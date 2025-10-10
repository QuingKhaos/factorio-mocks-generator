--- @class factorio_mocks_generator.prototype_rules.default_extractors.Vector3D
local Vector3D = {}

--- Extracts Vector3D default values from string representations
--- @param default_string string The default value string to parse
--- @return data.Vector3D? extracted_value The extracted vector values, or nil if not extractable
function Vector3D.extract(default_string)
  -- Remove backticks if present
  local cleaned = string.gsub(default_string, "^`(.+)`$", "%1")

  -- Try to extract array format: {x, y, z}
  local array_match = string.match(cleaned, "^{([^}]+)}$")
  if array_match then
    local values = {}
    for value in string.gmatch(array_match, "[%-]?[%d%.]+") do
      table.insert(values, tonumber(value))
    end

    if #values == 3 then
      return values
    end
  end

  return nil
end

return Vector3D