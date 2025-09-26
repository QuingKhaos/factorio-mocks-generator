insulate("[#UNIT] settings-generator", function()
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
        return "return {mock = 'settings'}"
      end
    )

    package.loaded["serializer"] = serializer
  end)

  after_each(function()
    _G.helpers = nil
    package.loaded["serializer"] = nil
    package.loaded["prototype.settings-generator"] = nil
  end)

  it("should write settings data to correct file path", function()
    local settings_generator = require("prototype.settings-generator")
    local real_settings = {
      startup = {
        ["enable-cranes"] = {value = false},
        ["factorio-mocks-generator-enable-stable-split"] = {value = true}
      }
    }

    settings_generator(real_settings)

    assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called_with(
      "factorio-mocks-generator/prototype/settings.lua",
      "return {mock = 'settings'}"
    )
  end)

  it("should serialize the settings data", function()
    local settings_generator = require("prototype.settings-generator")
    local real_settings = {
      startup = {
        ["future-beacons"] = {value = true},
        ["py-braided-pipes"] = {value = false},
        overload = {value = 0}
      }
    }

    settings_generator(real_settings)

    assert.spy(serializer).was.called_with(real_settings)
  end)

  it("should handle empty settings", function()
    local settings_generator = require("prototype.settings-generator")
    local empty_settings = {}

    settings_generator(empty_settings)

    assert.spy(serializer).was.called_with(empty_settings)
    assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called(1)
  end)
end)
