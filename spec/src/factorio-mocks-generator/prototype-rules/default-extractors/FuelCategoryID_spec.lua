insulate("[#UNIT] prototype-rules.default-extractors.FuelCategoryID", function()
  local extractors = require("factorio-mocks-generator.prototype-rules.default-extractors")

  describe("for FuelCategoryID[]", function()
    it("should extract backtick-wrapped array format as Lua table", function()
      local property = {
        name = "fuel_categories",
        type = {
          complex_type = "array",
          value = "FuelCategoryID",
        },
        optional = true,
        default = "`{\"chemical\"}`"
      }

      local expected = {"chemical"}

      local result = extractors.extract_structured_default(property)
      assert.are.same(expected, result)
    end)
  end)
end)
