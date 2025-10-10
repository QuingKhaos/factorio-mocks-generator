local helpers = require("factorio-mocks-generator.LIVR.helpers")

--- @class factorio_mocks_generator.LIVR.rules.string
local rules = {}

function rules.string()
  return function(value)
    if value ~= nil then
      if type(value) ~= "string" then
        return value, "FORMAT_ERROR"
      end
    end

    return value
  end
end

function rules.eq(_, allowed_value)
  return function(value)
    if value ~= nil then
      -- Strict type checking - no coercion
      if value ~= allowed_value then
        return value, "NOT_ALLOWED_VALUE"
      end
    end

    return value
  end
end

function rules.one_of(_, ...)
  local allowed_values = {...}

  return function (value)
    if value ~= nil then
      if type(value) ~= "string" then
        return value, "FORMAT_ERROR"
      end

      for i = 1, #allowed_values do
        local allowed_value = allowed_values[i]
        if value == allowed_value then
          return allowed_value
        end
      end

      return value, "NOT_ALLOWED_VALUE"
    end

    return value
  end
end

return rules
