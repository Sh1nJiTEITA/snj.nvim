---@class Metadata
---@field alias string | nil Optional alias for using with require
---@field config table | function | nil Optional setup parameters

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
	local pattern = construct_src_pattern(base)
	if url:find(pattern) ~= nil then
		return url
	end
	return nil
end

---@param url string
local function valid_gb(url)
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

---@class Man
local Man = {}

---@private
Man.__index = Man

---@type table<string,Metadata>
Man._metadatas = {}

---@param url string
---@return boolean
function Man.contains(url)
	return Man._metadatas[url] ~= nil
end

---@param url string
---@param meta UserMetadata
function Man.add_plugin(meta)
	local instance = Man.instance()

	local src = valid_gb(meta.gh) or valid_cb(meta.cb) or valid_gl(meta.gl)

	if src == nil then
		vim.notify("Cant add plugin: no url provided", vim.log.levels.ERROR)
		return
	end

	-- if instance.
end
