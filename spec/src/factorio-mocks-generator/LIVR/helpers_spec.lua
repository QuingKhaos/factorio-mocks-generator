insulate("[#UNIT] LIVR.helpers", function()
  local helpers = require("factorio-mocks-generator.LIVR.helpers")

  describe("is_integer", function()
    it("should return true for integer numbers", function()
      assert.is_true(helpers.is_integer(5))
      assert.is_true(helpers.is_integer(0))
      assert.is_true(helpers.is_integer(-3))
    end)

    it("should return true for whole number floats", function()
      assert.is_true(helpers.is_integer(5.0))
      assert.is_true(helpers.is_integer(-10.0))
    end)

    it("should return false for non-integer numbers", function()
      assert.is_false(helpers.is_integer(5.5))
      assert.is_false(helpers.is_integer(3.14))
      assert.is_false(helpers.is_integer(-2.7))
    end)

    it("should return false for non-numbers", function()
      assert.is_false(helpers.is_integer("5"))
      assert.is_false(helpers.is_integer(true))
      assert.is_false(helpers.is_integer({}))
      assert.is_false(helpers.is_integer(nil))
    end)
  end)

  describe("is_array", function()
    it("should return true for empty tables", function()
      assert.is_true(helpers.is_array({}))
    end)

    it("should return true for pure arrays with consecutive integer keys", function()
      assert.is_true(helpers.is_array({"a", "b", "c"}))
      assert.is_true(helpers.is_array({1, 2, 3, 4, 5}))
      assert.is_true(helpers.is_array({true, false, nil, "test"}))
    end)

    it("should return false for objects with string keys", function()
      assert.is_false(helpers.is_array({name = "test", value = 42}))
      assert.is_false(helpers.is_array({a = 1, b = 2}))
    end)

    it("should return false for mixed array-object tables", function()
      assert.is_false(helpers.is_array({"array_element", name = "test", value = 42}))
      assert.is_false(helpers.is_array({1, 2, key = "value"}))
    end)

    it("should return true for sparse arrays", function()
      local sparse = {}
      sparse[1] = "first"
      sparse[3] = "third"   -- Missing index 2
      assert.is_true(helpers.is_array(sparse))
    end)

    it("should return true for arrays with non-consecutive indices", function()
      local non_consecutive = {}
      non_consecutive[1] = "first"
      non_consecutive[2] = "second"
      non_consecutive[5] = "fifth"   -- Gap between 2 and 5
      assert.is_true(helpers.is_array(non_consecutive))
    end)

    it("should return true for arrays starting at index 0", function()
      local zero_based = {}
      zero_based[0] = "zero"
      zero_based[1] = "one"
      assert.is_true(helpers.is_array(zero_based))
    end)

    it("should return true for arrays with negative indices", function()
      local negative_indices = {}
      negative_indices[-1] = "negative"
      negative_indices[1] = "positive"
      assert.is_true(helpers.is_array(negative_indices))
    end)

    it("should return true for arrays with large integer indices", function()
      local large_indices = {}
      large_indices[1000] = "thousand"
      large_indices[1000000] = "million"
      assert.is_true(helpers.is_array(large_indices))
    end)

    it("should return true for single-element sparse arrays", function()
      local single_sparse = {}
      single_sparse[5] = "only_element"
      assert.is_true(helpers.is_array(single_sparse))
    end)
  end)

  describe("is_object", function()
    it("should return true for empty tables", function()
      assert.is_true(helpers.is_object({}))
    end)

    it("should return true for pure objects with string keys", function()
      assert.is_true(helpers.is_object({name = "test", value = 42}))
      assert.is_true(helpers.is_object({a = 1, b = 2, c = "three"}))
    end)

    it("should return false for arrays with integer keys", function()
      assert.is_false(helpers.is_object({"a", "b", "c"}))
      assert.is_false(helpers.is_object({1, 2, 3, 4, 5}))
    end)

    it("should return false for mixed array-object tables", function()
      assert.is_false(helpers.is_object({"array_element", name = "test", value = 42}))
      assert.is_false(helpers.is_object({1, 2, key = "value"}))
    end)

    it("should return false for sparse arrays", function()
      local sparse = {}
      sparse[1] = "first"
      sparse[3] = "third"
      assert.is_false(helpers.is_object(sparse))
    end)

    it("should return false for tables with any integer keys", function()
      local mixed = {name = "test"}
      mixed[1] = "first_element"
      assert.is_false(helpers.is_object(mixed))
    end)
  end)
end)
