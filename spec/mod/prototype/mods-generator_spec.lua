insulate("[#UNIT] mods-generator", function()
  -- Extend package.path to simulate Factorio's module root behavior
  package.path = package.path .. ";./mod/?.lua;./mod/?/init.lua"

  local serializer

  before_each(function()
    _G.helpers = mock({
      -- luacheck: no unused args
      write_file = function(filename, data, append, for_player) end
    }, true)

    serializer = mock(
    -- luacheck: no unused args
      function(global)
        return "return {mock = 'mods'}"
      end
    )

    package.loaded["serializer"] = serializer
  end)

  after_each(function()
    _G.helpers = nil
    package.loaded["serializer"] = nil
    package.loaded["prototype.mods-generator"] = nil
  end)

  it("should write mods data to correct file path", function()
    local mods_generator = require("prototype.mods-generator")
    local real_mods = {
      base = "2.0.66",
      ["factorio-mocks-generator"] = "0.1.0",
      pyalienlife = "3.0.59"
    }

    mods_generator(real_mods)

    assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called_with(
      "factorio-mocks-generator/prototype/mods.lua",
      "return {mock = 'mods'}"
    )
  end)

  it("should serialize the mods data", function()
    local mods_generator = require("prototype.mods-generator")
    local real_mods = {
      base = "2.0.66",
      pycoalprocessing = "3.0.43",
      pyfusionenergy = "3.0.16"
    }

    mods_generator(real_mods)

    assert.spy(serializer).was.called_with(real_mods)
  end)

  it("should handle empty mods", function()
    local mods_generator = require("prototype.mods-generator")
    local empty_mods = {}

    mods_generator(empty_mods)

    assert.spy(serializer).was.called_with(empty_mods)
    assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called(1)
  end)
end)
