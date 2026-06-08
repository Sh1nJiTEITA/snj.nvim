import lldb

lldb
"""

enum class value_t : std::uint8_t
{
    null,             ///< null value
    object,           ///< object (unordered set of name/value pairs)
    array,            ///< array (ordered collection of values)
    string,           ///< string value
    boolean,          ///< boolean value
    number_integer,   ///< number value (signed integer)
    number_unsigned,  ///< number value (unsigned integer)
    number_float,     ///< number value (floating-point)
    binary,           ///< binary array (ordered collection of bytes)
    discarded         ///< discarded by the parser callback function
};

union json_value
{
    /// object (stored with pointer to save storage)
    object_t* object;
    /// array (stored with pointer to save storage)
    array_t* array;
    /// string (stored with pointer to save storage)
    string_t* string;
    /// binary (stored with pointer to save storage)
    binary_t* binary;
    /// boolean
    boolean_t boolean;
    /// number (integer)
    number_integer_t number_integer;
    /// number (unsigned integer)
    number_unsigned_t number_unsigned;
    /// number (floating-point)
    number_float_t number_float;
};


template<
    template<typename, typename, typename...> class ObjectType,   
    template<typename, typename...> class ArrayType,              
    class StringType, 
    class BooleanType, 
    class NumberIntegerType, 
    class NumberUnsignedType, 
    class NumberFloatType,              
    template<typename> class AllocatorType,                       
    template<typename, typename = void> class JSONSerializer,     
    class BinaryType
>
struct basic_json
{
    value_t m_type;
    json_value m_value;
};

template<typename BasicJsonType>
struct internal_iterator
{
    /// iterator for JSON objects
    typename BasicJsonType::object_t::iterator object_iterator {};
    /// iterator for JSON arrays
    typename BasicJsonType::array_t::iterator array_iterator {};
    /// generic iterator for all other types
    primitive_iterator_t primitive_iterator {};
};

template<typename BasicJsonType>
struct iter_impl
{
    pointer m_object = nullptr;

    internal_iterator<typename std::remove_const<BasicJsonType>::type> m_it {};
};


template<typename BinaryType>
struct byte_container_with_subtype : BinaryType
{
    std::uint8_t m_subtype = 0;
    bool m_has_subtype = false;
};
"""


class ValueType:
    def __init__(self, valobj):
        self.null = 0  # < null value
        self.object = 1  # < object (unordered set of name/value pairs)
        self.array = 2  # < array (ordered collection of values)
        self.string = 3  # < string value
        self.boolean = 4  # < boolean value
        self.number_integer = 5  # < number value (signed integer)
        self.number_unsigned = 6  # < number value (unsigned integer)
        self.number_float = 7  # < number value (floating-point)
        self.binary = 8  # < binary array (ordered collection of bytes)
        self.discarded = 9  # < discarded by the parser callback function
        self.valobj = valobj.GetNonSyntheticValue()
        self.type = self.valobj.GetValueAsUnsigned(self.null)

    def IsNull(self):
        return self.type == self.null

    def IsObject(self):
        return self.type == self.object

    def IsArray(self):
        return self.type == self.array

    def IsString(self):
        return self.type == self.string

    def IsBool(self):
        return self.type == self.boolean

    def IsInt(self):
        return self.type == self.number_integer

    def IsUint(self):
        return self.type == self.number_unsigned

    def IsFloat(self):
        return self.type == self.number_float

    def IsBinary(self):
        return self.type == self.binary

    def IsDiscarded(self):
        return self.type == self.discarded

    def GetSummary(self):
        return self.valobj.GetValue()


