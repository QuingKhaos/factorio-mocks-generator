local serializer = require("serializer")

-- Predefined alphabetical ranges for stable splitting
local SPLIT_RANGES = {
  {"a", "d"}, -- a-d
  {"e", "h"}, -- e-h
  {"i", "l"}, -- i-l
  {"m", "p"}, -- m-p
  {"q", "t"}, -- q-t
  {"u", "z"}  -- u-z
}

--- Determines which alphabetical range a name belongs to
--- @param name string The entity name
--- @return number The range index (1-6)
local function get_range_index(name)
  local first_char = name:lower():sub(1, 1)

  for i, range in ipairs(SPLIT_RANGES) do
    if first_char >= range[1] and first_char <= range[2] then
      return i
    end
  end

  return 6  -- Default to last range for edge cases
end

--- Gets the suffix for a range index
--- @param range_index number The range index
--- @return string The file suffix
local function get_range_suffix(range_index)
  local range = SPLIT_RANGES[range_index]

  return range[1] .. "-" .. range[2]
end

--- Categories that should always be split (known large categories)
local ALWAYS_SPLIT = {
  ["assembling-machine"] = true,
  ["recipe"] = true,
  ["item"] = true,
  ["technology"] = true,
  ["mining-drill"] = true
}

--- Splits a category into fixed alphabetical ranges
--- @param category_data table The category data
--- @return table Array of {suffix, entities} pairs
local function split_by_fixed_ranges(category_data)
  local ranges = {}

  -- Initialize empty ranges
  for i = 1, #SPLIT_RANGES do
    ranges[i] = {
      suffix = get_range_suffix(i),
      entities = {}
    }
  end

  -- Distribute entities to fixed ranges
  for name, data in pairs(category_data) do
    local range_index = get_range_index(name)
    ranges[range_index].entities[name] = data
  end

  -- Only return non-empty ranges
  local non_empty_ranges = {}
  for _, range in ipairs(ranges) do
    if next(range.entities) then
      table.insert(non_empty_ranges, range)
    end
  end

  return non_empty_ranges
end

--- Sorts the types in `data.raw` alphabetically.
--- @param data_raw data.raw
--- @return string[] A sorted list of types.
local function sort_types(data_raw)
  local sorted_types = {}
  for type, _ in pairs(data_raw) do
    table.insert(sorted_types, type)
  end

  table.sort(sorted_types)
  return sorted_types
end

--- Writes an index file that requires each type file or directory.
--- @param data_raw data.raw
--- @param split_categories table Set of categories that were split
--- @return nil
local function write_index_file(data_raw, split_categories)
  local sorted_types = sort_types(data_raw)

  local content = "return {\n"
  for _, type in ipairs(sorted_types) do
    if split_categories[type] then
      -- Category was split into multiple files
      content = content .. '  ["' .. type .. '"] = require("data-raw.' .. type .. '.index"),\n'
    else
      -- Single file
      content = content .. '  ["' .. type .. '"] = require("data-raw.' .. type .. '"),\n'
    end
  end
  content = content .. "}"

  helpers.write_file("factorio-mocks-generator/prototype/data-raw.lua", content)
end

--- Writes index file for split categories
--- @param category_name string Name of the category
--- @param splits table Array of splits with their suffixes
--- @return nil
local function write_split_index(category_name, splits)
  local content = "local merged = {}\n"

  for _, split in ipairs(splits) do
    local var_name = split.suffix:gsub("-", "_")

    content = content .. "local " .. var_name ..
      " = require(\"data-raw." .. category_name .. "." .. split.suffix .. "\")\n"
  end

  content = content .. "\n"

  for _, split in ipairs(splits) do
    local var_name = split.suffix:gsub("-", "_")
    content = content .. "for name, data in pairs(" .. var_name .. ") do\n"
    content = content .. "  merged[name] = data\n"
    content = content .. "end\n"
  end

  content = content .. "\nreturn merged"

  helpers.write_file("factorio-mocks-generator/prototype/data-raw/" .. category_name .. "/index.lua", content)
end

--- Splits `data.raw` into separate files, splitting known large categories.
--- @param data_raw data.raw
--- @return table The split categories info
local function write_file_for_each_type_with_splitting(data_raw)
  local split_categories = {}

  for type, _data in pairs(data_raw) do
    if ALWAYS_SPLIT[type] then
      split_categories[type] = true

      -- Split into fixed alphabetical ranges
      local splits = split_by_fixed_ranges(_data)

      -- Write split files
      for _, split in ipairs(splits) do
        helpers.write_file(
          "factorio-mocks-generator/prototype/data-raw/" .. type .. "/" .. split.suffix .. ".lua",
          serializer(split.entities)
        )
      end

      -- Write index file that merges all splits
      write_split_index(type, splits)
    else
      -- Single file for smaller categories
      helpers.write_file("factorio-mocks-generator/prototype/data-raw/" .. type .. ".lua", serializer(_data))
    end
  end

  return split_categories
end

--- Writes `data.raw` as single files without any splitting.
--- @param data_raw data.raw
--- @return table Empty split categories info (no splits)
local function write_file_for_each_type_no_splitting(data_raw)
  for type, _data in pairs(data_raw) do
    helpers.write_file("factorio-mocks-generator/prototype/data-raw/" .. type .. ".lua", serializer(_data))
  end

  return {}  -- No categories were split
end

--- Splits `data.raw` into separate files for each type and generates an index file.
--- @param data_raw data.raw The `data.raw` table to process.
--- @param enable_splitting data.ModSetting Whether to enable stable splitting for large categories
--- @return nil
return function(data_raw, enable_splitting)
  if enable_splitting.value then
    local split_categories = write_file_for_each_type_with_splitting(data_raw)
    write_index_file(data_raw, split_categories)
  else
    local split_categories = write_file_for_each_type_no_splitting(data_raw)
    write_index_file(data_raw, split_categories)
  end
end
