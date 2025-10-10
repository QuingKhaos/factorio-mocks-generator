insulate("[#UNIT] LIVR.rules.common", function()
  local rules = require("factorio-mocks-generator.LIVR.rules.common")

  describe("required", function()
    it("should create validator function", function()
      local rule_func = rules.required()
      assert.is_function(rule_func)
    end)

    it("should fail validation for nil values", function()
      local rule_func = rules.required()

      local result, error = rule_func(nil)
      assert.is_nil(result)
      assert.are.equal("REQUIRED", error)
    end)

    it("should pass validation for empty strings", function()
      local rule_func = rules.required()

      local result, error = rule_func("")
      assert.are.equal("", result)
      assert.is_nil(error)
    end)

    it("should pass validation for valid strings", function()
      local rule_func = rules.required()

      local result, error = rule_func("hello")
      assert.are.equal("hello", result)
      assert.is_nil(error)
    end)

    it("should pass validation for numbers", function()
      local rule_func = rules.required()

      local result, error = rule_func(42)
      assert.are.equal(42, result)
      assert.is_nil(error)
    end)

    it("should pass validation for zero", function()
      local rule_func = rules.required()

      local result, error = rule_func(0)
      assert.are.equal(0, result)
      assert.is_nil(error)
    end)

    it("should pass validation for false", function()
      local rule_func = rules.required()

      local result, error = rule_func(false)
      assert.are.equal(false, result)
      assert.is_nil(error)
    end)

    it("should pass validation for true", function()
      local rule_func = rules.required()

      local result, error = rule_func(true)
      assert.are.equal(true, result)
      assert.is_nil(error)
    end)

    it("should pass validation for empty tables", function()
      local rule_func = rules.required()

      local result, error = rule_func({})
      assert.are.same({}, result)
      assert.is_nil(error)
    end)

    it("should pass validation for tables with content", function()
      local rule_func = rules.required()
      local test_table = {key = "value"}

      local result, error = rule_func(test_table)
      assert.are.same(test_table, result)
      assert.is_nil(error)
    end)

    it("should pass validation for whitespace strings", function()
      local rule_func = rules.required()

      local result, error = rule_func("   ")
      assert.are.equal("   ", result)
      assert.is_nil(error)
    end)
  end)

  describe("any_object", function()
    it("should create validator function", function()
      local rule_func = rules.any_object()
      assert.is_function(rule_func)
    end)

    it("should pass validation for nil values", function()
      local rule_func = rules.any_object()

      local result, error = rule_func(nil)
      assert.is_nil(result)
      assert.is_nil(error)
    end)

    it("should pass validation for empty objects", function()
      local rule_func = rules.any_object()

      local result, error = rule_func({})
      assert.are.same({}, result)
      assert.is_nil(error)
    end)

    it("should pass validation for objects with string keys", function()
      local rule_func = rules.any_object()
      local test_obj = {key = "value", another = 123}

      local result, error = rule_func(test_obj)
      assert.are.same(test_obj, result)
      assert.is_nil(error)
    end)

    it("should pass validation for nested objects", function()
      local rule_func = rules.any_object()
      local test_obj = {
        outer = {
          inner = "value"
        }
      }

      local result, error = rule_func(test_obj)
      assert.are.same(test_obj, result)
      assert.is_nil(error)
    end)

    it("should fail validation for arrays (not objects)", function()
      local rule_func = rules.any_object()
      local test_array = {"item1", "item2", "item3"}

      local result, error = rule_func(test_array)
      assert.are.same(test_array, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for mixed array-object tables", function()
      local rule_func = rules.any_object()
      local test_mixed = {1, 2, key = "value"}

      local result, error = rule_func(test_mixed)
      assert.are.same(test_mixed, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for empty strings", function()
      local rule_func = rules.any_object()

      local result, error = rule_func("")
      assert.are.equal("", result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for strings", function()
      local rule_func = rules.any_object()

      local result, error = rule_func("hello")
      assert.are.equal("hello", result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for numbers", function()
      local rule_func = rules.any_object()

      local result, error = rule_func(42)
      assert.are.equal(42, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for booleans", function()
      local rule_func = rules.any_object()

      local result, error = rule_func(true)
      assert.are.equal(true, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    describe("edge cases", function()
      it("should handle objects with numeric string keys", function()
        local rule_func = rules.any_object()
        local test_obj = {["1"] = "value1", ["2"] = "value2"}

        local result, error = rule_func(test_obj)
        assert.are.same(test_obj, result)
        assert.is_nil(error)
      end)
    end)
  end)
end)
