local serializer = require("__factorio-mocks-generator__.serializer")

--- Writse `settings` to file
--- @param settings data.Settings Struct for startup settings
--- @return nil
return function(settings)
  helpers.write_file(
    "factorio-mocks-generator/prototype/settings.lua",
    "--- @type data.Settings\n" .. serializer.serialize(settings) .. "\n"
  )
end
