insulate("[#UNIT] prototype-rules.default-extractors.LocalisedString", function()
  local extractors = require("factorio-mocks-generator.prototype-rules.default-extractors")

  it("should extract backtick-wrapped array format as Lua table", function()
    local property = {
      name = "fuel_value_type",
      type = "LocalisedString",
      optional = true,
      default = "`{\"description.fuel-value\"}`"
    }

    local expected = {"description.fuel-value"}

    local result = extractors.extract_structured_default(property)
    assert.are.same(expected, result)
  end)
end)
