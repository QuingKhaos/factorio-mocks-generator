--- @class factorio_mocks_generator.prototype_rules.default_extractors.Color
local Color = {}

--- Extracts Color default values from string representations
--- @param default_string string The default value string to parse
--- @return data.Color[]? extracted_value The extracted color values, or nil if not extractable
function Color.extract_array(default_string)
  -- Remove backticks if present
  local cleaned = string.gsub(default_string, "^`(.+)`$", "%1")

  -- For Color arrays, try to extract nested array format: {{r, g, b}}
    local nested_match = string.match(cleaned, "^{{([%d%.,%s]+)}}$")
    if nested_match then
      --- @type data.Color
      local values = {}
      for value in string.gmatch(nested_match, "[%d%.]+") do
        table.insert(values, tonumber(value))
      end

      if #values >= 3 then
        return {values} -- Wrap in outer array for Color array format
      end
    end

    return nil -- Color arrays only support nested format
end

--- Extracts Color default values from string representations
--- @param default_string string The default value string to parse
--- @return data.Color? extracted_value The extracted color values, or nil if not extractable
function Color.extract(default_string)
  -- Remove backticks if present
  local cleaned = string.gsub(default_string, "^`(.+)`$", "%1")

  -- For single Color types, try multiple formats:

  -- Try to extract array format: {r, g, b} or {r, g, b, a}
  local array_match = string.match(cleaned, "^{([%d%.,%s]+)}%s*%(.*%)?$") or string.match(cleaned, "^{([%d%.,%s]+)}$")
  if array_match then
    local values = {}
    for value in string.gmatch(array_match, "[%d%.]+") do
      table.insert(values, tonumber(value))
    end

    if #values >= 3 then -- RGB or RGBA
      return values
    end
  end

  -- Try to extract object format: {r=1, g=1, b=1} or {r=1, g=1, b=1, a=1}
  local object_match = string.match(cleaned, "^{(.+)}%s*%(.*%)?$") or string.match(cleaned, "^{(.+)}$")
  if object_match and string.find(object_match, "[rgba]%s*=") then
    local color_obj = {}
    for key, value in string.gmatch(object_match, "([rgba])%s*=%s*([%d%.]+)") do
      color_obj[key] = tonumber(value)
    end

    if color_obj.r then
      color_obj.r = {__meta_order__ = 0, __value__ = color_obj.r}
    end

    if color_obj.g then
      color_obj.g = {__meta_order__ = 1, __value__ = color_obj.g}
    end

    if color_obj.b then
      color_obj.b = {__meta_order__ = 2, __value__ = color_obj.b}
    end

    if color_obj.a then
      color_obj.a = {__meta_order__ = 3, __value__ = color_obj.a}
    end

    return color_obj
  end

  return nil
end

return Color
