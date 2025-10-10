--- @class factorio_mocks_generator.utils
local utils = {}

--- Converts a string from CamelCase to SNAKE_CASE
--- @param str string The CamelCase string to convert
--- @return string snake_case The converted SNAKE_CASE string
function utils.camel_to_snake_case(str)
  -- Replace hyphens with underscores first
  local result = string.gsub(str, "%-", "_")

  -- Insert underscore before uppercase letters (but not at the beginning)
  result = string.gsub(result, "(%l)(%u)", "%1_%2")

  -- Insert underscore before digits (treat digits like word boundaries)
  result = string.gsub(result, "(%l)(%d)", "%1_%2")

  -- Insert underscore after digits, but only before multi-character words
  -- This handles "4Way" -> "4_Way" but keeps "4f", "3D" together
  result = string.gsub(result, "(%d)(%u%l+)", "%1_%2")

  return string.upper(result)
end

--- Merges two tables shallowly, with values from `override` taking precedence.
--- @param base table Base table
--- @param override table Override table
--- @return table Merged table
function utils.shallow_merge(base, override)
  override = override or {}
  local result = {}

  for k, v in pairs(base) do
    result[k] = v
  end

  for k, v in pairs(override) do
    result[k] = v
  end

  return result
end

--- Deep copies a table, handling nested tables and avoiding cycles.
--- @generic T : any
--- @param object T The object to deep copy
--- @return T # The deep copied object
function utils.deepcopy(object)
  local lookup_table = {}
  local function _copy(_object)
    if type(_object) ~= "table" then
      return _object
    elseif lookup_table[_object] then
      return lookup_table[_object]
    end

    local new_table = {}
    lookup_table[_object] = new_table
    for index, value in pairs(_object) do
      new_table[_copy(index)] = _copy(value)
    end

    return setmetatable(new_table, getmetatable(_object))
  end

  return _copy(object)
end

function utils.table_keys(t)
  local keys = {}
  for k, _ in pairs(t) do
    table.insert(keys, k)
  end

  table.sort(keys)
  return keys
end

return utils
