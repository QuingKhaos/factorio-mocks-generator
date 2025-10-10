local serializer = require("__factorio-mocks-generator__.serializer")

--- Writes `feature_flags` to file
--- @param feature_flags data.FeatureFlags Struct for feature flags
return function(feature_flags)
  helpers.write_file(
    "factorio-mocks-generator/prototype/feature-flags.lua",
    "--- @type data.FeatureFlags\n" .. serializer.serialize(feature_flags) .. "\n"
  )
end
