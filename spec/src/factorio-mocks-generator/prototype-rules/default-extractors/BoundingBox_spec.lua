insulate("[#UNIT] prototype-rules.default-extractors.BoundingBox", function()
  local extractors = require("factorio-mocks-generator.prototype-rules.default-extractors")

  it("should extract backtick-wrapped array format as Lua table", function()
    local property = {
      name = "collision_box",
      type = "BoundingBox",
      optional = true,
      default = "Empty = `{{0, 0}, {0, 0}}`"
    }

    local expected = {{0, 0}, {0, 0}}

    local result = extractors.extract_structured_default(property)
    assert.are.same(expected, result)
  end)

  it("should extract complex decimals as Lua table", function()
    local property = {
      name = "collision_box",
      type = "BoundingBox",
      optional = true,
      default = "`{{-0.7, -2.516}, {0.7, 2.516}}`"
    }

    local expected = {{-0.7, -2.516}, {0.7, 2.516}}

    local result = extractors.extract_structured_default(property)
    assert.are.same(expected, result)
  end)
end)
