local serializer = require("serializer")

--- Writes `feature_flags` to file
--- @param feature_flags data.FeatureFlags Struct for feature flags
--- @return nil
return function(feature_flags)
  helpers.write_file("factorio-mocks-generator/prototype/feature_flags.lua", serializer(feature_flags))
end