class Value:
    def __init__(self, valobj):
        self.valobj = valobj.GetNonSyntheticValue()
        self.type = ValueType(self.valobj.GetChildMemberWithName("m_type"))
        self.m_value = self.valobj.GetChildMemberWithName("m_value")
        self.val = self.Cast()
        self.base_val = self.CastToBase()

    def GetSummary(self):
        if self.val is None:
            return self.type.GetSummary()

        if self.type.IsBinary():
            s_subtype = ""

            if (
                self.val.GetChildMemberWithName("m_has_subtype").GetValueAsUnsigned(0)
                > 0
            ):
                s_subtype = (
                    "subtype="
                    + str(
                        self.val.GetChildMemberWithName("m_subtype").GetValueAsUnsigned(
                            0
                        )
                    )
                    + ","
                )

            return "binary(" + s_subtype + str(self.base_val.GetSummary()) + ")"

        return SummaryOrValue(self.val)

    def GetCount(self):
        if self.val is None:
            return 0

        return self.val.GetNumChildren()

    def IndexOf(self, name):
        if self.type.IsArray():
            return self.val.GetIndexOfChildWithName(name)
        if self.type.IsObject():
            return self.val.GetIndexOfChildWithName(name)
        if self.type.IsString():
            return self.val.GetIndexOfChildWithName(name)
        if self.type.IsBinary():
            return self.base_val.GetIndexOfChildWithName(name)

        return None

    def At(self, index):
        if self.type.IsArray():
            return self.val.GetChildAtIndex(index)
        if self.type.IsObject():
            pair = self.val.GetChildAtIndex(index)
            first = pair.GetChildMemberWithName("first")
            second = pair.GetChildMemberWithName("second")

            return self.m_value.CreateValueFromData(
                "[%s]" % SummaryOrValue(first), second.GetData(), second.GetType()
            )
        if self.type.IsString():
            return self.val.GetChildAtIndex(index)
        if self.type.IsBinary():
            return self.base_val.GetChildAtIndex(index)

        return None

    def Cast(self):
        if self.type.IsArray():
            return self.m_value.GetChildMemberWithName("array").deref
        if self.type.IsObject():
            return self.m_value.GetChildMemberWithName("object").deref
        if self.type.IsString():
            return self.m_value.GetChildMemberWithName("string").deref
        if self.type.IsBinary():
            return self.m_value.GetChildMemberWithName("binary").deref
        if self.type.IsBool():
            return self.m_value.GetChildMemberWithName("boolean")
        if self.type.IsInt():
            return self.m_value.GetChildMemberWithName("number_integer")
        if self.type.IsUint():
            return self.m_value.GetChildMemberWithName("number_unsigned")
        if self.type.IsFloat():
            return self.m_value.GetChildMemberWithName("number_float")

        return None

    def CastToBase(self):
        if self.type.IsBinary():
            return self.val.Cast(
                self.val.GetType().GetDirectBaseClassAtIndex(0).GetType()
            )

        return None


class Iterator:
    def __init__(self, valobj):
        self.valobj = valobj.GetNonSyntheticValue()
        self.value = None
        self.m_object = Value(self.valobj.GetChildMemberWithName("m_object"))

        if self.TryGetKeyAndOrValue():
            self.value = Value(self.m_value)

    def GetSummary(self):
        if self.m_key is None:
            if self.value is None:
                if self.m_value is None:
                    if self.m_object is None:
                        return "invalid"

                    if self.m_primitive is None:
                        return self.m_object.type.GetSummary()

                    summary = self.m_object.GetSummary()
                    index = self.m_primitive.GetValueAsUnsigned(0)

                    if self.m_object.type.IsString():
                        if index < (len(summary) - 2):
                            return "[%d] = %s" % (index, summary[index + 1])

                        return "invalid"

                    return summary

                return SummaryOrValue(self.m_value)

            return self.value.GetSummary()

        return "%s: %s" % (SummaryOrValue(self.m_key), self.value.GetSummary())

    def GetCount(self):
        if self.value is None:
            return 0

        return self.value.GetCount()

    def IndexOf(self, name):
        if self.value is None:
            return None

        return self.value.IndexOf(name)

    def At(self, index):
        if self.value is None:
            return None

        return self.value.At(index)

    def TryGetKeyAndOrValue(self):
        self.m_key = None
        self.m_value = None
        self.m_primitive = None

        if self.m_object.type.IsNull():
            return False

        if self.m_object.type.IsObject():
            self.m_key = self.valobj.GetValueForExpressionPath(
                ".m_it.object_iterator.first"
            )
            self.m_value = self.valobj.GetValueForExpressionPath(
                ".m_it.object_iterator.second"
            )
            return True

        if self.m_object.type.IsArray():
            self.m_value = self.valobj.GetValueForExpressionPath(
                ".m_it.array_iterator"
            ).GetChildAtIndex(0)
            return True

        self.m_primitive = self.valobj.GetValueForExpressionPath(
            ".m_it.primitive_iterator"
        ).GetChildAtIndex(0)

        return False


