---@class Metadata
---@field alias string | nil Optional alias for using with require
---@field config table | function | nil Optional setup parameters
---@field branch string | nil

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

---@class Man
local Man = {}

---@private
Man.__index = Man

---@type table<string,Metadata>
---@private
Man._metadatas = {}

---@param url string
---@return boolean
function Man.contains(url)
	return Man._metadatas[url] ~= nil
end

---@param meta UserMetadata
function Man.add_plugin(meta)
	local url = target_gh(meta.gh) or target_cb(meta.cb) or target_gl(meta.gl)

	if url == nil then
		vim.notify("Cant add plugin: no url provided", vim.log.levels.ERROR)
		return
	end

	if meta.alias == nil then
		local autoname = url:match(".*/(.*)$")
		if autoname ~= nil then
			meta.alias = autoname:gsub("%.nvim", "")
		end
	end

	vim.notify('Installing plugin with name="' .. meta.alias .. '"', vim.log.levels.INFO)

	if not Man.contains(url) then
		Man._metadatas[url] = meta
	end
end

---@param meta Metadata
local function apply_config(meta)
	local tbl = meta.config

	if type(tbl) == "function" then
		tbl = tbl()
	end

	if type(tbl) == "table" then
		require(meta.alias).setup(tbl)
	else
		require(meta.alias).setup({})
	end
end

function Man.apply()
	local pack_sequance = {}

	for url, meta in pairs(Man._metadatas) do
		table.insert(pack_sequance, {
			src = url,
			name = meta.alias,
			version = meta.branch,
		})
	end

	vim.pack.add(pack_sequance)

	for _, meta in pairs(Man._metadatas) do
		apply_config(meta)
	end

	Man._metadatas = {}
end

return Man
