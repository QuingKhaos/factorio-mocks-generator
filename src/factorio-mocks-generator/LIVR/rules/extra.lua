local expected_type = require("LIVR.helpers").expected_type
local helpers = require("factorio-mocks-generator.LIVR.helpers")

--- @class factorio_mocks_generator.LIVR.rules.extra
local rules = {}

function rules.boolean()
  return function(value)
    if value ~= nil then
      if type(value) ~= "boolean" then
        return value, "FORMAT_ERROR"
      end
    end

    return value
  end
end

function rules.list_length(_, min_length, max_length)
  expected_type("list_length", 1, "number", min_length)

  if max_length then
    expected_type("list_length", 2, "number", max_length)
  else
    max_length = min_length
  end

  return function(value)
    if value ~= nil then
      if not helpers.is_array(value) then
        return value, "FORMAT_ERROR"
      end

      if #value < min_length then
        return value, "TOO_FEW_ITEMS"
      end

      if #value > max_length then
        return value, "TOO_MANY_ITEMS"
      end
    end

    return value
  end
end

return rules
