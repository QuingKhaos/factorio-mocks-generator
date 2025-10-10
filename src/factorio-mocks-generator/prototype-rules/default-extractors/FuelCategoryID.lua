--- @class factorio_mocks_generator.prototype_rules.default_extractors.FuelCategoryID
local FuelCategoryID = {}

--- Extracts FuelCategoryID array default values from string representations
--- @param default_string string The default value string to parse
--- @return data.FuelCategoryID[]? extracted_value The extracted fuel category ID values, or nil if not extractable
function FuelCategoryID.extract_array(default_string)
  -- Remove backticks if present
  local cleaned = string.gsub(default_string, "^`(.+)`$", "%1")

  -- Try to extract array format: {"string1", "string2", ...}
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

return FuelCategoryID