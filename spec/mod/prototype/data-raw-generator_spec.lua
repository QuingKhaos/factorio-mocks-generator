insulate("[#UNIT] data-raw-generator", function()
  -- Extend package.path to simulate Factorio's module root behavior
  package.path = package.path .. ";./mod/?.lua;./mod/?/init.lua"

  local serializer
  local data_raw_generator

  before_each(function()
    _G.helpers = mock({
      -- luacheck: no unused args
      write_file = function(filename, data, append, for_player) end,

      -- luacheck: no unused args
      remove_path = function(path) end,
    }, true)

    serializer = mock(
      -- luacheck: no unused args
      function(global)
        return "return {mock = 'data'}"
      end
    )

    package.loaded["serializer"] = serializer
    data_raw_generator = require("prototype.data-raw-generator")
  end)

  after_each(function()
    _G.helpers = nil
    package.loaded["serializer"] = nil
    package.loaded["prototype.data-raw-generator"] = nil
  end)

  describe("without stable split enabled", function()
    local enable_stable_split = {value = false}

    it("should write each type to a separate file", function()
      local test_data_raw = {
        accumulator = {
          accumulator = {type = "accumulator", name = "accumulator"}
        },
        beacon = {
          beacon = {type = "beacon", name = "beacon"}
        }
      }

      data_raw_generator(test_data_raw, enable_stable_split)

      -- Should write individual type files
      assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called_with(
        "factorio-mocks-generator/prototype/data-raw/accumulator.lua",
        "return {mock = 'data'}"
      )
      assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called_with(
        "factorio-mocks-generator/prototype/data-raw/beacon.lua",
        "return {mock = 'data'}"
      )
    end)

    it("should write an index file", function()
      local test_data_raw = {
        accumulator = {
          accumulator = {type = "accumulator", name = "accumulator"}
        },
        beacon = {
          beacon = {type = "beacon", name = "beacon"}
        }
      }

      data_raw_generator(test_data_raw, enable_stable_split)

      -- Should write index file (check that it was called with data-raw.lua)
      local index_call_found = false
      for _, call in ipairs(helpers.write_file.calls) do
        if call.vals[1]:match("data%-raw%.lua$") then
          index_call_found = true
          break
        end
      end
      assert.is_true(index_call_found)
    end)

    it("should handle empty data.raw", function()
      local empty_data_raw = {}

      data_raw_generator(empty_data_raw, enable_stable_split)

      -- Should still write index file
      assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called(1)
    end)
  end)

  describe("with stable split enabled", function()
    local enable_stable_split = {value = true}

    it("should split large categories into ranges", function()
      local test_data_raw = {
        -- Category that is in ALWAYS_SPLIT list - will be split regardless of size
        item = {
          accumulator = {type = "item", name = "accumulator"},
          beacon = {type = "item", name = "beacon"}
        }
      }

      data_raw_generator(test_data_raw, enable_stable_split)

      -- Should write split files with range suffixes (item is in ALWAYS_SPLIT)
      local split_files_found = 0
      for _, call in ipairs(helpers.write_file.calls) do
        if call.vals[1]:match("item/[a-z]%-[a-z]%.lua$") then
          split_files_found = split_files_found + 1
        end
      end
      assert.is_true(split_files_found > 0)
    end)

    it("should not split small categories", function()
      local test_data_raw = {
        -- Categories not in ALWAYS_SPLIT - should not be split regardless of size
        accumulator = {
          accumulator = {type = "accumulator", name = "accumulator"}
        },
        beacon = {
          beacon = {type = "beacon", name = "beacon"}
        }
      }

      data_raw_generator(test_data_raw, enable_stable_split)

      -- These categories should be written as single files, not split
      local single_files_found = 0
      local split_files_found = 0
      for _, call in ipairs(helpers.write_file.calls) do
        if call.vals[1]:match("accumulator%.lua$") or call.vals[1]:match("beacon%.lua$") then
          single_files_found = single_files_found + 1
        elseif call.vals[1]:match("accumulator/[a-z]%-[a-z]%.lua$")
          or call.vals[1]:match("beacon/[a-z]%-[a-z]%.lua$") then
          split_files_found = split_files_found + 1
        end
      end

      -- Should have single files, not split files
      assert.is_true(single_files_found > 0)
      assert.are.equal(0, split_files_found)
    end)
  end)

  describe("alphabetical range splitting", function()
    it("should distribute entities to correct alphabetical ranges", function()
      -- This is testing internal logic, so we'll observe file creation patterns
      local test_data_raw = {
        -- Use 'recipe' which is in ALWAYS_SPLIT list
        recipe = {}
      }

      -- Add recipes spanning different alphabetical ranges (using real Factorio recipe names)
      local test_names = {
        "accumulator", "beacon", "copper-plate", "electric-engine-unit", "fast-inserter"
      }

      for _, name in ipairs(test_names) do
        test_data_raw.recipe[name] = {type = "recipe", name = name}
      end

      data_raw_generator(test_data_raw, {value = true})

      -- Should create range-based files for recipe (which is in ALWAYS_SPLIT)
      local range_files_found = 0
      for _, call in ipairs(helpers.write_file.calls) do
        if call.vals[1]:match("recipe/[a-z]%-[a-z]%.lua$") then
          range_files_found = range_files_found + 1
        end
      end

      -- Since we have items in different ranges, we should get multiple range files
      assert.is_true(range_files_found > 0)
    end)
  end)
end)

