insulate("[UNIT] serializer", function()
  _G.serpent = mock({
    -- luacheck: no unused args
    block = function(value, options)
      return "..."
    end
  })

  _G._TEST = true
  local serializer = require("mod.serializer")

  it("should call serpent.block()", function()
    local test_table = {key = "value"}
    serializer(test_table)

    assert.spy(_G.serpent.block --[[@as luassert.spy]]).was.called(1)
  end)

  describe("output", function()
    it("should start with 'return'", function()
      local input = {test = "value"}
      local result = serializer(input)

      assert.truthy(result:match("^return "))
    end)
  end)

  describe("flat_deep_copy", function()
    it("should handle non-table values", function()
      assert.are.equal(42, serializer.flat_deep_copy(42))
      assert.are.equal("test", serializer.flat_deep_copy("test"))
      assert.are.equal(true, serializer.flat_deep_copy(true))
      assert.are.equal(nil, serializer.flat_deep_copy(nil))
    end)

    it("should create a copy of simple tables", function()
      local original = {a = 1, b = 2}
      local copy = serializer.flat_deep_copy(original)

      assert.are_not.equal(original, copy)
      assert.are.equal(original.a, copy.a)
      assert.are.equal(original.b, copy.b)
    end)

    it("should eliminate shared references", function()
      local shared = {value = "shared"}
      local original = {
        first = shared,
        second = shared
      }

      local copy = serializer.flat_deep_copy(original)

      -- Original has shared references
      assert.are.equal(original.first, original.second)

      -- Copy should have independent references
      assert.are_not.equal(copy.first, copy.second)

      -- But the content should be the same
      assert.are.equal(copy.first.value, copy.second.value)
      assert.are.equal("shared", copy.first.value)
    end)
  end)
end)

insulate("[INTEGRATION] serializer", function()
  _G.serpent = require("serpent")
  local serializer = require("mod.serializer")

  it("should handle non-table values", function()
    local result = serializer({test = "simple"})
    assert.is_string(result)
    assert.truthy(result:match("return"))
  end)

  it("should handle simple tables", function()
    local input = {
      name = "test",
      value = 42,
      flag = true
    }

    local result = serializer(input)

    assert.is_string(result)
    assert.truthy(result:match("return"))
    assert.truthy(result:match("name"))
    assert.truthy(result:match("value"))
    assert.truthy(result:match("flag"))
  end)

  it("should handle nested tables", function()
    local input = {
      outer = {
        inner = {
          deep = "value"
        }
      }
    }

    local result = serializer(input)

    assert.is_string(result)
    assert.truthy(result:match("return"))
    assert.truthy(result:match("outer"))
  end)

  it("should handle tables with numeric keys", function()
    local input = {
      [1] = "first",
      [2] = "second",
      [10] = "tenth"
    }
    local result = serializer(input)

    assert.is_string(result)
    assert.truthy(result:match("return"))
  end)

  it("should handle mixed key types", function()
    local input = {
      string_key = "string_value",
      [42] = "numeric_value",
      [true] = "boolean_value"
    }

    local result = serializer(input)

    assert.is_string(result)
    assert.truthy(result:match("return"))
  end)

  it("should handle empty tables", function()
    local input = {}
    local result = serializer(input)

    assert.is_string(result)
    assert.truthy(result:match("return"))
  end)

  describe("options", function()
    it("should produce sorted output", function()
      local input = {
        zebra = 1,
        alpha = 2,
        beta = 3
      }

      local result = serializer(input)

      -- With sorted keys, alpha should appear before zebra
      local alpha_pos = result:find("alpha")
      local zebra_pos = result:find("zebra")

      if alpha_pos and zebra_pos then
        assert.is_true(alpha_pos < zebra_pos)
      end
    end)
  end)

  describe("deep copy behavior", function()
    it("should serialize nested tables successfully", function()
      local input = {
        shared = {nested = "original"}
      }

      local result = serializer(input)

      -- Should serialize successfully regardless of shared references
      assert.is_string(result)
      assert.truthy(result:match("shared"))
      -- Just verify it's a valid return statement, don't worry about specific content
      assert.truthy(result:match("^return "))
    end)

    it("should create independent copies without shared references", function()
      -- Create a table with actual shared references
      local shared_table = {shared_value = "test"}
      local input = {
        first_ref = shared_table,
        second_ref = shared_table,
        data = "original"
      }

      -- Verify the input actually has shared references
      assert.are.equal(input.first_ref, input.second_ref)

      local result = serializer(input)

      -- Should serialize successfully with deep copies (no shared references in output)
      assert.is_string(result)
      assert.truthy(result:match("first_ref"))
      assert.truthy(result:match("second_ref"))
      assert.truthy(result:match("data"))
      assert.truthy(result:match("^return "))

      -- Should not contain any SERPENT PLACEHOLDER
      assert.is_not_truthy(result:match("SERPENT PLACEHOLDER"))

      -- Real serpent should serialize the actual nested content
      assert.truthy(result:match("shared_value"))
    end)
  end)
end)
