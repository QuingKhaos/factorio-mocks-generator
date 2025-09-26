local serializer = require("serializer")

--- Writes `mods` to file
--- @param mods data.Mods List of mods
--- @return nil
return function(mods)
  helpers.write_file("factorio-mocks-generator/prototype/mods.lua", serializer(mods))
end
