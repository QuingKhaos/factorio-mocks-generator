local curl = require("cURL")
local json = require("cjson")
local file_utils = require("factorio-mocks-generator.file-utils")
local utils = require("factorio-mocks-generator.utils")
local prototype_rules_generator = require("factorio-mocks-generator.prototype-rules.generator")
local serpent = require("serpent")

--- @class factorio_mocks_generator.rules_generator.options
--- @field force boolean Overwrite existing files
--- @field visibility string[] List of game expansions
local _default_options = {
  force = false,
  visibility = {},
}

--- @class factorio_mocks_generator.rules_generator
local rules_generator = {}

--- Fetches the API JSON data for the given Factorio version and API type.
--- @param version string Factorio version (e.g., "1.1.0") or alias ("stable" or "latest")
--- @param api_type string "prototype" or "runtime"
--- @return table data Decoded JSON API data (FactorioPrototypeAPI for prototype, FactorioRuntimeAPI for runtime)
--- @private
function rules_generator._fetch_api_json(version, api_type)
  local url = string.format("https://lua-api.factorio.com/%s/%s-api.json", version, api_type)

  local response_body = {}
  local c = curl.easy()

  c:setopt(curl.OPT_URL, url)
  c:setopt(curl.OPT_WRITEFUNCTION, function(chunk)
    table.insert(response_body, chunk)
    return #chunk
  end)

  local ok, err = c:perform()
  local response_code = c:getinfo(curl.INFO_RESPONSE_CODE)
  c:close()

  if not ok then
    error(string.format("Failed to fetch %s API data: %s", api_type, err))
  end

  if response_code ~= 200 then
    error(string.format("Failed to fetch %s API data. HTTP status: %s", api_type, response_code))
  end

  local body = table.concat(response_body)
  return json.decode(body)
end

--- Creates the rules entrypoint
--- @param output_dir string Directory to save the init.lua file
--- @param visibility string[] List of game expansions
function rules_generator._create_entrypoint(output_dir, visibility)
  local content = file_utils.read_file("src/factorio-mocks-generator/templates/rules/init.lua")

  content = string.gsub(content, "visibility = %{%}", "visibility = " .. serpent.line(visibility, {comment = false}))

  file_utils.write_file(output_dir .. "/init.lua", content)
end

--- Generates LIVR rules for the specified Factorio version.
--- @param version string Factorio version (e.g., "2.0.66") or well-known alias ("stable" or "experimental")
--- @param output_dir string Directory to save generated LIVR rules
--- @param options? factorio_mocks_generator.rules_generator.options Options for rule generation
function rules_generator.generate_rules_for_version(version, output_dir, options)
  options = utils.deepcopy(options) or {}
  options.force = options.force or _default_options.force
  options.visibility = options.visibility or _default_options.visibility

  -- Resolve community aliases to API endpoint aliases
  -- "stable" maps to "stable" in the API, so no change needed
  local api_version = version
  if version == "experimental" then
    api_version = "latest"
  end

  file_utils.prepare_output_directory(output_dir, options.force)
  local prototype_api = rules_generator._fetch_api_json(api_version, "prototype")

  prototype_rules_generator.generate_prototype_rules(prototype_api, output_dir, {
    visibility = options.visibility
  })

  rules_generator._create_entrypoint(output_dir, options.visibility)
end

return rules_generator