class Synthetic:
    def __init__(self, valobj, internal_dict):
        self.valobj = valobj
        self.value = Value(valobj)
        # this call should initialize the Python object using valobj as the variable to provide synthetic children for

    def num_children(self):
        # this call should return the number of children that you want your object to have
        return self.value.GetCount()

    def get_child_index(self, name):
        # this call should return the index of the synthetic child whose name is given as argument
        return self.value.IndexOf(name)

    def get_child_at_index(self, index):
        # this call should return a new LLDB SBValue object representing the child at the index given as argument
        return self.value.At(index)

    def update(self):
        # this call should be used to update the internal state of this Python object whenever the state of the variables in LLDB changes.[1]
        pass

    def has_children(self):
        # this call should return True if this object might have children, and False if this object can be guaranteed not to have children.[2]]
        if self.value.GetCount() > 0:
            return True

        return False

    def get_value(self):
        # this call can return an SBValue to be presented as the value of the synthetic value under consideration.[3]
        return self.valobj


class IteratorSynthetic:
    def __init__(self, valobj, internal_dict):
        self.valobj = valobj
        self.iterator = Iterator(valobj)
        # this call should initialize the Python object using valobj as the variable to provide synthetic children for

    def num_children(self):
        # this call should return the number of children that you want your object to have
        return self.iterator.GetCount()

    def get_child_index(self, name):
        # this call should return the index of the synthetic child whose name is given as argument
        return self.iterator.IndexOf(name)

    def get_child_at_index(self, index):
        # this call should return a new LLDB SBValue object representing the child at the index given as argument
        return self.iterator.At(index)

    def update(self):
        # this call should be used to update the internal state of this Python object whenever the state of the variables in LLDB changes.[1]
        pass

    def has_children(self):
        # this call should return True if this object might have children, and False if this object can be guaranteed not to have children.[2]]
        if self.iterator.GetCount() > 0:
            return True

        return False

    def get_value(self):
        # this call can return an SBValue to be presented as the value of the synthetic value under consideration.[3]
        return self.valobj


def SummaryOrValue(valobj):
    summary = valobj.GetSummary()

    if summary is None:
        return valobj.GetValue()
    return summary


def Summary(valobj, internal_dict, options):
    return Value(valobj).GetSummary()


def IteratorSummary(valobj, internal_dict, options):
    return Iterator(valobj).GetSummary()


# def __lldb_init_module(debugger, internal_dict):
#
#     debugger.HandleCommand(
#         'type summary add -x "^nlohmann::basic_json<.+>(( )?&)?$" -F nlohmann_json.Summary'
#     )
#     debugger.HandleCommand(
#         'type synthetic add -x "^nlohmann::basic_json<.+>(( )?&)?$" -l nlohmann_json.Synthetic'
#     )
#
#     debugger.HandleCommand(
#         'type summary add -x "^nlohmann::detail::iter_impl<.+>(( )?&)?$" -F nlohmann_json.IteratorSummary'
#     )
#     debugger.HandleCommand(
#         'type synthetic add -x "^nlohmann::detail::iter_impl<.+>(( )?&)?$" -l nlohmann_json.IteratorSynthetic'
#     )


def __lldb_init_module(debugger, internal_dict):
    # Match nlohmann::basic_json regardless of middle namespaces like json_abi_diag
    # We use (::.*)? to catch any inline versioning or diagnostic namespaces
    json_regex = "^nlohmann(::.*)?::basic_json<.+>(( )?&)?$"
    iter_regex = "^nlohmann(::.*)?::detail::iter_impl<.+>(( )?&)?$"

    debugger.HandleCommand(
        f'type summary add -x "{json_regex}" -F nlohmann_json.Summary'
    )
    debugger.HandleCommand(
        f'type synthetic add -x "{json_regex}" -l nlohmann_json.Synthetic'
    )

    debugger.HandleCommand(
        f'type summary add -x "{iter_regex}" -F nlohmann_json.IteratorSummary'
    )
    debugger.HandleCommand(
        f'type synthetic add -x "{iter_regex}" -l nlohmann_json.IteratorSynthetic'
    )
