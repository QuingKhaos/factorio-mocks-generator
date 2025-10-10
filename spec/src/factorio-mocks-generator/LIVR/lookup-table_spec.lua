--- @diagnostic disable: invisible
insulate("[#UNIT] LIVR.lookup-table", function()
  local lookup_table = require("factorio-mocks-generator.LIVR.lookup-table")

  describe("load", function()
    after_each(function()
      lookup_table._table = nil
      lookup_table._options = {strict = false}
    end)

    it("should load valid table with prototype data", function()
      local test_data = {
        recipe = {["iron-plate"] = {}, ["copper-plate"] = {}},
        item = {["iron-ore"] = {}, ["copper-ore"] = {}}
      }

      lookup_table.load(test_data)

      assert.are.same(test_data, lookup_table._table)
    end)

    it("should overwrite existing table when called multiple times", function()
      local first_data = {
        recipe = {["iron-plate"] = {}}
      }

      local second_data = {
        item = {["iron-ore"] = {}}
      }

      lookup_table.load(first_data)
      lookup_table.load(second_data)

      assert.are.same(second_data, lookup_table._table)
    end)

    it("should accept strict parameter true", function()
      local test_data = {
        recipe = {["iron-plate"] = {}}
      }

      lookup_table.load(test_data, {strict = true})

      assert.is_true(lookup_table._options.strict)
    end)

    it("should accept strict parameter false", function()
      local test_data = {
        recipe = {["iron-plate"] = {}}
      }

      lookup_table.load(test_data, {strict = false})

      assert.is_false(lookup_table._options.strict)
    end)

    it("should default to non-strict mode when no options provided", function()
      local test_data = {
        recipe = {["iron-plate"] = {}}
      }

      lookup_table.load(test_data)

      assert.is_false(lookup_table._options.strict)
    end)

    it("should error when strict option is not a boolean", function()
      local test_data = {
        recipe = {["iron-plate"] = {}}
      }

      assert.has_error(function()
        --- @diagnostic disable-next-line: assign-type-mismatch
        lookup_table.load(test_data, {strict = "string"})
      end, "lookup-table.load: expected options.strict to be a boolean, got string")
    end)

    it("should accept empty options table", function()
      local test_data = {
        recipe = {["iron-plate"] = {}}
      }

      assert.has_no_error(function()
        lookup_table.load(test_data, {})
      end)
    end)

    it("should not be affected by mutations to passed options object", function()
      local test_data = {
        recipe = {["iron-plate"] = {}}
      }

      local options = {strict = true}
      lookup_table.load(test_data, options)

      -- Verify initial state
      assert.is_true(lookup_table._options.strict)

      -- Mutate the original options object
      options.strict = false

      -- Internal state should remain unchanged
      assert.is_true(lookup_table._options.strict)
    end)

    it("should error when table is nil", function()
      assert.has_error(function()
        --- @diagnostic disable-next-line: param-type-mismatch
        lookup_table.load(nil)
      end, "lookup-table.load: expected table, got nil")
    end)

    it("should error when table is empty", function()
      assert.has_error(function()
        lookup_table.load({})
      end, "lookup-table.load: table cannot be empty, must have at least one prototype type key")
    end)

    it("should error when parameter is not a table", function()
      assert.has_error(function()
        --- @diagnostic disable-next-line: param-type-mismatch
        lookup_table.load("string")
      end, "lookup-table.load: expected table, got string")
    end)
  end)

  describe("get", function()
    after_each(function()
      lookup_table._table = nil
      lookup_table._options = {strict = false}
    end)

    it("should return nil when no table loaded", function()
      assert.is_nil(lookup_table.get())
    end)

    it("should return loaded table", function()
      local test_data = {
        recipe = {["iron-plate"] = {}},
        item = {["iron-ore"] = {}}
      }

      lookup_table._table = test_data

      assert.are.same(test_data, lookup_table.get())
    end)

    it("should return same reference to loaded table", function()
      local test_data = {
        recipe = {["iron-plate"] = {}}
      }

      lookup_table._table = test_data

      local first_get = lookup_table.get()
      local second_get = lookup_table.get()

      assert.are.equal(first_get, second_get)
    end)
  end)

  describe("unload", function()
    after_each(function()
      lookup_table._table = nil
      lookup_table._options = {strict = false}
    end)

    it("should clear loaded table", function()
      local test_data = {
        recipe = {["iron-plate"] = {}}
      }

      lookup_table._table = test_data

      lookup_table.unload()
      assert.is_nil(lookup_table.get())
    end)

    it("should be safe to call when no table loaded", function()
      assert.has_no_error(function()
        lookup_table.unload()
      end)
    end)

    it("should be safe to call multiple times", function()
      local test_data = {
        recipe = {["iron-plate"] = {}}
      }

      lookup_table._table = test_data

      lookup_table.unload()
      lookup_table.unload()
      assert.is_nil(lookup_table.get())
    end)
  end)

  describe("opts", function()
    after_each(function()
      lookup_table._table = nil
      lookup_table._options = {strict = false}
    end)

    it("should return default options when no table loaded", function()
      local opts = lookup_table.opts()

      assert.is_table(opts)
      assert.is_false(opts.strict)
    end)

    it("should return current options after loading with strict true", function()
      local test_data = {
        recipe = {["iron-plate"] = {}}
      }

      lookup_table.load(test_data, {strict = true})
      local opts = lookup_table.opts()

      assert.is_table(opts)
      assert.is_true(opts.strict)
    end)

    it("should return current options after loading with strict false", function()
      local test_data = {
        recipe = {["iron-plate"] = {}}
      }

      lookup_table.load(test_data, {strict = false})
      local opts = lookup_table.opts()

      assert.is_table(opts)
      assert.is_false(opts.strict)
    end)

    it("should return copy not reference to internal options", function()
      local test_data = {
        recipe = {["iron-plate"] = {}}
      }

      lookup_table.load(test_data, {strict = true})
      local opts = lookup_table.opts()

      -- Modify the returned options
      opts.strict = false

      -- Internal options should remain unchanged
      local opts_after = lookup_table.opts()
      assert.is_true(opts_after.strict)
    end)

    it("should return default options after unload", function()
      local test_data = {
        recipe = {["iron-plate"] = {}}
      }

      lookup_table.load(test_data, {strict = true})
      lookup_table.unload()
      local opts = lookup_table.opts()

      assert.is_table(opts)
      assert.is_false(opts.strict)
    end)
  end)
end)
