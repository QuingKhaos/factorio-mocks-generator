local livr = require("LIVR.Validator")

--- @class factorio_mocks_generator.LIVR.rules.meta
local rules = {}

function rules.default(_, default_value)
  if type(default_value) ~= "string" and type(default_value) ~= "number" and type(default_value) ~= "boolean" then
    error("Rule [default] bad argument #1 (string, number or boolean expected)")
  end

  return function(value)
    if value == nil then
      value = default_value
    end

    return value
  end
end

return rules
