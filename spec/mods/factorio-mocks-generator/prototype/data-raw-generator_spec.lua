insulate("[#UNIT] data-raw-generator", function()
  local serializer
  local data_raw_generator

  before_each(function()
    _G.helpers = mock({
      -- luacheck: no unused args
      write_file = function(filename, data, append, for_player) end
    }, true)

    serializer = mock({
    -- luacheck: no unused args
      serialize = function(global)
        return "return {mock = 'data.raw'}"
      end
    })

    package.loaded["__factorio-mocks-generator__.serializer"] = serializer
    data_raw_generator = require("__factorio-mocks-generator__.prototype.data-raw-generator")
  end)

  after_each(function()
    _G.helpers = nil
    package.loaded["__factorio-mocks-generator__.serializer"] = nil
    package.loaded["__factorio-mocks-generator__.prototype.data-raw-generator"] = nil
  end)

  it("should write data.raw to correct file paths", function()
    local real_data = {
      item = {},
      recipe = {},
    }

    data_raw_generator(real_data)

    assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called_with(
      "factorio-mocks-generator/prototype/data-raw/item.lua",
      "return {mock = 'data.raw'}\n"
    )

    assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called_with(
      "factorio-mocks-generator/prototype/data-raw/recipe.lua",
      "return {mock = 'data.raw'}\n"
    )

    assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called_with(
      "factorio-mocks-generator/prototype/data-raw/init.lua", [[--- @type data.raw
return {
  ["item"] = require("___GENERATED__FACTORIO__DATA___.prototype.data-raw.item"),
  ["recipe"] = require("___GENERATED__FACTORIO__DATA___.prototype.data-raw.recipe"),
}
]])
  end)

  it("should serialize the data.raw data", function()
    local real_data = {
      item = {},
      recipe = {},
    }

    data_raw_generator(real_data)

    assert.spy(serializer.serialize).was.called_with(real_data.item)
    assert.spy(serializer.serialize).was.called_with(real_data.recipe)
  end)

  it("should handle empty data.raw", function()
    local empty_data = {}

    data_raw_generator(empty_data)

    assert.spy(serializer.serialize).was.called(0)
    assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called(1)
  end)
end)
