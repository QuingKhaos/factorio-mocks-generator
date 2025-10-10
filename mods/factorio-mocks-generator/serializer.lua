--- @class factioro_mocks_generator.serializer
local serializer = {}

--- Deep copy utility that completely eliminates shared references by duplicating data
--- @param original any The original data to copy
--- @return any # A deep copy with no shared references
function serializer._flat_deep_copy(original)
  if type(original) ~= "table" then
    return original
  end

  local copy = {}
  for key, value in pairs(original) do
    -- Recursively copy both key and value, creating completely independent copies
    copy[serializer._flat_deep_copy(key)] = serializer._flat_deep_copy(value)
  end

  return copy
end

--- Function to serialize a table with deep copies instead of references
--- @param global table The table to serialize
--- @return string # A Lua code string that reconstructs the table
function serializer.serialize(global)
  local _options = {
    indent = "  ",
    comment = false,
    sortkeys = true,
    sparse = false,
    fatal = true,
    fixradix = true,
    nocode = true,
    nohuge = true,
    metatostring = false,
    numformat = "%.17g",
  }

  return "return " .. serpent.block(serializer._flat_deep_copy(global), _options)
end

return serializer
