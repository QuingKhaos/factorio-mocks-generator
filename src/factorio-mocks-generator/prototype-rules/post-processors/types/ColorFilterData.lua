local helpers = require("factorio-mocks-generator.LIVR.helpers")
local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.ColorFilterData: factorio_mocks_generator.prototype_rules.post_processors.types
local ColorFilterData = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function ColorFilterData.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Add metadata.oneline to `matrix`
  for _, rule in ipairs(new_rules.matrix) do
    if helpers.is_object(rule) and rule.list_of ~= nil then
      rule.list_of = {
        rule.list_of,
        {metadata = {oneline = true}}
      }
    end
  end

  return {
    nested_object = new_rules,
  }
end

return ColorFilterData
