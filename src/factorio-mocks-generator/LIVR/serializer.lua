local serpent = require("serpent")
local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.LIVR.serializer
--- @field private _serpent_options table Options passed to serpent for serialization
local serializer = {}

--- Custom sorting function for serpent that sorts by __meta_order__ and unwraps values
--- @param keys table Array of keys to sort (modified in-place)
--- @param original_table table The original table being serialized
--- @private
function serializer._sortkeys_by_meta_order(keys, original_table)
  -- First: Sort the keys based on our logic
  local function compare_keys(a, b)
    local a_is_number = type(a) == "number"
    local b_is_number = type(b) == "number"

    -- Check for mixed array/object keys
    if a_is_number ~= b_is_number then
      error("Cannot mix array indices and object keys")
    end

    -- For numeric keys (arrays): sort numerically
    if a_is_number then
      return a < b
    end

    -- For string keys: check metadata consistency
    local a_value = original_table[a]
    local b_value = original_table[b]
    local a_has_order = (type(a_value) == "table" and a_value.__meta_order__ ~= nil)
    local b_has_order = (type(b_value) == "table" and b_value.__meta_order__ ~= nil)

    if a_has_order and b_has_order then
      -- Both have __meta_order__ → sort by order values
      return a_value.__meta_order__ < b_value.__meta_order__
    elseif not a_has_order and not b_has_order then
      -- Neither has __meta_order__ → alphabetical sorting
      return a < b
    else
      -- Mixed scenario → data inconsistency error
      local missing_key = a_has_order and b or a
      error("Missing __meta_order__ in property: " .. tostring(missing_key))
    end
  end

  table.sort(keys, compare_keys)

  -- Second: Clean up the original table by unwrapping values
  for key, value in pairs(original_table) do
    if type(value) == "table" then
      if value.__meta_oneline__ ~= nil then
        -- Preserve __meta_oneline__ structure (remove __meta_order__)
        original_table[key] = {__meta_oneline__ = value.__meta_oneline__, __value__ = utils.deepcopy(value.__value__)}
      elseif value.__meta_default__ ~= nil then
        -- Preserve __meta_default__ structure (remove __meta_order__)
        original_table[key] = {__meta_default__ = utils.deepcopy(value.__meta_default__)}
      elseif value.__value__ ~= nil then
        -- Unwrap __value__ content (discard __meta_order__)
        original_table[key] = utils.deepcopy(value.__value__)
      end
    end
  end
end

--- Process __DESC__ prefixed values into [[...]] format with unescaped quotes.
--- @param tag string The name of the current element with '=' or an empty string in case of array index
--- @param head string An opening table bracket `{` and associated indentation and newline (if any)
--- @param body string Table elements concatenated into a string using commas and indentation/newlines (if any)
--- @private
function serializer._meta_default_desc_processing(tag, head, body, tail)
  if string.match(body, "^__meta_default__ = \"__DESC__") then
    body = string.gsub(body, "^__meta_default__ = \"__DESC__", "__meta_default__ = [[")
    body = string.gsub(body, "\"$", "]]")

    -- Unescape double quotes since we're using [[...]] now which doesn't need escaping
    body = string.gsub(body, '\\"', '"')
  end

  return tag, head, body, tail
end

--- Custom formatter to detect __meta_default__ wrappers and render as comments.
--- @param tag string The name of the current element with '=' or an empty string in case of array index
--- @param head string An opening table bracket `{` and associated indentation and newline (if any)
--- @param body string Table elements concatenated into a string using commas and indentation/newlines (if any)
--- @param tail string A closing table bracket `}` and associated indentation and newline (if any)
--- @private
function serializer._meta_default_processing(tag, head, body, tail)
  if string.match(body, "^__meta_default__") then
    body = string.gsub(body, "^__meta_default__ = ", "")

    -- Compress content to single line
    body = string.gsub(body, "\n%s*", "")
    body = string.gsub(body, "%s+", " ")
    body = string.gsub(body, "^%s+", "")
    body = string.gsub(body, "%s+$", "")
    body = string.gsub(body, "%s*{%s*", "{")
    body = string.gsub(body, "%s*}%s*", "}")
    body = string.gsub(body, "%s*,%s*", ", ")

    -- Fix inline trailing commas added by trailing comma formatter
    body = string.gsub(body, ", }", "}")

    tag = "--" .. tag

    return tag, "", body, ""
  end

  return tag, head, body, tail
end

--- Custom formatter fix the indentation for commented default values.
--- @param tag string The name of the current element with '=' or an empty string in case of array index
--- @param head string An opening table bracket `{` and associated indentation and newline (if any)
--- @param body string Table elements concatenated into a string using commas and indentation/newlines (if any)
--- @param tail string A closing table bracket `}` and associated indentation and newline (if any)
--- @param level number The current level
--- @private
function serializer._meta_default_indentation_fix(tag, head, body, tail, level)
  if level == 0 then
    body = string.gsub(body, "  %-%-", "--")

    if string.match(body, "^%-%-") then
      head = string.gsub(head, "  $", "")
    end
  end

  return tag, head, body, tail
