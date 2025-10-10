insulate("[#UNIT] LIVR.rules.string", function()
  local rules = require("factorio-mocks-generator.LIVR.rules.string")

  describe("string", function()
    it("should create validator function", function()
      local rule_func = rules.string()
      assert.is_function(rule_func)
    end)

    it("should pass validation for nil values", function()
      local rule_func = rules.string()

      local result, error = rule_func(nil)
      assert.is_nil(result)
      assert.is_nil(error)
    end)

    it("should pass validation for empty strings", function()
      local rule_func = rules.string()

      local result, error = rule_func("")
      assert.are.equal("", result)
      assert.is_nil(error)
    end)

    it("should pass validation for valid strings", function()
      local rule_func = rules.string()

      local result, error = rule_func("hello")
      assert.are.equal("hello", result)
      assert.is_nil(error)
    end)

    it("should pass validation for string with whitespace", function()
      local rule_func = rules.string()

      local result, error = rule_func("  hello world  ")
      assert.are.equal("  hello world  ", result)
      assert.is_nil(error)
    end)

    it("should fail validation for numbers", function()
      local rule_func = rules.string()

      local result, error = rule_func(123)
      assert.are.equal(123, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for booleans", function()
      local rule_func = rules.string()

      local result, error = rule_func(true)
      assert.are.equal(true, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for tables", function()
      local rule_func = rules.string()

      local result, error = rule_func({})
      assert.are.same({}, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)
  end)

  describe("eq", function()
    it("should create validator function", function()
      local rule_func = rules.eq(nil, "expected")
      assert.is_function(rule_func)
    end)

    it("should pass validation for nil values", function()
      local rule_func = rules.eq(nil, "expected")

      local result, error = rule_func(nil)
      assert.is_nil(result)
      assert.is_nil(error)
    end)

    it("should pass validation for matching empty string values", function()
      local rule_func = rules.eq(nil, "")

      local result, error = rule_func("")
      assert.are.equal("", result)
      assert.is_nil(error)
    end)

    it("should pass validation for matching string values", function()
      local rule_func = rules.eq(nil, "hello")

      local result, error = rule_func("hello")
      assert.are.equal("hello", result)
      assert.is_nil(error)
    end)

    it("should pass validation for matching number values", function()
      local rule_func = rules.eq(nil, 42)

      local result, error = rule_func(42)
      assert.are.equal(42, result)
      assert.is_nil(error)
    end)

    it("should pass validation for matching boolean values", function()
      local rule_func = rules.eq(nil, true)

      local result, error = rule_func(true)
      assert.are.equal(true, result)
      assert.is_nil(error)
    end)

    it("should fail validation for non-matching string and empty string values", function()
      local rule_func = rules.eq(nil, "expected")

      local result, error = rule_func("")
      assert.are.equal("", result)
      assert.are.equal("NOT_ALLOWED_VALUE", error)
    end)

    it("should fail validation for non-matching string values", function()
      local rule_func = rules.eq(nil, "expected")

      local result, error = rule_func("actual")
      assert.are.equal("actual", result)
      assert.are.equal("NOT_ALLOWED_VALUE", error)
    end)

    it("should fail validation for non-matching number values", function()
      local rule_func = rules.eq(nil, 42)

      local result, error = rule_func(24)
      assert.are.equal(24, result)
      assert.are.equal("NOT_ALLOWED_VALUE", error)
    end)

    it("should fail validation for type mismatches (strict checking)", function()
      local rule_func = rules.eq(nil, "42")

      local result, error = rule_func(42)
      assert.are.equal(42, result)
      assert.are.equal("NOT_ALLOWED_VALUE", error)
    end)

    it("should fail validation for boolean type mismatches", function()
      local rule_func = rules.eq(nil, true)

      local result, error = rule_func("true")
      assert.are.equal("true", result)
      assert.are.equal("NOT_ALLOWED_VALUE", error)
    end)

    describe("edge cases", function()
      it("should handle whitespace strings correctly", function()
        local rule_func = rules.eq(nil, "  ")

        local result, error = rule_func("  ")
        assert.are.equal("  ", result)
        assert.is_nil(error)
      end)

      it("should distinguish between empty string and whitespace", function()
        local rule_func = rules.eq(nil, "")

        local result, error = rule_func(" ")
        assert.are.equal(" ", result)
        assert.are.equal("NOT_ALLOWED_VALUE", error)
      end)

      it("should handle zero values correctly", function()
        local rule_func = rules.eq(nil, 0)

        local result, error = rule_func(0)
        assert.are.equal(0, result)
        assert.is_nil(error)
      end)

      it("should not coerce false to empty string", function()
        local rule_func = rules.eq(nil, false)

        local result, error = rule_func("")
        assert.are.equal("", result)
        assert.are.equal("NOT_ALLOWED_VALUE", error)
      end)
    end)
  end)
end)