insulate("[#INTEGRATION] data-raw-generator", function()
  -- Extend package.path to simulate Factorio's module root behavior
  package.path = package.path .. ";./mod/?.lua;./mod/?/init.lua"
  _G.serpent = require("serpent")

  local data_raw_generator
  local written_files

  before_each(function()
    written_files = {}

    -- Set up helpers with in-memory file tracking
    _G.helpers = mock({
      -- luacheck: no unused args
      write_file = function(filename, data, append, for_player)
        if append and written_files[filename] then
          written_files[filename] = written_files[filename] .. data
        else
          written_files[filename] = data
        end
      end,

      remove_path = function(path)
        -- Remove all files whose paths start with the given path prefix
        local to_remove = {}
        for filename, _ in pairs(written_files) do
          if filename:find("^" .. path:gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1")) then
            table.insert(to_remove, filename)
          end
        end

        for _, filename in ipairs(to_remove) do
          written_files[filename] = nil
        end
      end
    })

    data_raw_generator = require("prototype.data-raw-generator")
  end)

  after_each(function()
    written_files = {}

    _G.helpers = nil
    package.loaded["prototype.data-raw-generator"] = nil
  end)

  describe("without stable split enabled", function()
    local enable_stable_split = {value = false}

    it("should generate working Lua files for simple categories", function()
      local test_data_raw = {
        accumulator = {
          accumulator = {
            type = "accumulator",
            name = "accumulator",
            energy_source = {type = "electric"}
          }
        },
        beacon = {
          beacon = {
            type = "beacon",
            name = "beacon",
            energy_usage = "480kW"
          }
        }
      }

      data_raw_generator(test_data_raw, enable_stable_split)

      -- Verify files were written with valid Lua content
      local accumulator_content = written_files["factorio-mocks-generator/prototype/data-raw/accumulator.lua"]
      local beacon_content = written_files["factorio-mocks-generator/prototype/data-raw/beacon.lua"]

      -- Check files were written
      assert.is_not_nil(accumulator_content)
      assert.is_not_nil(beacon_content)

      -- Verify content is valid Lua that returns the expected data
      assert.is_not_nil(accumulator_content:match("^return"))
      assert.is_not_nil(beacon_content:match("^return"))

      -- Test that the generated Lua is syntactically correct
      local acc_func, err = load(accumulator_content)
      assert.is_nil(err)
      assert.is_function(acc_func)

      local beacon_func, err2 = load(beacon_content)
      assert.is_nil(err2)
      assert.is_function(beacon_func)

      -- Verify data integrity
      local acc_data = acc_func and acc_func()
      if acc_data then
        assert.are.equal("accumulator", acc_data.accumulator.type)
        assert.are.equal("electric", acc_data.accumulator.energy_source.type)
      end

      local beacon_data = beacon_func and beacon_func()
      if beacon_data then
        assert.are.equal("beacon", beacon_data.beacon.type)
        assert.are.equal("480kW", beacon_data.beacon.energy_usage)
      end
    end)

    it("should generate correct index file", function()
      local test_data_raw = {
        accumulator = {acc = {type = "accumulator", name = "acc"}},
        beacon = {beacon = {type = "beacon", name = "beacon"}}
      }

      data_raw_generator(test_data_raw, enable_stable_split)

      -- Check index file content
      local index_content = written_files["factorio-mocks-generator/prototype/data-raw.lua"]
      assert.is_not_nil(index_content)

      -- Verify index file structure
      assert.is_not_nil(index_content:match('require%("data%-raw%.accumulator"%)'))
      assert.is_not_nil(index_content:match('require%("data%-raw%.beacon"%)'))
      assert.is_not_nil(index_content:match("^return"))
    end)
  end)

  describe("with stable split enabled", function()
    local enable_stable_split = {value = true}

    it("should split item category into alphabetical ranges", function()
      local test_data_raw = {
        item = {
          -- Items spanning multiple alphabetical ranges
          accumulator = {type = "item", name = "accumulator"},
          beacon = {type = "item", name = "beacon"},
          copper_plate = {type = "item", name = "copper-plate"},
          electronic_circuit = {type = "item", name = "electronic-circuit"},
          fast_inserter = {type = "item", name = "fast-inserter"},
          iron_plate = {type = "item", name = "iron-plate"}
        }
      }

      data_raw_generator(test_data_raw, enable_stable_split)

      -- Check that split files were created
      -- Verify range files exist (at least some should exist based on our test data)
      local a_d_content = written_files["factorio-mocks-generator/prototype/data-raw/item/a-d.lua"]

      -- Check a-d range (accumulator, beacon, copper_plate)
      assert.is_not_nil(a_d_content)

      -- Verify content contains expected items
      assert.is_not_nil(a_d_content:match("accumulator"))
      assert.is_not_nil(a_d_content:match("beacon"))
      assert.is_not_nil(a_d_content:match("copper.plate") or a_d_content:match("copper_plate"))

      -- Test that generated Lua is valid
      local func, err = load(a_d_content)
      assert.is_nil(err)
      local data = func and func()
      if data then
        assert.is_not_nil(data.accumulator)
        assert.is_not_nil(data.beacon)
      end
    end)

    it("should create working index file for split categories", function()
      local test_data_raw = {
        item = {
          accumulator = {type = "item", name = "accumulator"},
          fast_inserter = {type = "item", name = "fast-inserter"}
        }
      }

      data_raw_generator(test_data_raw, enable_stable_split)

      -- Check split index file
      local split_index_content = written_files["factorio-mocks-generator/prototype/data-raw/item/index.lua"]
      assert.is_not_nil(split_index_content)

      -- Verify index structure
      assert.is_not_nil(split_index_content:match("local merged"))
      assert.is_not_nil(split_index_content:match("return merged"))
      assert.is_not_nil(split_index_content:match("require.*data%-raw%.item%."))

      -- Test that index Lua is syntactically correct
      local func, err = load(split_index_content)
      assert.is_nil(err)
      assert.is_function(func)
    end)

    it("should handle mixed split and non-split categories", function()
      local test_data_raw = {
        item = { -- Will be split
          accumulator = {type = "item", name = "accumulator"}
        },
        beacon = { -- Will NOT be split
          beacon = {type = "beacon", name = "beacon"}
        }
      }

      data_raw_generator(test_data_raw, enable_stable_split)

      -- Main index should reference both correctly
      local main_index_content = written_files["factorio-mocks-generator/prototype/data-raw.lua"]
      assert.is_not_nil(main_index_content)

      -- Item should use split index, beacon should use direct file
      assert.is_not_nil(main_index_content:match('item.*require%("data%-raw%.item%.index"%)'))
      assert.is_not_nil(main_index_content:match('beacon.*require%("data%-raw%.beacon"%)'))
    end)
  end)

  describe("real-world data scenarios", function()
    it("should handle complex nested data structures", function()
      local complex_data = {
        recipe = {
          ["iron-plate"] = {
            type = "recipe",
            name = "iron-plate",
            ingredients = {{type = "item", name = "iron-ore", amount = 1}},
            results = {{type = "item", name = "iron-plate", amount = 1}},
            energy_required = 3.2,
            category = "smelting",
            enabled = true
          }
        }
      }

      data_raw_generator(complex_data, {value = true})

      -- Verify the complex data is preserved correctly
      local recipe_range_content = written_files["factorio-mocks-generator/prototype/data-raw/recipe/i-l.lua"]
      assert.is_not_nil(recipe_range_content)

      local func, err = load(recipe_range_content)
      assert.is_nil(err)

      if func then
        local data = func()
        if data["iron-plate"] then
          assert.are.equal("recipe", data["iron-plate"].type)
          assert.are.equal(3.2, data["iron-plate"].energy_required)
          assert.is_table(data["iron-plate"].ingredients)
        end
      end
    end)
  end)
end)
