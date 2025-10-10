insulate("[#UNIT] prototype-rules.default-extractors.Vector3D", function()
  local extractors = require("factorio-mocks-generator.prototype-rules.default-extractors")

  it("should extract bare array format as Lua table", function()
    local property = {
      name = "direction",
      type = "Vector3D",
      optional = true,
      default = "{1, 1, 1}"
    }

    local expected = {1, 1, 1}

    local result = extractors.extract_structured_default(property)
    assert.are.same(expected, result)
  end)

end)
