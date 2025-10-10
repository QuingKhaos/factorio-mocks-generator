insulate("[#UNIT] LIVR.rules.numeric", function()
  local rules = require("factorio-mocks-generator.LIVR.rules.numeric")

  describe("integer", function()
    it("should create validator function", function()
      local rule_func = rules.integer()
      assert.is_function(rule_func)
    end)

    it("should pass validation for nil values", function()
      local rule_func = rules.integer()

      local result, error = rule_func(nil)
      assert.is_nil(result)
      assert.is_nil(error)
    end)

    it("should pass validation for positive integers", function()
      local rule_func = rules.integer()

      local result, error = rule_func(42)
      assert.are.equal(42, result)
      assert.is_nil(error)
    end)

    it("should pass validation for negative integers", function()
      local rule_func = rules.integer()

      local result, error = rule_func(-17)
      assert.are.equal(-17, result)
      assert.is_nil(error)
    end)

    it("should pass validation for zero", function()
      local rule_func = rules.integer()

      local result, error = rule_func(0)
      assert.are.equal(0, result)
      assert.is_nil(error)
    end)

    it("should pass validation for large integers", function()
      local rule_func = rules.integer()

      local result, error = rule_func(1000000)
      assert.are.equal(1000000, result)
      assert.is_nil(error)
    end)

    it("should pass validation for decimal numbers (accepted by Factorio)", function()
      local rule_func = rules.integer()

      local result, error = rule_func(3.14)
      assert.are.equal(3.14, result)
      assert.is_nil(error)
    end)

    it("should pass validation for small decimal numbers (accepted by Factorio)", function()
      local rule_func = rules.integer()

      local result, error = rule_func(0.5)
      assert.are.equal(0.5, result)
      assert.is_nil(error)
    end)

    it("should pass validation for negative decimals (accepted by Factorio)", function()
      local rule_func = rules.integer()

      local result, error = rule_func(-2.7)
      assert.are.equal(-2.7, result)
      assert.is_nil(error)
    end)

    it("should fail validation for empty strings", function()
      local rule_func = rules.integer()

      local result, error = rule_func("")
      assert.are.equal("", result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for strings", function()
      local rule_func = rules.integer()

      local result, error = rule_func("42")
      assert.are.equal("42", result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for booleans", function()
      local rule_func = rules.integer()

      local result, error = rule_func(true)
      assert.are.equal(true, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for tables", function()
      local rule_func = rules.integer()

      local result, error = rule_func({})
      assert.are.same({}, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    describe("edge cases", function()
      it("should handle very large integers", function()
        local rule_func = rules.integer()
        local large_int = 9007199254740991 -- Max safe integer in Lua

        local result, error = rule_func(large_int)
        assert.are.equal(large_int, result)
        assert.is_nil(error)
      end)

      it("should pass validation for infinity", function()
        local rule_func = rules.integer()

        local result, error = rule_func(math.huge)
        assert.are.equal(math.huge, result)
        assert.is_nil(error)
      end)

      it("should pass validation for negative infinity", function()
        local rule_func = rules.integer()

        local result, error = rule_func(-math.huge)
        assert.are.equal(-math.huge, result)
        assert.is_nil(error)
      end)

      it("should fail validation for NaN", function()
        local rule_func = rules.integer()
        local nan = 0 / 0

        local result, error = rule_func(nan)
        assert.is_not_nil(result)
        assert.are.equal("NOT_INTEGER", error)
      end)
    end)
  end)

  describe("decimal", function()
    it("should create validator function", function()
      local rule_func = rules.decimal()
      assert.is_function(rule_func)
    end)

    it("should pass validation for nil values", function()
      local rule_func = rules.decimal()

      local result, error = rule_func(nil)
      assert.is_nil(result)
      assert.is_nil(error)
    end)

    it("should pass validation for integers", function()
      local rule_func = rules.decimal()

      local result, error = rule_func(42)
      assert.are.equal(42, result)
      assert.is_nil(error)
    end)

    it("should pass validation for decimal numbers", function()
      local rule_func = rules.decimal()

      local result, error = rule_func(3.14)
      assert.are.equal(3.14, result)
      assert.is_nil(error)
    end)

    it("should pass validation for negative numbers", function()
      local rule_func = rules.decimal()

      local result, error = rule_func(-2.7)
      assert.are.equal(-2.7, result)
      assert.is_nil(error)
    end)

    it("should pass validation for zero", function()
      local rule_func = rules.decimal()

      local result, error = rule_func(0)
      assert.are.equal(0, result)
      assert.is_nil(error)
    end)

    it("should pass validation for zero as decimal", function()
      local rule_func = rules.decimal()

      local result, error = rule_func(0.0)
      assert.are.equal(0.0, result)
      assert.is_nil(error)
    end)

    it("should pass validation for small decimals", function()
      local rule_func = rules.decimal()

      local result, error = rule_func(0.001)
      assert.are.equal(0.001, result)
      assert.is_nil(error)
    end)

    it("should pass validation for large numbers", function()
      local rule_func = rules.decimal()

      local result, error = rule_func(1000000.123)
      assert.are.equal(1000000.123, result)
      assert.is_nil(error)
    end)

    it("should fail validation for empty strings", function()
      local rule_func = rules.decimal()

      local result, error = rule_func("")
      assert.are.equal("", result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for strings", function()
      local rule_func = rules.decimal()

      local result, error = rule_func("3.14")
      assert.are.equal("3.14", result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for booleans", function()
      local rule_func = rules.decimal()

      local result, error = rule_func(false)
      assert.are.equal(false, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for tables", function()
      local rule_func = rules.decimal()

      local result, error = rule_func({})
      assert.are.same({}, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    describe("edge cases", function()
      it("should pass validation for infinity", function()
        local rule_func = rules.decimal()

        local result, error = rule_func(math.huge)
        assert.are.equal(math.huge, result)
        assert.is_nil(error)
      end)

      it("should pass validation for negative infinity", function()
        local rule_func = rules.decimal()

        local result, error = rule_func(-math.huge)
        assert.are.equal(-math.huge, result)
        assert.is_nil(error)
      end)

      it("should fail validation for NaN", function()
        local rule_func = rules.decimal()
        local nan = 0 / 0

        local result, error = rule_func(nan)
        assert.is_not_nil(result)
        assert.are.equal("NOT_DECIMAL", error)
      end)

      it("should pass validation for very small numbers", function()
        local rule_func = rules.decimal()

        local result, error = rule_func(1e-10)
        assert.are.equal(1e-10, result)
        assert.is_nil(error)
      end)

      it("should pass validation for very large numbers", function()
        local rule_func = rules.decimal()

        local result, error = rule_func(1e10)
        assert.are.equal(1e10, result)
        assert.is_nil(error)
      end)
    end)
  end)
end)
