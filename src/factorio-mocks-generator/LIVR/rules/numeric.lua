local expected_type = require("LIVR.helpers").expected_type
local helpers = require("factorio-mocks-generator.LIVR.helpers")

--- @class factorio_mocks_generator.LIVR.rules.numeric
local rules = {}

function rules.integer()
  return function(value)
    if value ~= nil then
      if type(value) ~= "number" then
        return value, "FORMAT_ERROR"
      end

      -- Check for NaN (NaN is the only value that doesn't equal itself)
      -- Factorio truncates decimal numbers to integers, so accept any valid number
      if value ~= value then
        return value, "NOT_INTEGER"
      end
    end

    return value
  end
end

function rules.decimal()
  return function(value)
    if value ~= nil then
      if type(value) ~= "number" then
        return value, "FORMAT_ERROR"
      end

      -- Check for NaN (NaN is the only value that doesn't equal itself)
      if value ~= value then
        return value, "NOT_DECIMAL"
      end
    end

    return value
  end
end

function rules.min_number(_, min_number)
  expected_type("min_number", 1, "number", min_number)
  return function(value)
    if value ~= nil then
      if type(value) ~= "number" then
        return value, "FORMAT_ERROR"
      end

      if value < min_number then
        return value, "TOO_LOW"
      end
    end

    return value
  end
end

return rules
