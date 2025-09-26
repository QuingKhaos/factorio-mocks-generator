--- Deep copy utility that completely eliminates shared references by duplicating data
--- @param original any The original data to copy
--- @return any # A deep copy with no shared references
local function _flat_deep_copy(original)
  if type(original) ~= "table" then
    return original
  end

  local copy = {}
  for key, value in pairs(original) do
    -- Recursively copy both key and value, creating completely independent copies
    copy[_flat_deep_copy(key)] = _flat_deep_copy(value)
  end

  return copy
end

--- Function to serialize a table with deep copies instead of references
--- @param global table The table to serialize
--- @return string # A Lua code string that reconstructs the table
local function serialize(global)
  local _options = {
    intent = 2,
    comment = false,
    sortkeys = true,
    sparse = false,
    fatal = true,
    nocode = true,
    metatostring = false,
    numformat = "%.17g",
  }

  return "return " .. serpent.block(_flat_deep_copy(global), _options)
end

-- luacov: disable
if _TEST then
  return setmetatable({
    flat_deep_copy = _flat_deep_copy
  }, {
    __call = function(_, global)
      return serialize(global)
    end
  })
else
  return serialize
end
-- luacov: enable
