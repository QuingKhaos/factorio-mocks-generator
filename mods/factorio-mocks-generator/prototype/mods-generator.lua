local serializer = require("__factorio-mocks-generator__.serializer")

--- Writes `mods` to file
--- @param mods data.Mods List of mods
--- @return nil
return function(mods)
  helpers.write_file(
    "factorio-mocks-generator/prototype/mods.lua",
    "--- @type data.Mods\n" .. serializer.serialize(mods) .. "\n"
  )
end
