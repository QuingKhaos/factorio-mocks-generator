insulate("[UNIT] feature-flags-generator", function()
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
        return "return {mock = 'feature_flags'}"
      end
    )

    package.loaded["serializer"] = serializer
  end)

  after_each(function()
    _G.helpers = nil
    package.loaded["serializer"] = nil
    package.loaded["prototype.feature-flags-generator"] = nil
  end)

  it("should write feature flags data to correct file path", function()
    local feature_flags_generator = require("prototype.feature-flags-generator")
    local real_flags = {
      expansion_shaders = false,
      quality = false,
      space_travel = false,
      spoiling = false
    }

    feature_flags_generator(real_flags)

    assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called_with(
      "factorio-mocks-generator/prototype/feature_flags.lua",
      "return {mock = 'feature_flags'}"
    )
  end)

  it("should serialize the feature flags data", function()
    local feature_flags_generator = require("prototype.feature-flags-generator")
    local real_flags = {
      expansion_shaders = false,
      quality = false,
      space_travel = false,
      spoiling = false
    }

    feature_flags_generator(real_flags)

    assert.spy(serializer).was.called_with(real_flags)
  end)

  it("should handle empty feature flags", function()
    local feature_flags_generator = require("prototype.feature-flags-generator")
    local empty_flags = {}

    feature_flags_generator(empty_flags)

    assert.spy(serializer).was.called_with(empty_flags)
    assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called(1)
  end)
end)
