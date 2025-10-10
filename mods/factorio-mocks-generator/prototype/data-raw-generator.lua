local serializer = require("__factorio-mocks-generator__.serializer")

--- Sorts the types in `data.raw` alphabetically.
--- @param data_raw data.raw
--- @return string[] # A sorted list of types.
local function sort_types(data_raw)
  local sorted_types = {}
  for type, _ in pairs(data_raw) do
    table.insert(sorted_types, type)
  end

  table.sort(sorted_types)

  return sorted_types
end

--- Splits `data.raw` into separate files for each type and generates an init file.
--- @param data_raw data.raw The `data.raw` table to process.
return function(data_raw)
  local sorted_types = sort_types(data_raw)
  local init_content = "--- @type data.raw\nreturn {\n"

  for _, type in ipairs(sorted_types) do
    helpers.write_file(
      "factorio-mocks-generator/prototype/data-raw/" .. type .. ".lua",
      serializer.serialize(data_raw[type]) .. "\n"
    )

    init_content = init_content ..
      '  ["' .. type .. '"] = require("___GENERATED__FACTORIO__DATA___.prototype.data-raw.' .. type .. '"),\n'
  end

  init_content = init_content .. "}\n"
  helpers.write_file("factorio-mocks-generator/prototype/data-raw/init.lua", init_content)
end
