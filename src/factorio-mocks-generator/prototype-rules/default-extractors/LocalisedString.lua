--- @class factorio_mocks_generator.prototype_rules.default_extractors.LocalisedString
local LocalisedString = {}

--- Extracts LocalisedString default values from string representations
--- @param default_string string The default value string to parse
--- @return data.LocalisedString? extracted_value The extracted localised string values, or nil if not extractable
function LocalisedString.extract(default_string)
  -- Remove backticks if present
  local cleaned = string.gsub(default_string, "^`(.+)`$", "%1")

  -- Try to extract array format: {"string"}
  local array_match = string.match(cleaned, "^{([^}]+)}$")
  if array_match then
    local values = {}
    -- Extract quoted strings from the array
    for value in string.gmatch(array_match, '"([^"]*)"') do
      table.insert(values, value)
    end

    if #values > 0 then
      return values
    end
  end

  return nil
end

return LocalisedString