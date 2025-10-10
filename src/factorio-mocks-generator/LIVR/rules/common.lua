local helpers = require("factorio-mocks-generator.LIVR.helpers")

--- @class factorio_mocks_generator.LIVR.rules.common
local rules = {}

function rules.required()
  return function(value)
    if value ~= nil then
      return value
    end

    return value, "REQUIRED"
  end
end

function rules.not_empty_list()
  return function(value)
    if value ~= nil then
      if not helpers.is_array(value) then
        return value, "FORMAT_ERROR"
      end

      if #value == 0 then
        return value, "CANNOT_BE_EMPTY"
      end
    end

    return value
  end
end

function rules.any_object()
  return function(value)
    if value ~= nil then
      if not helpers.is_object(value) then
        return value, "FORMAT_ERROR"
      end
    end

    return value
  end
end

return rules
