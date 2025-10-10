insulate("[#UNIT] settings-generator", function()
  local serializer
  local settings_generator

  before_each(function()
    _G.helpers = mock({
      -- luacheck: no unused args
      write_file = function(filename, data, append, for_player) end
    }, true)

    serializer = mock({
    -- luacheck: no unused args
      serialize = function(global)
        return "return {mock = 'settings'}"
      end
    })

    package.loaded["__factorio-mocks-generator__.serializer"] = serializer
    settings_generator = require("__factorio-mocks-generator__.prototype.settings-generator")
  end)

  after_each(function()
    _G.helpers = nil
    package.loaded["__factorio-mocks-generator__.serializer"] = nil
    package.loaded["__factorio-mocks-generator__.prototype.settings-generator"] = nil
  end)

  it("should write settings data to correct file path", function()
    local real_settings = {
      startup = {
        ["enable-cranes"] = {value = false},
        ["factorio-mocks-generator-enable-stable-split"] = {value = true}
      }
    }

    settings_generator(real_settings)

    assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called_with(
      "factorio-mocks-generator/prototype/settings.lua",
      "--- @type data.Settings\nreturn {mock = 'settings'}\n"
    )
  end)

  it("should serialize the settings data", function()
    local real_settings = {
      startup = {
        ["future-beacons"] = {value = true},
        ["py-braided-pipes"] = {value = false},
        overload = {value = 0}
      }
    }

    settings_generator(real_settings)

    assert.spy(serializer.serialize).was.called_with(real_settings)
  end)

  it("should handle empty settings", function()
    local empty_settings = {}

    settings_generator(empty_settings)

    assert.spy(serializer.serialize).was.called_with(empty_settings)
    assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called(1)
  end)
end)
