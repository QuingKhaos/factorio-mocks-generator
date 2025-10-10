--- @class factorio_mocks_generator.prototype_rules.default_extractors.Vector
local Vector = {}

--- Extracts Vector default values from string representations
--- @param default_string string The default value string to parse
--- @return data.Vector? extracted_value The extracted vector values, or nil if not extractable
function Vector.extract(default_string)
  -- Remove backticks if present
  local cleaned = string.gsub(default_string, "^`(.+)`$", "%1")

  -- Try to extract array format: {x, y}
  local array_match = string.match(cleaned, "^{([^}]+)}$")
  if array_match then
    local values = {}
    for value in string.gmatch(array_match, "[%-]?[%d%.]+") do
      table.insert(values, tonumber(value))
    end

    if #values == 2 then
      return values
    end
  end

  return nil
end

return Vector