--- @class factorio_mocks_generator.LIVR.helpers
local helpers = {}

--- Check if value is an integer number
--- @param value any The value to check
--- @return boolean # True if value is an integer number, false otherwise
function helpers.is_integer(value)
  if type(value) == "number" and value == math.floor(value) then
    return true
  end

  return false
end

--- Check if table has only numeric keys (pure array, dense or sparse)
--- @param value any The value to check
--- @return boolean # True if value is a table with only numeric keys or is an empty table, false otherwise
function helpers.is_array(value)
  if type(value) ~= "table" then
    return false
  end

  for key, _ in pairs(value) do
    -- If any key is not a number or not an integer, it's not an array
    if type(key) ~= "number" or not helpers.is_integer(key) then
      return false
    end
  end

  return true
end

--- Check if table is a pure object (all keys are non-integer)
--- @param value any The value to check
--- @return boolean # True if value is a table that is a pure object or is an empty table, false otherwise
function helpers.is_object(value)
  if type(value) ~= "table" then
    return false
  end

  for key, _ in pairs(value) do
    -- If any key is an integer, it's not a pure object
    if type(key) == "number" and helpers.is_integer(key) then
      return false
    end
  end

  return true
end

return helpers
