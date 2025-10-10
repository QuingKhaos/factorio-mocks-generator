--- @class factorio_mocks_generator.prototype_rules.default_extractors.BoundingBox
local BoundingBox = {}

--- Extracts BoundingBox default values from string representations
--- @param default_string string The default value string to parse
--- @return data.BoundingBox? extracted_value The extracted bounding box values, or nil if not extractable
function BoundingBox.extract(default_string)
  -- Remove backticks if present, also handle "Empty = `...`" pattern
  local cleaned = string.gsub(default_string, "^.*`(.+)`.*$", "%1")
  if cleaned == default_string then
    -- No backticks found, try without them
    cleaned = default_string
  end

  -- Try to extract nested array format: {{x1, y1}, {x2, y2}}
  local nested_match = string.match(cleaned, "^{{([^}]+)}, {([^}]+)}}$")
  if nested_match then
    local point1 = {}
    local point2 = {}

    -- Extract first point coordinates
    for value in string.gmatch(nested_match, "[%-]?[%d%.]+") do
      table.insert(point1, tonumber(value))
    end

    -- Extract second point coordinates from the remaining string
    local _, second_point_start = string.find(cleaned, "}, {")
    if second_point_start then
      local second_point_str = string.sub(cleaned, second_point_start + 1)
      second_point_str = string.match(second_point_str, "^([^}]+)")

      for value in string.gmatch(second_point_str, "[%-]?[%d%.]+") do
        table.insert(point2, tonumber(value))
      end
    end

    if #point1 == 2 and #point2 == 2 then
      return {point1, point2}
    end
  end

  return nil
end

return BoundingBox
