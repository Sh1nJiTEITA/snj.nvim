---@class Metadata
---@field url string | nil
---@field file string | nil
---@field alias string | nil Optional alias for using with require
---@field config table | function | nil Optional setup parameters
---@field branch string | nil
---@field deps UserMetadata  | UserMetadata[] | nil

---@class UserMetadata : Metadata
---@field gh string | nil Url from github
---@field cb string | nil Url from codeberg
---@field gl string | nil Url from gitlab

BASE_URL_GH = "https://github.com/"
BASE_URL_GL = "https://gitlab.com/"
BASE_URL_CB = "https://codeberg.org/"

---@return string
local function construct_src_pattern(base_url)
	return "^" .. base_url .. ".*"
end

---@param url string
---@param base string
local function valid_src(base, url)
	if url == nil then
		return nil
	end
	local pattern = construct_src_pattern(base)
	if url:find(pattern) ~= nil then
		return url
	end
	return nil
end

---@param url string
local function valid_gh(url)
	return valid_src(BASE_URL_GH, url)
end

---@param url string
local function valid_cb(url)
	return valid_src(BASE_URL_CB, url)
end

---@param url string
local function valid_gl(url)
	return valid_src(BASE_URL_GL, url)
end

---@param url string | nil
local function make_target_src(base, url)
	if url == nil then
		return nil
	end

	return base .. url
end

---@param url string | nil
local function target_gh(url)
	return make_target_src(BASE_URL_GH, url)
end

---@param url string | nil
local function target_gl(url)
	return make_target_src(BASE_URL_GL, url)
end

---@param url string | nil
local function target_cb(url)
	return make_target_src(BASE_URL_CB, url)
end

---@param meta UserMetadata
---@return string | nil
local function plugin_url(meta)
	return make_target_src(BASE_URL_GH, meta.gh)
		or make_target_src(BASE_URL_CB, meta.cb)
		or make_target_src(BASE_URL_GL, meta.gl)
end

---@param url string
---@return string | nil
local function generate_alias(url)
	local autoname = url:match(".*/(.*)$")
	if autoname then
		return autoname:gsub("%.nvim", "")
	end
	return nil
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

---@param plugins Metadata[]
---@return table<string, string[]>, table<string, number>, table<string, Metadata>
local build_dependency_graph = function(plugins)
	local indegree = {}
	local graph = {}
	local alias_to_meta = {}

	for _, meta in ipairs(plugins) do
		local alias = meta.alias
		assert(alias ~= nil)
		alias_to_meta[alias] = meta
		indegree[alias] = 0
		graph[alias] = {}
	end

	for _, meta in ipairs(plugins) do
		if meta.deps then
			for _, dep_alias in ipairs(meta.deps) do
				if alias_to_meta[dep_alias] then
					table.insert(graph[dep_alias], meta.alias)
					indegree[meta.alias] = indegree[meta.alias] + 1
				else
					vim.notify(
						"plman: Missing dependency '" .. dep_alias .. "' for '" .. meta.alias .. "'",
						vim.log.levels.WARN
					)
				end
			end
		end
	end

	return graph, indegree, alias_to_meta
end

---@param graph table<string, string[]>
---@param in_degree table<string, number>
---@param alias_to_meta table<string, Metadata>
---@param total_count number
---@return Metadata[] | nil
local function perform_topological_sort(graph, in_degree, alias_to_meta, total_count)
	local queue = {}
	local sorted = {}

	for alias, degree in pairs(in_degree) do
		if degree == 0 then
			table.insert(queue, alias)
		end
	end

	while #queue > 0 do
		local current = table.remove(queue, 1)
		table.insert(sorted, alias_to_meta[current])

		for _, dependent in ipairs(graph[current]) do
			in_degree[dependent] = in_degree[dependent] - 1
			if in_degree[dependent] == 0 then
				table.insert(queue, dependent)
			end
		end
	end

	if #sorted ~= total_count then
		vim.notify("plman: Circular dependency detected! Loading in default order.", vim.log.levels.ERROR)
		return nil
	end

	return sorted
end

---@param plugins Metadata[]
---@return Metadata[]
local function resolve_dependencies(plugins)
	local graph, in_degree, alias_to_meta = build_dependency_graph(plugins)
	local sorted = perform_topological_sort(graph, in_degree, alias_to_meta, #plugins)
	return sorted or plugins
end

---@class Man
local Man = {}

---@private
Man.__index = Man

---@type table<string>
---@private
Man._metadatas = {}

---@param alias string
---@return boolean
local function is_plugin_registered(alias)
	for _, existing in ipairs(Man._metadatas) do
		if existing.alias == alias then
			return true
		end
	end
	return false
end

---@param deps string | string[] | UserMetadata | UserMetadata[] | nil
---@return string[] | nil
local function normalize_and_register_deps(deps)
	if not deps then
		return nil
	end

	local normalized = {}
	-- Force into array format for iteration
	local iterable_deps = type(deps) == "table" and (#deps > 0 and deps or { deps }) or { deps }

	for _, dep in ipairs(iterable_deps) do
		if type(dep) == "table" then
			-- It's a UserMetadata object, register it recursively
			Man.add_plugin(dep)
			table.insert(normalized, dep.alias)
		elseif type(dep) == "string" then
			-- It's already a string alias
			table.insert(normalized, dep)
		end
	end

	return normalized
end

---@param meta UserMetadata | string
function Man.add_plugin(meta)
	if type(meta) == "string" then
		meta = require(meta)
	end
	if meta.file ~= nil then
		meta = require(meta.file)
	end

	local url = plugin_url(meta)
	if not url then
		return
	end
	meta.url = url

	meta.alias = meta.alias or generate_alias(url)
	if not meta.alias or is_plugin_registered(meta.alias) then
		return
	end

	meta.deps = normalize_and_register_deps(meta.deps)

	table.insert(Man._metadatas, meta)
end

local setup_plugin = function(name, tbl)
	local ok, plugin = pcall(require, name)

	if not ok then
		return
	end

	if type(plugin.setup) == "function" then
		plugin.setup(tbl)
	end
end

---@param meta Metadata
local function apply_config(meta)
	local tbl = meta.config

	if type(tbl) == "table" then
		--
		setup_plugin(meta.alias, tbl)
		--
	elseif type(tbl) == "function" then
		tbl = tbl()
		if type(tbl) == "table" then
			setup_plugin(meta.alias, tbl)
		else
		end
	else
		setup_plugin(meta.alias, tbl)
	end
end

function Man.apply()
	local sorted = resolve_dependencies(Man._metadatas)
	local pack_sequance = {}

	for _, meta in ipairs(sorted) do
		table.insert(pack_sequance, {
			src = meta.url,
			name = meta.alias,
			version = meta.branch,
		})
	end

	vim.pack.add(pack_sequance)

	for _, meta in pairs(Man._metadatas) do
		-- vim.notify('Enabling plugin with name="' .. meta.alias .. '"', vim.log.levels.INFO)
		apply_config(meta)
	end

	Man._metadatas = {}
end

return Man
