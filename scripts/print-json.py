import subprocess

import gdb


class PrintJson(gdb.Command):
    """Pretty-print a std::string or nlohmann::json expression as JSON via jq.
    Usage: pjson <expression>
    """

    def __init__(self):
        super().__init__("pjson", gdb.COMMAND_DATA)

    def invoke(self, arg, from_tty):
        if not arg:
            print("Usage: pjson <expression>")
            return

        raw_str = self._extract_string(arg)
        if raw_str is None:
            print("Could not extract a string from this expression.")
            return

        self._pretty_print(raw_str)

    def _try(self, expr):
        try:
            result = gdb.parse_and_eval(expr)
            return result.string()
        except Exception:
            return None

    def _extract_string(self, arg):
        try:
            val = gdb.parse_and_eval(arg)
        except Exception as e:
            print(f"Error evaluating expression: {e}")
            return None

        type_name = str(val.type.strip_typedefs())
        is_json = "nlohmann" in type_name or "basic_json" in type_name

        candidates = []
        if is_json:
            # Extract the versioned namespace prefix, e.g. "nlohmann::json_abi_v3_11_3"
            prefix = type_name.split("::basic_json")[0]
            error_handler = f"{prefix}::detail::error_handler_t::strict"

            candidates += [
                f"({arg}).dump(-1, ' ', false, {error_handler}).c_str()",
                f"({arg}).dump(2, ' ', false, {error_handler}).c_str()",
                # fallback: cast enum value 0 (strict) directly by integer if the
                # fully-qualified name above doesn't resolve for some reason
                f"({arg}).dump(-1, ' ', false, ({prefix}::detail::error_handler_t)0).c_str()",
            ]
        candidates.append(f"({arg}).c_str()")

        for expr in candidates:
            try:
                result = gdb.parse_and_eval(expr)
                return (
                    result.string()
                    if result.type.code == gdb.TYPE_CODE_PTR
                    else str(result)
                )
            except Exception as e:
                print(f"  [debug] '{expr}' failed: {e}")

        print(
            "Warning: none of dump()/c_str() call variants worked;"
            " falling back to GDB's own printer."
        )
        return str(val)

    def _pretty_print(self, raw_str):
        try:
            result = subprocess.run(
                ["jq", "."], input=raw_str, capture_output=True, text=True
            )
            if result.returncode != 0:
                print(f"jq error: {result.stderr}")
                print("Raw string was:")
                print(raw_str)
            else:
                print(result.stdout)
        except FileNotFoundError:
            print("Error: jq not found in PATH")


PrintJson()