end

--- Custom formatter that chains all meta default related formatters.
--- @param tag string The name of the current element with '=' or an empty string in case of array index
--- @param head string An opening table bracket `{` and associated indentation and newline (if any)
--- @param body string Table elements concatenated into a string using commas and indentation/newlines (if any)
--- @param tail string A closing table bracket `}` and associated indentation and newline (if any)
--- @param level number The current level
--- @private
function serializer._meta_default_formatter(tag, head, body, tail, level)
  tag, head, body, tail = serializer._meta_default_desc_processing(tag, head, body, tail)
  tag, head, body, tail = serializer._meta_default_processing(tag, head, body, tail)
  tag, head, body, tail = serializer._meta_default_indentation_fix(tag, head, body, tail, level)

  return tag, head, body, tail
end

--- Custom formatter to detect __meta_oneline__ wrappers and render as single line.
--- @param tag string The name of the current element with '=' or an empty string in case of array index
--- @param head string An opening table bracket `{` and associated indentation and newline (if any)
--- @param body string Table elements concatenated into a string using commas and indentation/newlines (if any)
--- @param tail string A closing table bracket `}` and associated indentation and newline (if any)
--- @private
function serializer._meta_oneline_formatter(tag, head, body, tail)
  if string.match(body, "^__meta_oneline__ = true") then
    body = string.gsub(body, "^__meta_oneline__ = true,.*__value__ = ", "")

    -- Convert default values from line comments to inline comments
    body = string.gsub(body, "%-%-(.-,?)\n", "--[[%1]]")

    -- Compress to single line
    body = string.gsub(body, "\n%s*", "")
    body = string.gsub(body, "%s+", " ")
    body = string.gsub(body, "^%s+", "")
    body = string.gsub(body, "%s+$", "")
    body = string.gsub(body, "%s*{%s*", "{")
    body = string.gsub(body, "%s*}%s*", "}")
    body = string.gsub(body, "%s*,%s*", ", ")

    -- Fix spacing in inline comments after compression
    body = string.gsub(body, ", %]%]", ",]]")

    -- Merge consecutive comments
    body = string.gsub(body, "%]%] %-%-%[%[", " ")

    return tag, "", body, ""
  end

  return tag, head, body, tail
end

--- Custom formatter to add trailing commas to the last element in a table for a better git diff
--- @param tag string The name of the current element with '=' or an empty string in case of array index
--- @param head string An opening table bracket `{` and associated indentation and newline (if any)
--- @param body string Table elements concatenated into a string using commas and indentation/newlines (if any)
--- @param tail string A closing table bracket `}` and associated indentation and newline (if any)
--- @private
function serializer._trailing_comma_formatter(tag, head, body, tail)
  -- Skip tables still wrapped in `__meta_default__`, they will be compressed by meta default formatter one level higher.
  if string.match(tag, "^__meta_default__") then
    return tag, head, body, tail
  end

  -- Skip tables still wrapped in `__value__`, they will be compressed by meta oneline formatter one level higher.
  if string.match(tag, "^__value__") then
    return tag, head, body, tail
  end

  if string.match(tail, "}$") then
    tail = "," .. tail
  end

  return tag, head, body, tail
end

--- Custom formatter for serpent, chains multiple formatters if needed.
--- @param tag string The name of the current element with '=' or an empty string in case of array index
--- @param head string An opening table bracket `{` and associated indentation and newline (if any)
--- @param body string Table elements concatenated into a string using commas and indentation/newlines (if any)
--- @param tail string A closing table bracket `}` and associated indentation and newline (if any)
--- @param level number The current level
--- @private
function serializer._custom_formatter(tag, head, body, tail, level)
  tag, head, body, tail = serializer._meta_default_formatter(tag, head, body, tail, level)
  tag, head, body, tail = serializer._meta_oneline_formatter(tag, head, body, tail)
  tag, head, body, tail = serializer._trailing_comma_formatter(tag, head, body, tail)

  return tag .. head .. body .. tail
end

serializer._serpent_options = {
  indent = "  ",
  comment = false,
  sortkeys = serializer._sortkeys_by_meta_order,
  sparse = false,
  fatal = true,
  fixradix = true,
  nocode = true,
  nohuge = true,
  metatostring = false,
  numformat = "%.14g",
  custom = serializer._custom_formatter,
}

--- Function to serialize a table pretty printed
--- @param data table The table to serialize
--- @param options table? Optional serpent options to override defaults
--- @return string # A Lua code string that represents the passed table
function serializer.serialize(data, options)
  options = utils.shallow_merge(serializer._serpent_options, options or {})
  return serpent.block(data, options)
end

return serializer
