insulate("[#UNIT] LIVR.rules.custom", function()
  local rules = require("factorio-mocks-generator.LIVR.rules.custom")

  describe("unsigned_integer", function()
    it("should create validator function", function()
      local rule_func = rules.unsigned_integer()
      assert.is_function(rule_func)
    end)

    it("should pass validation for nil values", function()
      local rule_func = rules.unsigned_integer()

      local result, error = rule_func(nil)
      assert.is_nil(result)
      assert.is_nil(error)
    end)

    it("should pass validation for zero", function()
      local rule_func = rules.unsigned_integer()

      local result, error = rule_func(0)
      assert.are.equal(0, result)
      assert.is_nil(error)
    end)

    it("should pass validation for positive integers", function()
      local rule_func = rules.unsigned_integer()

      local result, error = rule_func(42)
      assert.are.equal(42, result)
      assert.is_nil(error)
    end)

    it("should fail validation for negative integers", function()
      local rule_func = rules.unsigned_integer()

      local result, error = rule_func(-5)
      assert.are.equal(-5, result)
      assert.are.equal("NOT_UNSIGNED_INTEGER", error)
    end)

    it("should pass validation for decimals (accepted by Factorio)", function()
      local rule_func = rules.unsigned_integer()

      local result, error = rule_func(3.14)
      assert.are.equal(3.14, result)
      assert.is_nil(error)
    end)

    it("should fail validation for empty strings", function()
      local rule_func = rules.unsigned_integer()

      local result, error = rule_func("")
      assert.are.equal("", result)
      assert.are.equal("FORMAT_ERROR", error)
    end)

    it("should fail validation for strings", function()
      local rule_func = rules.unsigned_integer()

      local result, error = rule_func("42")
      assert.are.equal("42", result)
      assert.are.equal("FORMAT_ERROR", error)
    end)
  end)

  describe("lookup", function()
    local lookup_table = require("factorio-mocks-generator.LIVR.lookup-table")

    it("should create validator function", function()
      local rule_func = rules.lookup(nil, "recipe")
      assert.is_function(rule_func)
    end)

    it("should pass validation when no lookup table is loaded", function()
      stub(lookup_table, "get", function() return nil end)

      local rule_func = rules.lookup(nil, "recipe")

      local result, error = rule_func("iron-plate")
      assert.are.equal("iron-plate", result)
      assert.is_nil(error)

      lookup_table.get --[[@as luassert.spy]]:revert()
    end)

    it("should pass validation for nil values", function()
      local rule_func = rules.lookup(nil, "recipe")

      local result, error = rule_func(nil)
      assert.is_nil(result)
      assert.is_nil(error)
    end)

    it("should pass validation for empty strings", function()
      local rule_func = rules.lookup(nil, "recipe")

      local result, error = rule_func("")
      assert.are.equal("", result)
      assert.is_nil(error)
    end)

    it("should validate successfully when value exists in lookup table", function()
      local mock_data = {
        recipe = {
          ["iron-plate"] = {type = "recipe", name = "iron-plate"},
          ["copper-plate"] = {type = "recipe", name = "copper-plate"}
        }
      }

      stub(lookup_table, "get", function() return mock_data end)
      stub(lookup_table, "opts", function() return {strict = false} end)

      local rule_func = rules.lookup(nil, "recipe")

      local result, error = rule_func("iron-plate")
      assert.are.equal("iron-plate", result)
      assert.is_nil(error)

      lookup_table.get --[[@as luassert.spy]]:revert()
      lookup_table.opts --[[@as luassert.spy]]:revert()
    end)

    it("should fail validation when value does not exist in lookup table", function()
      local mock_data = {
        recipe = {
          ["iron-plate"] = {type = "recipe", name = "iron-plate"}
        }
      }

      stub(lookup_table, "get", function() return mock_data end)
      stub(lookup_table, "opts", function() return {strict = false} end)

      local rule_func = rules.lookup(nil, "recipe")

      local result, error = rule_func("nonexistent-recipe")
      assert.is_nil(result)
      assert.are.equal("LOOKUP_ENTRY_NOT_FOUND", error)

      lookup_table.get --[[@as luassert.spy]]:revert()
      lookup_table.opts --[[@as luassert.spy]]:revert()
    end)

    it("should pass validation when prototype type does not exist in flexible mode", function()
      local mock_data = {
        item = {
          ["iron-ore"] = {type = "item", name = "iron-ore"}
        }
      }

      stub(lookup_table, "get", function() return mock_data end)
      stub(lookup_table, "opts", function() return {strict = false} end)

      local rule_func = rules.lookup(nil, "recipe")

      local result, error = rule_func("iron-plate")
      assert.are.equal("iron-plate", result)
      assert.is_nil(error)

      lookup_table.get --[[@as luassert.spy]]:revert()
      lookup_table.opts --[[@as luassert.spy]]:revert()
    end)

    it("should fail validation when prototype type does not exist in strict mode", function()
      local mock_data = {
        item = {
          ["iron-ore"] = {type = "item", name = "iron-ore"}
        }
      }

      stub(lookup_table, "get", function() return mock_data end)
      stub(lookup_table, "opts", function() return {strict = true} end)

      local rule_func = rules.lookup(nil, "recipe")

      local result, error = rule_func("iron-plate")
      assert.is_nil(result)
      assert.are.equal("LOOKUP_TABLE_NOT_FOUND", error)

      lookup_table.get --[[@as luassert.spy]]:revert()
      lookup_table.opts --[[@as luassert.spy]]:revert()
    end)
  end)

  describe("metadata", function()
    it("should create validator function", function()
      local rule_func = rules.metadata(nil, {default = "default_value", order = 5})
      assert.is_function(rule_func)
    end)

    describe("default value handling", function()
      it("should wrap nil values with metadata", function()
        local rule_func = rules.metadata(nil, {default = "default_value"})

        local expected = {
          result = {__meta_default__ = "default_value"},
          error = nil
        }

        local result, error = rule_func(nil)
        assert.same(expected, {result = result, error = error})
      end)

      it("should preserve empty string values", function()
        local rule_func = rules.metadata(nil, {default = "default_value"})

        local expected = {
          result = "",
          error = nil
        }

        local result, error = rule_func("")
        assert.same(expected, {result = result, error = error})
      end)

      it("should preserve existing values", function()
        local rule_func = rules.metadata(nil, {default = "existing_value"})

        local expected = {
          result = "actual_value",
          error = nil
        }

        local result, error = rule_func("actual_value")
        assert.same(expected, {result = result, error = error})
      end)

      it("should preserve zero values", function()
        local rule_func = rules.metadata(nil, {default = "default_value"})

        local expected = {
          result = 0,
          error = nil
        }

        local result, error = rule_func(0)
        assert.same(expected, {result = result, error = error})
      end)

      it("should preserve false values", function()
        local rule_func = rules.metadata(nil, {default = "default_value"})

        local expected = {
          result = false,
          error = nil
        }

        local result, error = rule_func(false)
        assert.same(expected, {result = result, error = error})
      end)

      it("should handle string default values", function()
        local string_func = rules.metadata(nil, {default = "string_default"})

        local expected = {
          result = {__meta_default__ = "string_default"},
          error = nil
        }

        local result, error = string_func(nil)
        assert.same(expected, {result = result, error = error})
      end)

      it("should handle number default values", function()
        local number_func = rules.metadata(nil, {default = 42})

        local expected = {
          result = {__meta_default__ = 42},
          error = nil
        }

        local result, error = number_func(nil)
        assert.same(expected, {result = result, error = error})
      end)

      it("should handle boolean default values", function()
        local boolean_func = rules.metadata(nil, {default = false})

        local expected = {
          result = {__meta_default__ = false},
          error = nil
        }

        local result, error = boolean_func(nil)
        assert.same(expected, {result = result, error = error})
      end)

      it("should handle table default values", function()
        local table_func = rules.metadata(nil, {default = {key = "value"}})

        local expected = {
          result = {__meta_default__ = {key = "value"}},
          error = nil
        }

        local result, error = table_func(nil)
        assert.same(expected, {result = result, error = error})
      end)
    end)

    describe("oneline handling", function()
      it("should not wrap nil values", function()
        local rule_func = rules.metadata(nil, {oneline = true})

        local expected = {
          result = nil,
          error = nil
        }

        local result, error = rule_func(nil)
        assert.same(expected, {result = result, error = error})
      end)

      it("should not wrap scalar string values", function()
        local rule_func = rules.metadata(nil, {oneline = true})

        local expected = {
          result = "test_value",
          error = nil
        }

        local result, error = rule_func("test_value")
        assert.same(expected, {result = result, error = error})
      end)

      it("should not wrap scalar number values", function()
        local rule_func = rules.metadata(nil, {oneline = true})

        local expected = {
          result = 42,
          error = nil
        }

        local result, error = rule_func(42)
        assert.same(expected, {result = result, error = error})
      end)

      it("should not wrap scalar boolean values", function()
        local rule_func = rules.metadata(nil, {oneline = true})

        local expected = {
          result = true,
          error = nil
        }

        local result, error = rule_func(true)
        assert.same(expected, {result = result, error = error})
      end)

      it("should not wrap empty tables", function()
        local rule_func = rules.metadata(nil, {oneline = true})

        local expected = {
          result = {},
          error = nil
        }

        local result, error = rule_func({})
        assert.same(expected, {result = result, error = error})
      end)

      it("should wrap non-empty object tables with oneline metadata", function()
        local rule_func = rules.metadata(nil, {oneline = true})

        local expected = {
          result = {__value__ = {key = "value"}, __meta_oneline__ = true},
          error = nil
        }

        local result, error = rule_func({key = "value"})
        assert.same(expected, {result = result, error = error})
      end)

      it("should wrap non-empty array tables with oneline metadata", function()
        local rule_func = rules.metadata(nil, {oneline = true})

        local expected = {
          result = {__value__ = {1, 2, 3}, __meta_oneline__ = true},
          error = nil
        }

        local result, error = rule_func({1, 2, 3})
        assert.same(expected, {result = result, error = error})
      end)

      it("should error if oneline parameter is not a boolean", function()
        assert.has_error(function()
          --- @diagnostic disable-next-line: assign-type-mismatch
          rules.metadata(nil, {oneline = "not_boolean"})
        end, "Rule [metadata] parameter 'oneline' must be a boolean")
      end)

      it("should not wrap values when oneline is explicitly false", function()
        local rule_func = rules.metadata(nil, {oneline = false})

        local expected = {
          result = {key = "value"},
          error = nil
        }

        local result, error = rule_func({key = "value"})
        assert.same(expected, {result = result, error = error})
      end)
    end)

    describe("order handling", function()
      it("should not wrap nil values", function()
        local rule_func = rules.metadata(nil, {order = 10})

        local expected = {
          result = nil,
          error = nil
        }

        local result, error = rule_func(nil)
        assert.same(expected, {result = result, error = error})
      end)

      it("should wrap empty string values", function()
        local rule_func = rules.metadata(nil, {order = 5})

        local expected = {
          result = {__value__ = "", __meta_order__ = 5},
          error = nil
        }

        local result, error = rule_func("")
        assert.same(expected, {result = result, error = error})
      end)

      it("should wrap existing values", function()
        local rule_func = rules.metadata(nil, {order = 3})

        local expected = {
          result = {__value__ = "actual_value", __meta_order__ = 3},
          error = nil
        }

        local result, error = rule_func("actual_value")
        assert.same(expected, {result = result, error = error})
      end)

      it("should handle zero order values", function()
        local rule_func = rules.metadata(nil, {order = 0})

        local expected = {
          result = {__value__ = "value", __meta_order__ = 0},
          error = nil
        }

        local result, error = rule_func("value")
        assert.same(expected, {result = result, error = error})
      end)

      it("should error if order parameter is not an integer", function()
        assert.has_error(function()
          --- @diagnostic disable-next-line: assign-type-mismatch
          rules.metadata(nil, {order = "not_a_number"})
        end, "Rule [metadata] parameter 'order' must be an unsigned integer")
      end)

      it("should error if order parameter is a decimal", function()
        assert.has_error(function()
          rules.metadata(nil, {order = 3.5})
        end, "Rule [metadata] parameter 'order' must be an unsigned integer")
      end)

      it("should error if order parameter is negative", function()
        assert.has_error(function()
          rules.metadata(nil, {order = -5})
        end, "Rule [metadata] parameter 'order' must be an unsigned integer")
      end)
    end)

    describe("combined handling", function()
      it("should wrap nil values with both default and order metadata", function()
        local rule_func = rules.metadata(nil, {default = "test_default", order = 15})
        local result, error = rule_func(nil)

        local expected = {
          result = {__meta_default__ = "test_default", __meta_order__ = 15},
          error = nil
        }

        assert.same(expected, {result = result, error = error})
      end)

      it("should wrap empty string values with order metadata only", function()
        local rule_func = rules.metadata(nil, {default = "empty_default", order = 25})

        local expected = {
          result = {__value__ = "", __meta_order__ = 25},
          error = nil
        }

        local result, error = rule_func("")
        assert.same(expected, {result = result, error = error})
      end)

      it("should wrap existing values with order metadata only", function()
        local rule_func = rules.metadata(nil, {default = "ignored_default", order = 99})
        local result, error = rule_func("actual_value")

        local expected = {
          result = {__value__ = "actual_value", __meta_order__ = 99},
          error = nil
        }

        assert.same(expected, {result = result, error = error})
      end)

      it("should combine oneline with order metadata for non-empty tables", function()
        local rule_func = rules.metadata(nil, {oneline = true, order = 5})

        local expected = {
          result = {__value__ = {x = 1, y = 2}, __meta_oneline__ = true, __meta_order__ = 5},
          error = nil
        }

        local result, error = rule_func({x = 1, y = 2})
        assert.same(expected, {result = result, error = error})
      end)

      it("should not add oneline to default-wrapped values for nil", function()
        local rule_func = rules.metadata(nil, {oneline = true, default = {x = 1}})

        local expected = {
          result = {__meta_default__ = {x = 1}},
          error = nil
        }

        local result, error = rule_func(nil)
        assert.same(expected, {result = result, error = error})
      end)

      it("should apply oneline wrapping for non-nil values with defaults", function()
        local rule_func = rules.metadata(nil, {oneline = true, default = "ignored"})

        local expected = {
          result = {__value__ = {a = 1}, __meta_oneline__ = true},
          error = nil
        }

        local result, error = rule_func({a = 1})
        assert.same(expected, {result = result, error = error})
      end)
    end)
  end)
end)

