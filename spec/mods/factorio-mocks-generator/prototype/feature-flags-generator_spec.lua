insulate("[#UNIT] feature-flags-generator", function()
  local serializer
  local feature_flags_generator

  before_each(function()
    _G.helpers = mock({
      -- luacheck: no unused args
      write_file = function(filename, data, append, for_player) end
    }, true)

    serializer = mock({
    -- luacheck: no unused args
      serialize = function(global)
        return "return {mock = 'feature_flags'}"
      end
    })

    package.loaded["__factorio-mocks-generator__.serializer"] = serializer
    feature_flags_generator = require("__factorio-mocks-generator__.prototype.feature-flags-generator")
  end)

  after_each(function()
    _G.helpers = nil
    package.loaded["__factorio-mocks-generator__.serializer"] = nil
    package.loaded["__factorio-mocks-generator__.prototype.feature-flags-generator"] = nil
  end)

  it("should write feature flags data to correct file path", function()
    local real_flags = {
      expansion_shaders = false,
      quality = false,
      space_travel = false,
      spoiling = false
    }

    feature_flags_generator(real_flags)

    assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called_with(
      "factorio-mocks-generator/prototype/feature-flags.lua",
      "--- @type data.FeatureFlags\nreturn {mock = 'feature_flags'}\n"
    )
  end)

  it("should serialize the feature flags data", function()
    local real_flags = {
      expansion_shaders = false,
      quality = false,
      space_travel = false,
      spoiling = false
    }

    feature_flags_generator(real_flags)

    assert.spy(serializer.serialize).was.called_with(real_flags)
  end)

  it("should handle empty feature flags", function()
    local empty_flags = {}

    feature_flags_generator(empty_flags)

    assert.spy(serializer.serialize).was.called_with(empty_flags)
    assert.spy(helpers.write_file --[[@as luassert.spy]]).was.called(1)
  end)
end)
