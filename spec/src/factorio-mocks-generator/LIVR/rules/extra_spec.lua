insulate("[#UNIT] LIVR.rules.extra", function()
  local rules = require("factorio-mocks-generator.LIVR.rules.extra")

  describe("boolean", function()
    it("should create validator function", function()
      local rule_func = rules.boolean()
      assert.is_function(rule_func)
    end)

    it("should pass validation for nil values", function()
      local rule_func = rules.boolean()

      local result, error = rule_func(nil)
      assert.is_nil(result)
      assert.is_nil(error)
    end)

    it("should pass validation for true", function()
      local rule_func = rules.boolean()

      local result, error = rule_func(true)
      assert.are.equal(true, result)
      assert.is_nil(error)
    end)

    it("should pass validation for false", function()
      local rule_func = rules.boolean()

      local result, error = rule_func(false)
      assert.are.equal(false, result)
      assert.is_nil(error)
    end)

    it("should fail validation for empty strings", function()
      local rule_func = rules.boolean()

      local result, error = rule_func("")
      assert.are.equal("", result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for strings", function()
      local rule_func = rules.boolean()

      local result, error = rule_func("true")
      assert.are.equal("true", result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for numbers", function()
      local rule_func = rules.boolean()

      local result, error = rule_func(1)
      assert.are.equal(1, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for zero", function()
      local rule_func = rules.boolean()

      local result, error = rule_func(0)
      assert.are.equal(0, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for tables", function()
      local rule_func = rules.boolean()

      local result, error = rule_func({})
      assert.are.same({}, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)
  end)

  describe("list_length", function()
    it("should create validator function with single length parameter", function()
      local rule_func = rules.list_length(nil, 3)
      assert.is_function(rule_func)
    end)

    it("should create validator function with min and max length parameters", function()
      local rule_func = rules.list_length(nil, 2, 5)
      assert.is_function(rule_func)
    end)

    it("should pass validation for nil values", function()
      local rule_func = rules.list_length(nil, 3)

      local result, error = rule_func(nil)
      assert.is_nil(result)
      assert.is_nil(error)
    end)

    it("should pass validation for arrays with exact length", function()
      local rule_func = rules.list_length(nil, 3)
      local test_array = {"a", "b", "c"}

      local result, error = rule_func(test_array)
      assert.are.same(test_array, result)
      assert.is_nil(error)
    end)

    it("should pass validation for arrays within min-max range", function()
      local rule_func = rules.list_length(nil, 2, 4)
      local test_array = {"a", "b", "c"}

      local result, error = rule_func(test_array)
      assert.are.same(test_array, result)
      assert.is_nil(error)
    end)

    it("should pass validation for arrays at min boundary", function()
      local rule_func = rules.list_length(nil, 2, 4)
      local test_array = {"a", "b"}

      local result, error = rule_func(test_array)
      assert.are.same(test_array, result)
      assert.is_nil(error)
    end)

    it("should pass validation for arrays at max boundary", function()
      local rule_func = rules.list_length(nil, 2, 4)
      local test_array = {"a", "b", "c", "d"}

      local result, error = rule_func(test_array)
      assert.are.same(test_array, result)
      assert.is_nil(error)
    end)

    it("should fail validation for arrays too short", function()
      local rule_func = rules.list_length(nil, 3)
      local test_array = {"a", "b"}

      local result, error = rule_func(test_array)
      assert.are.same(test_array, result)
      assert.are.equal("TOO_FEW_ITEMS", error)
    end)

    it("should fail validation for arrays too long", function()
      local rule_func = rules.list_length(nil, 3)
      local test_array = {"a", "b", "c", "d"}

      local result, error = rule_func(test_array)
      assert.are.same(test_array, result)
      assert.are.equal("TOO_MANY_ITEMS", error)
    end)

    it("should fail validation for arrays below min range", function()
      local rule_func = rules.list_length(nil, 3, 5)
      local test_array = {"a", "b"}

      local result, error = rule_func(test_array)
      assert.are.same(test_array, result)
      assert.are.equal("TOO_FEW_ITEMS", error)
    end)

    it("should fail validation for arrays above max range", function()
      local rule_func = rules.list_length(nil, 3, 5)
      local test_array = {"a", "b", "c", "d", "e", "f"}

      local result, error = rule_func(test_array)
      assert.are.same(test_array, result)
      assert.are.equal("TOO_MANY_ITEMS", error)
    end)

    it("should fail validation for empty strings", function()
      local rule_func = rules.list_length(nil, 3)

      local result, error = rule_func("")
      assert.are.equal("", result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for non-tables", function()
      local rule_func = rules.list_length(nil, 3)

      local result, error = rule_func("hello")
      assert.are.equal("hello", result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for objects (not arrays)", function()
      local rule_func = rules.list_length(nil, 3)
      local test_object = {key = "value", another = "test"}

      local result, error = rule_func(test_object)
      assert.are.same(test_object, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for mixed array-object tables", function()
      local rule_func = rules.list_length(nil, 3)
      local test_mixed = {1, 2, key = "value"}

      local result, error = rule_func(test_mixed)
      assert.are.same(test_mixed, result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should pass validation for empty arrays when min length is 0", function()
      local rule_func = rules.list_length(nil, 0, 2)
      local test_array = {}

      local result, error = rule_func(test_array)
      assert.are.same(test_array, result)
      assert.is_nil(error)
    end)

    it("should fail validation for empty arrays when min length > 0", function()
      local rule_func = rules.list_length(nil, 1)
      local test_array = {}

      local result, error = rule_func(test_array)
      assert.are.same(test_array, result)
      assert.are.equal("TOO_FEW_ITEMS", error)
    end)

    describe("edge cases", function()
      it("should handle arrays with mixed value types", function()
        local rule_func = rules.list_length(nil, 3)
        local test_array = {"string", 42, true}

        local result, error = rule_func(test_array)
        assert.are.same(test_array, result)
        assert.is_nil(error)
      end)

      it("should handle arrays with nil values", function()
        local rule_func = rules.list_length(nil, 3)
        local test_array = {"a", nil, "c"}

        local result, error = rule_func(test_array)
        assert.are.same(test_array, result)
        assert.is_nil(error)
      end)

      it("should use min as max when max is not specified", function()
        local rule_func = rules.list_length(nil, 3)
        local test_array = {"a", "b", "c", "d"}

        local result, error = rule_func(test_array)
        assert.are.same(test_array, result)
        assert.are.equal("TOO_MANY_ITEMS", error)
      end)
    end)
  end)
end)
