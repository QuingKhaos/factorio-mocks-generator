local serializer = require("serializer")

--- Writse `settings` to file
--- @param settings data.Settings Struct for startup settings
--- @return nil
return function(settings)
  helpers.write_file("factorio-mocks-generator/prototype/settings.lua", serializer(settings))
end