insulate("[#INTEGRATION] LIVR.rules.custom", function()
  local livr = require("factorio-mocks-generator.LIVR")

  describe("not_if", function()
    it("should register rule", function()
      local validator = livr.new({test = {not_if = {"other_field", "decimal"}}}):prepare()
      assert.is_function(validator.validate)
    end)

    it("should apply sub-rules when both fields are nil", function()
      local validator = livr.new({
        braking_power = {not_if = {"braking_force", {"required", "decimal"}}},
        braking_force = {not_if = {"braking_power", {"required", "decimal"}}},
      })

      local result, errors = validator:validate({})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("REQUIRED", errors.braking_power)
    end)

    it("should skip sub-rules when other field exists and current is nil", function()
      local validator = livr.new({
        braking_power = {not_if = {"braking_force", {"required", "decimal"}}},
        braking_force = {not_if = {"braking_power", {"required", "decimal"}}},
      })

      local result, errors = validator:validate({braking_force = 100})

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.is_nil(result.braking_power)
    end)

    it("should apply sub-rules when only current field exists", function()
      local validator = livr.new({
        braking_power = {not_if = {"braking_force", {"required", "decimal"}}},
        braking_force = {not_if = {"braking_power", {"required", "decimal"}}},
      })

      local result, errors = validator:validate({braking_power = 50})

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.are.equal(50, result.braking_power)
    end)

    it("should fail with XOR violation when both fields exist", function()
      local validator = livr.new({
        braking_power = {not_if = {"braking_force", {"required", "decimal"}}},
        braking_force = {not_if = {"braking_power", {"required", "decimal"}}},
      })

      local result, errors = validator:validate({braking_power = 50, braking_force = 100})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("NOT_ALLOWED", errors.braking_power)
    end)

    it("should handle query field with falsy values", function()
      local validator = livr.new({
        braking_power = {not_if = {"braking_force", {"required", "decimal"}}},
        braking_force = {not_if = {"braking_power", {"required", "decimal"}}},
      })

      local result, errors = validator:validate({braking_power = 50, braking_force = 0})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("NOT_ALLOWED", errors.braking_power)
    end)

    it("should handle condition field with false value", function()
      local validator = livr.new({
        enabled = {not_if = {"disabled", {"required", "boolean"}}},
        disabled = {not_if = {"enabled", {"required", "boolean"}}},
      })

      local result, errors = validator:validate({enabled = true, disabled = false})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("NOT_ALLOWED", errors.enabled)
    end)

    it("should handle query field with empty string", function()
      local validator = livr.new({
        name = {not_if = {"alt_name", {"required", "string"}}},
        alt_name = {not_if = {"name", {"required", "string"}}},
      })

      local result, errors = validator:validate({name = "test", alt_name = ""})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("NOT_ALLOWED", errors.name)
    end)

    it("should error when query parameter is missing", function()
      assert.has_error(function()
        livr.new({test_field = {not_if = {}}}):prepare()
      end, "Rule [not_if] bad argument #1 (string expected)")
    end)

    it("should error when sub-rules parameter is missing", function()
      assert.has_error(function()
        livr.new({test_field = {not_if = {"other_field"}}}):prepare()
      end, "Rule [not_if] bad argument #2 (string or table expected)")
    end)

    it("should error when query parameter is not a string", function()
      assert.has_error(function()
        livr.new({test_field = {not_if = {123, {"required"}}}}):prepare()
      end, "Rule [not_if] bad argument #1 (string expected)")
    end)

    it("should error when sub-rules parameter is not valid", function()
      assert.has_error(function()
        livr.new({test_field = {not_if = {"other_field", "invalid_rule"}}}):prepare()
      end, "Rule [invalid_rule] not registered")
    end)

    it("should work with complex sub-rules", function()
      local validator = livr.new({
        coordinates = {not_if = {"location", {"required", {list_of = "decimal"}}}},
        location = {not_if = {"coordinates", {"required", "string"}}},
      })

      local result, errors = validator:validate({coordinates = {1.5, 2.5, 3.0}})

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.same({1.5, 2.5, 3.0}, result.coordinates)
    end)

    it("should propagate sub-rule validation errors", function()
      local validator = livr.new({
        braking_power = {not_if = {"braking_force", {"required", "decimal"}}},
        braking_force = {not_if = {"braking_power", {"required", "decimal"}}},
      })

      -- Test invalid value that should fail decimal validation
      local result, errors = validator:validate({braking_power = "invalid_number"})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.braking_power)
    end)
  end)

  describe("ignored_if", function()
    it("should register rule", function()
      local validator = livr.new({test = {ignored_if = {"other_field", "decimal"}}}):prepare()
      assert.is_function(validator.validate)
    end)

    it("should eliminate field when other field is present", function()
      local validator = livr.new({
        actions = {list_of = "string"},
        name = {ignored_if = {"actions", {{default = "foo"}, "string"}}},
      })

      local result, errors = validator:validate({actions = {"some_action"}, name = nil})

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.is_nil(result.name) -- Field should get no default value
      assert.is_not_nil(result.actions)
    end)

    it("should apply sub-rules when other field is absent", function()
      local validator = livr.new({
        actions = {list_of = "string"},
        name = {ignored_if = {"actions", {"required", "string"}}},
      })

      local result, errors = validator:validate({name = "test_name"})

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.are.equal("test_name", result.name)
    end)

    it("should apply required validation when other field is absent", function()
      local validator = livr.new({
        actions = {list_of = "string"},
        name = {ignored_if = {"actions", {"required", "string"}}},
      })

      local result, errors = validator:validate({})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("REQUIRED", errors.name)
    end)

    it("should apply type validation when other field is absent", function()
      local validator = livr.new({
        actions = {list_of = "string"},
        name = {ignored_if = {"actions", {"required", "string"}}},
      })

      local result, errors = validator:validate({name = 123})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.name)
    end)

    it("should handle query field with falsy values", function()
      local validator = livr.new({
        actions = "boolean",
        name = {ignored_if = {"actions", {{default = "foo"}, "string"}}},
      })

      -- actions = false (falsy but not nil) should still eliminate name
      local result, errors = validator:validate({actions = false, name = nil})

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.is_nil(result.name) -- Field should get no default value
    end)

    it("should handle query field with empty string", function()
      local validator = livr.new({
        actions = "string",
        name = {ignored_if = {"actions", {{default = "foo"}, "string"}}},
      })

      -- actions = "" (falsy but not nil) should still eliminate name
      local result, errors = validator:validate({actions = "", name = nil})

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.is_nil(result.name) -- Field should get no default value
    end)

    it("should handle nil query field", function()
      local validator = livr.new({
        actions = {list_of = "string"},
        name = {ignored_if = {"actions", {"required", "string"}}},
      })

      -- actions = nil should apply normal validation to name
      local result, errors = validator:validate({actions = nil, name = "test"})

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.are.equal("test", result.name)
    end)

    it("should error when query parameter is missing", function()
      assert.has_error(function()
        livr.new({test_field = {ignored_if = {}}}):prepare()
      end, "Rule [ignored_if] bad argument #1 (string or table expected)")
    end)

    it("should error when sub-rules parameter is missing", function()
      assert.has_error(function()
        livr.new({test_field = {ignored_if = {"other_field"}}}):prepare()
      end, "Rule [ignored_if] bad argument #2 (string or table expected)")
    end)

    it("should error when query parameter is not a string", function()
      assert.has_error(function()
        livr.new({test_field = {ignored_if = {123, {"required"}}}}):prepare()
      end, "Rule [ignored_if] bad argument #1 (string or table expected)")
    end)

    it("should error when sub-rules parameter is not valid", function()
      assert.has_error(function()
        livr.new({test_field = {ignored_if = {"other_field", "invalid_rule"}}}):prepare()
      end, "Rule [invalid_rule] not registered")
    end)

    it("should work with complex sub-rules", function()
      local validator = livr.new({
        location = {list_of = "string"},
        coordinates = {ignored_if = {"location", {"required", {list_of = "decimal"}}}},
      })

      local result, errors = validator:validate({coordinates = {1.5, 2.5, 3.0}})

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.same({1.5, 2.5, 3.0}, result.coordinates)
    end)

    it("should propagate sub-rule validation errors", function()
      local validator = livr.new({
        actions = {list_of = "string"},
        frame_speed = {ignored_if = {"actions", {"required", "decimal"}}},
      })

      -- Test invalid value that should fail decimal validation
      local result, errors = validator:validate({frame_speed = "invalid_number"})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.frame_speed)
    end)
  end)

  describe("dict_of", function()
    it("should register rule", function()
      local validator = livr.new({test = {dict_of = {keys = "string", values = "integer"}}}):prepare()
      assert.is_function(validator.validate)
    end)

    it("should validate dictionary with string keys and decimal values", function()
      local schema = {
        emissions = {
          dict_of = {
            keys = "string",
            values = "decimal"
          }
        }
      }

      local validator = livr.new(schema)
      local test_data = {
        emissions = {
          pollution = 0.5,
          carbon = 1.25,
          sulfur = 0.1
        }
      }

      local result, errors = validator:validate(test_data)

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.is_table(result.emissions)
      assert.are.equal(0.5, result.emissions.pollution)
      assert.are.equal(1.25, result.emissions.carbon)
      assert.are.equal(0.1, result.emissions.sulfur)
    end)

    it("should validate dictionary with enum keys and list values", function()
      local schema = {
        directions = {
          dict_of = {
            keys = {["or"] = {{eq = "north"}, {eq = "south"}, {eq = "east"}, {eq = "west"}}},
            values = {list_of = "integer"}
          }
        }
      }

      local validator = livr.new(schema)
      local test_data = {
        directions = {
          north = {1, 2, 3},
          east = {4, 5}
        }
      }

      local result, errors = validator:validate(test_data)

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.are.same({1, 2, 3}, result.directions.north)
      assert.are.same({4, 5}, result.directions.east)
    end)

    it("should report comprehensive key validation errors", function()
      local schema = {
        directions = {
          dict_of = {
            keys = {["or"] = {{eq = "north"}, {eq = "south"}, {eq = "east"}, {eq = "west"}}},
            values = "integer"
          }
        }
      }

      local validator = livr.new(schema)
      local test_data = {
        directions = {
          north = 1,
          invalid_key = 2, -- Invalid key
          bad_key = 3      -- Another invalid key
        }
      }

      local result, errors = validator:validate(test_data)

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.is_table(errors.directions)

      -- Check key-specific errors
      assert.is_not_nil(errors.directions.invalid_key)
      assert.is_not_nil(errors.directions.invalid_key.key)
      assert.are.equal("NOT_ALLOWED_VALUE", errors.directions.invalid_key.key)

      assert.is_not_nil(errors.directions.bad_key)
      assert.is_not_nil(errors.directions.bad_key.key)
      assert.are.equal("NOT_ALLOWED_VALUE", errors.directions.bad_key.key)
    end)

    it("should report comprehensive value validation errors", function()
      local schema = {
        directions = {
          dict_of = {
            keys = "string",
            values = "integer"
          }
        }
      }

      local validator = livr.new(schema)
      local test_data = {
        directions = {
          north = 1,
          east = "invalid_value", -- Invalid value
          south = true            -- Another invalid value
        }
      }

      local result, errors = validator:validate(test_data)

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.is_table(errors.directions)

      -- Check value-specific errors
      assert.is_not_nil(errors.directions.east)
      assert.is_not_nil(errors.directions.east.value)
      assert.are.equal("FORMAT_ERROR", errors.directions.east.value)

      assert.is_not_nil(errors.directions.south)
      assert.is_not_nil(errors.directions.south.value)
      assert.are.equal("FORMAT_ERROR", errors.directions.south.value)
    end)

    it("should report both key and value errors simultaneously", function()
      local schema = {
        directions = {
          dict_of = {
            keys = {["or"] = {{eq = "north"}, {eq = "south"}, {eq = "east"}, {eq = "west"}}},
            values = "integer"
          }
        }
      }

      local validator = livr.new(schema)
      local test_data = {
        directions = {
          north = 1,                    -- Valid
          invalid_key = "invalid_value" -- Both key and value invalid
        }
      }

      local result, errors = validator:validate(test_data)

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.is_table(errors.directions)

      -- Check that both key and value errors are reported
      assert.is_not_nil(errors.directions.invalid_key)
      assert.is_not_nil(errors.directions.invalid_key.key)
      assert.is_not_nil(errors.directions.invalid_key.value)
      assert.are.equal("NOT_ALLOWED_VALUE", errors.directions.invalid_key.key)
      assert.are.equal("FORMAT_ERROR", errors.directions.invalid_key.value)
    end)

    it("should handle empty dictionaries correctly", function()
      local schema = {
        emissions = {
          dict_of = {
            keys = "string",
            values = "decimal"
          }
        }
      }

      local validator = livr.new(schema)
      local test_data = {
        emissions = {}
      }

      local result, errors = validator:validate(test_data)

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.are.same({}, result.emissions)
    end)

    it("should handle nil values for dictionaries", function()
      local schema = {
        emissions = {
          dict_of = {
            keys = "string",
            values = "decimal"
          }
        }
      }

      local validator = livr.new(schema)

      local test_data = {emissions = nil}
      local result, errors = validator:validate(test_data)
      assert.is_nil(errors)
      assert.is_nil(result.emissions)
    end)

    it("should fail validation for empty strings", function()
      local schema = {
        test_dict = {
          dict_of = {
            keys = "string",
            values = "integer"
          }
        }
      }

      local validator = livr.new(schema)
      local result, errors = validator:validate({test_dict = ""})

      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.test_dict)
    end)

    it("should fail validation for non-table inputs", function()
      local schema = {
        emissions = {
          dict_of = {
            keys = "string",
            values = "decimal"
          }
        }
      }

      local validator = livr.new(schema)
      local test_data = {
        emissions = "not a table"
      }

      local result, errors = validator:validate(test_data)

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.emissions)
    end)

    it("should fail validation for array-like tables", function()
      local schema = {
        test_dict = {
          dict_of = {
            keys = "string",
            values = "decimal"
          }
        }
      }

      local validator = livr.new(schema)
      local result, errors = validator:validate({
        test_dict = {"array_element1", "array_element2"}
      })

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.test_dict)
    end)

    it("should fail validation for mixed array-object tables", function()
      local schema = {
        test_dict = {
          dict_of = {
            keys = "string",
            values = "string"
          }
        }
      }

      local validator = livr.new(schema)
      local result, errors = validator:validate({
        test_dict = {"array_element", key = "object_value"}
      })

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.test_dict)
    end)

    it("should work with nested dict_of rules", function()
      local schema = {
        nested_emissions = {
          dict_of = {
            keys = "string",
            values = {
              dict_of = {
                keys = "string",
                values = "decimal"
              }
            }
          }
        }
      }

      local validator = livr.new(schema)
      local test_data = {
        nested_emissions = {
          factory = {
            pollution = 0.5,
            carbon = 1.25
          },
          transport = {
            fuel = 0.8
          }
        }
      }

      local result, errors = validator:validate(test_data)

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.are.equal(0.5, result.nested_emissions.factory.pollution)
      assert.are.equal(1.25, result.nested_emissions.factory.carbon)
      assert.are.equal(0.8, result.nested_emissions.transport.fuel)
    end)

    it("should fail when keys parameter is missing", function()
      assert.has_error(function()
        local schema = {
          test = {
            dict_of = {
              values = "string"
            }
          }
        }

        livr.new(schema):prepare()
      end, "Rule [dict_of] missing required parameter 'keys'")
    end)

    it("should fail when values parameter is missing", function()
      assert.has_error(function()
        local schema = {
          test = {
            dict_of = {
              keys = "string"
            }
          }
        }

        livr.new(schema):prepare()
      end, "Rule [dict_of] missing required parameter 'values'")
    end)

    it("should fail when parameter is not a table", function()
      assert.has_error(function()
        local schema = {
          test = {
            dict_of = "invalid"
          }
        }

        livr.new(schema):prepare()
      end, "Rule [dict_of] bad argument #1 (table expected)")
    end)
  end)

  describe("tuple_of rule", function()
    it("should register rule", function()
      local validator = livr.new({test = {tuple_of = {"string", "decimal"}}}):prepare()
      assert.is_function(validator.validate)
    end)

    it("should handle nil values for tuples", function()
      local schema = {
        test_tuple = {
          tuple_of = {"string", "decimal"}
        }
      }

      local validator = livr.new(schema)
      local result, error = validator:validate({
        test_tuple = nil
      })

      assert.is_nil(error)
      assert.is_nil(result.test_tuple)
    end)

    it("should validate tuples with correct types and length", function()
      local schema = {
        position = {
          tuple_of = {"string", "decimal", "boolean"}
        }
      }

      local validator = livr.new(schema)
      local result, error = validator:validate({
        position = {"north", 42.5, true}
      })

      assert.is_nil(error)
      assert.same({position = {"north", 42.5, true}}, result)
    end)

    it("should reject tuples that are too short", function()
      local schema = {
        coords = {
          tuple_of = {"decimal", "decimal"}
        }
      }

      local validator = livr.new(schema)
      local result, error = validator:validate({
        coords = {1.5}
      })

      assert.is_nil(result)
      assert.are.equal("TOO_FEW_ITEMS", error.coords)
    end)

    it("should fail validation for tuples that are too long", function()
      local schema = {
        coords = {
          tuple_of = {"decimal", "decimal"}
        }
      }

      local validator = livr.new(schema)
      local result, error = validator:validate({
        coords = {1.5, 2.5, 3.5}
      })

      assert.is_nil(result)
      assert.are.equal("TOO_MANY_ITEMS", error.coords)
    end)

    it("should validate mixed tuple with valid elements", function()
      local schema = {
        mixed_tuple = {
          tuple_of = {"string", "integer", {eq = "fixed_value"}}
        }
      }

      local validator = livr.new(schema)
      local result, error = validator:validate({
        mixed_tuple = {"text", 10, "fixed_value"}
      })

      assert.is_nil(error)
      assert.same({mixed_tuple = {"text", 10, "fixed_value"}}, result)
    end)

    it("should fail validation for empty strings", function()
      local schema = {
        test_tuple = {
          tuple_of = {"string", "decimal"}
        }
      }

      local validator = livr.new(schema)
      local result, error = validator:validate({test_tuple = ""})

      assert.is_not_nil(error)
      assert.are.equal("FORMAT_ERROR", error.test_tuple)
    end)

    it("should fail validation for non-table inputs", function()
      local schema = {
        test_tuple = {
          tuple_of = {"string", "decimal"}
        }
      }

      local validator = livr.new(schema)
      local result, error = validator:validate({
        test_tuple = "not_an_array"
      })

      assert.is_nil(result)
      assert.are.equal("FORMAT_ERROR", error.test_tuple)
    end)

    it("should fail validation for object-like tables", function()
      local schema = {
        test_tuple = {
          tuple_of = {"string", "decimal"}
        }
      }

      local validator = livr.new(schema)
      local result, error = validator:validate({
        test_tuple = {key = "value", another = "object"}
      })

      assert.is_nil(result)
      assert.are.equal("FORMAT_ERROR", error.test_tuple)
    end)

    it("should fail validation for mixed array-object tables", function()
      local schema = {
        test_tuple = {
          tuple_of = {"string", "decimal"}
        }
      }

      local validator = livr.new(schema)
      local result, error = validator:validate({
        test_tuple = {"array_element", key = "object_value"}
      })

      assert.is_nil(result)
      assert.are.equal("FORMAT_ERROR", error.test_tuple)
    end)

    it("should validate empty tuples correctly", function()
      local schema = {
        empty_tuple = {
          tuple_of = {}
        }
      }

      local validator = livr.new(schema)
      local result, error = validator:validate({
        empty_tuple = {}
      })

      assert.is_nil(error)
      assert.same({empty_tuple = {}}, result)
    end)

    it("should fail validation for non-empty arrays when expecting empty tuples", function()
      local schema = {
        empty_tuple = {
          tuple_of = {}
        }
      }

      local validator = livr.new(schema)
      local result, error = validator:validate({
        empty_tuple = {"something"}
      })

      assert.is_nil(result)
      assert.are.equal("TOO_MANY_ITEMS", error.empty_tuple)
    end)

    it("should validate complex mixed-type tuples with valid data", function()
      local schema = {
        complex_tuple = {
          tuple_of = {
            "string",
            "integer",
            {["or"] = {{eq = "option1"}, {eq = "option2"}, {eq = "option3"}}},
            "decimal"
          }
        }
      }

      local validator = livr.new(schema)
      local result, error = validator:validate({
        complex_tuple = {"text", 42, "option2", 3.14}
      })

      assert.is_nil(error)
      assert.same({complex_tuple = {"text", 42, "option2", 3.14}}, result)
    end)

    it("should fail validation for complex tuples with invalid option values", function()
      local schema = {
        complex_tuple = {
          tuple_of = {
            "string",
            "integer",
            {["or"] = {{eq = "option1"}, {eq = "option2"}, {eq = "option3"}}},
            "decimal"
          }
        }
      }

      local validator = livr.new(schema)
      local result, error = validator:validate({
        complex_tuple = {"text", 42, "invalid_option", 3.14}
      })

      assert.is_nil(result)
      assert.are.equal("NOT_ALLOWED_VALUE", error.complex_tuple[3])
    end)
  end)

  describe("lookup", function()
    local lookup_table = require("factorio-mocks-generator.LIVR.lookup-table")

    before_each(function()
      -- Load real lookup table data
      local mock_data = {
        recipe = {
          ["iron-plate"] = {type = "recipe", name = "iron-plate"},
          ["copper-plate"] = {type = "recipe", name = "copper-plate"}
        },
        item = {
          ["iron-ore"] = {type = "item", name = "iron-ore"},
          ["copper-ore"] = {type = "item", name = "copper-ore"}
        }
      }

      lookup_table.load(mock_data)
    end)

    after_each(function()
      lookup_table.unload()
    end)

    it("should register rule", function()
      local validator = livr.new({field = {lookup = "recipe"}}):prepare()
      assert.is_function(validator.validate)
    end)

    it("should validate successfully with loaded lookup table", function()
      local validator = livr.new({name = {lookup = "recipe"}})
      local result, errors = validator:validate({name = "iron-plate"})

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.are.equal("iron-plate", result.name)
    end)

    it("should fail validation with loaded lookup table", function()
      local validator = livr.new({name = {lookup = "recipe"}})
      local result, errors = validator:validate({name = "nonexistent-recipe"})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("LOOKUP_ENTRY_NOT_FOUND", errors.name)
    end)
  end)

  describe("metadata", function()
    it("should register rule", function()
      local test_rule = {
        metadata = {
          default = "default_value",
          order = 5,
        }
      }

      local validator = livr.new({field = test_rule}):prepare()
      assert.is_function(validator.validate)
    end)
  end)
end)
