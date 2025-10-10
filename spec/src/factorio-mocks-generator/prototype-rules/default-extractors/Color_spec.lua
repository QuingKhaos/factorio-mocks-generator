insulate("[#UNIT] prototype-rules.default-extractors.Color", function()
  local extractors = require("factorio-mocks-generator.prototype-rules.default-extractors")

  describe("for Color properties", function()
    it("should extract bare array format as Lua table", function()
      local property = {
        name = "some_color",
        type = "Color",
        optional = true,
        default = "{1, 1, 1, 1}"
      }

      local expected = {1, 1, 1, 1}

      local result = extractors.extract_structured_default(property)
      assert.are.same(expected, result)
    end)

    it("should extract backtick-wrapped array format as Lua table", function()
      local property = {
        name = "some_color",
        type = "Color",
        optional = true,
        default = "`{0.05, 0.05, 0.05, 1.0}`"
      }

      local expected = {0.05, 0.05, 0.05, 1.0}

      local result = extractors.extract_structured_default(property)
      assert.are.same(expected, result)
    end)

    it("should extract RGB array format (no alpha) as Lua table", function()
      local property = {
        name = "some_color",
        type = "Color",
        optional = true,
        default = "`{1, 1, 1}`"
      }

      local expected = {1, 1, 1}

      local result = extractors.extract_structured_default(property)
      assert.are.same(expected, result)
    end)

    it("should extract compact array format as Lua table", function()
      local property = {
        name = "some_color",
        type = "Color",
        optional = true,
        default = "{1,1,1,1} (white)"
      }

      local expected = {1, 1, 1, 1}

      local result = extractors.extract_structured_default(property)
      assert.are.same(expected, result)
    end)

    it("should extract backtick-wrapped RGBA object as Lua table with metadata", function()
      local property = {
        name = "some_color",
        type = "Color",
        optional = true,
        default = "`{r=1, g=1, b=1, a=1}`"
      }

      local expected = {
        r = {__meta_order__ = 0, __value__ = 1},
        g = {__meta_order__ = 1, __value__ = 1},
        b = {__meta_order__ = 2, __value__ = 1},
        a = {__meta_order__ = 3, __value__ = 1},
      }

      local result = extractors.extract_structured_default(property)
      assert.are.same(expected, result)
    end)

    it("should extract backtick-wrapped RGB object format as Lua table with metadata", function()
      local property = {
        name = "some_color",
        type = "Color",
        optional = true,
        default = "`{r=1, g=1, b=1}`"
      }

      local expected = {
        r = {__meta_order__ = 0, __value__ = 1},
        g = {__meta_order__ = 1, __value__ = 1},
        b = {__meta_order__ = 2, __value__ = 1},
      }

      local result = extractors.extract_structured_default(property)
      assert.are.same(expected, result)
    end)

    it("should extract RGB object format as Lua table with metadata", function()
      local property = {
        name = "some_color",
        type = "Color",
        optional = true,
        default = "{r=1, g=1, b=1} (White)"
      }

      local expected = {
        r = {__meta_order__ = 0, __value__ = 1},
        g = {__meta_order__ = 1, __value__ = 1},
        b = {__meta_order__ = 2, __value__ = 1},
      }

      local result = extractors.extract_structured_default(property)
      assert.are.same(expected, result)
    end)

    it("should extract fractional values in RGBA object with metadata", function()
      local property = {
        name = "some_color",
        type = "Color",
        optional = true,
        default = "`{r=0.375, g=0.375, b=0.375, a=0.375}`"
      }

      local expected = {
        r = {__meta_order__ = 0, __value__ = 0.375},
        g = {__meta_order__ = 1, __value__ = 0.375},
        b = {__meta_order__ = 2, __value__ = 0.375},
        a = {__meta_order__ = 3, __value__ = 0.375},
      }

      local result = extractors.extract_structured_default(property)
      assert.are.same(expected, result)
    end)
  end)

  describe("for Color[] properties", function()
    it("should handle tuple defaults", function()
      local property = {
        name = "some_colors",
        type = {
          complex_type = "array",
          value = "Color"
        },
        optional = true,
        default = "{{1, 1, 1}}"
      }

      local expected = {{1, 1, 1}}

      local result = extractors.extract_structured_default(property)
      assert.are.same(expected, result)
    end)
  end)
end)
