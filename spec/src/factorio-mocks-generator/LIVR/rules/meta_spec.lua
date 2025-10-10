insulate("[#INTEGRATION] LIVR.rules.meta", function()
  local livr = require("factorio-mocks-generator.LIVR")

  describe("nested_object", function()
    it("should register rule", function()
      local validator = livr.new({test = {nested_object = {name = "string", value = "decimal"}}}):prepare()
      assert.is_function(validator.validate)
    end)

    it("should validate object-like tables successfully", function()
      local schema = {
        config = {
          nested_object = {
            name = "string",
            value = "decimal",
            enabled = "boolean"
          }
        }
      }

      local validator = livr.new(schema)
      local result, errors = validator:validate({
        config = {name = "test_config", value = 42.5, enabled = true}
      })

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.are.equal("test_config", result.config.name)
      assert.are.equal(42.5, result.config.value)
      assert.are.equal(true, result.config.enabled)
    end)

    it("should handle nil values", function()
      local schema = {
        config = {
          nested_object = {
            name = "string",
            value = "decimal"
          }
        }
      }

      local validator = livr.new(schema)
      local result, errors = validator:validate({
        config = nil
      })

      assert.is_nil(errors)
      assert.is_nil(result.config)
    end)

    it("should fail validation for empty strings", function()
      local schema = {
        config = {
          nested_object = {
            name = "string",
            value = "decimal"
          }
        }
      }

      local validator = livr.new(schema)
      local result, errors = validator:validate({config = ""})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.config)
    end)

    it("should fail validation for non-tables", function()
      local schema = {
        config = {
          nested_object = {
            name = "string",
            value = "decimal"
          }
        }
      }

      local validator = livr.new(schema)
      local result, errors = validator:validate({config = "not a table"})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.config)
    end)

    it("should fail validation for array-like tables", function()
      local schema = {
        config = {
          nested_object = {
            name = "string",
            value = "decimal"
          }
        }
      }

      local validator = livr.new(schema)
      local result, errors = validator:validate({
        config = {"array_element1", "array_element2", "array_element3"}
      })

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.config)
    end)

    it("should fail validation for mixed array-object tables", function()
      local schema = {
        config = {
          nested_object = {
            name = "string",
            value = "decimal"
          }
        }
      }

      local validator = livr.new(schema)
      local result, errors = validator:validate({
        config = {"array_element", name = "test_config", value = 42.5}
      })

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.config)
    end)
  end)

  describe("list_of", function()
    it("should register rule", function()
      local validator = livr.new({items = {list_of = "string"}}):prepare()
      assert.is_function(validator.validate)
    end)

    it("should validate arrays of strings", function()
      local validator = livr.new({items = {list_of = "string"}})
      local result, errors = validator:validate({items = {"test1", "test2", "test3"}})

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.is_table(result.items)
      assert.are.equal(3, #result.items)
      assert.are.equal("test1", result.items[1])
      assert.are.equal("test2", result.items[2])
      assert.are.equal("test3", result.items[3])
    end)

    it("should handle nil values", function()
      local validator = livr.new({items = {list_of = "string"}})
      local result, errors = validator:validate({items = nil})

      assert.is_nil(errors)
      assert.is_not_nil(result)
      assert.is_nil(result.items)
    end)

    it("should fail validation for empty strings", function()
      local validator = livr.new({items = {list_of = "string"}})
      local result, errors = validator:validate({items = ""})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.items)
    end)

    it("should fail validation for non-tables", function()
      local validator = livr.new({items = {list_of = "string"}})
      local result, errors = validator:validate({items = "not a table"})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.items)
    end)

    it("should fail validation for object-like tables", function()
      local validator = livr.new({items = {list_of = "string"}})
      local result, errors = validator:validate({items = {key = "value", another = "object"}})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.items)
    end)

    it("should fail validation for mixed array-object tables", function()
      local validator = livr.new({items = {list_of = "string"}})
      local result, errors = validator:validate({items = {"array_element", key = "object_value"}})

      assert.is_nil(result)
      assert.is_not_nil(errors)
      assert.are.equal("FORMAT_ERROR", errors.items)
    end)
  end)
end)
