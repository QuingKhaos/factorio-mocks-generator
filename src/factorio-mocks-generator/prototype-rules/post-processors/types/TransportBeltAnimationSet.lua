local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.TransportBeltAnimationSet: factorio_mocks_generator.prototype_rules.post_processors.types
local TransportBeltAnimationSet = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function TransportBeltAnimationSet.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Only loaded if `frozen_patch` is defined.
  for field, rule in pairs(new_rules) do
    if string.match(field, "_index_frozen$") then
      new_rules[field] = {
        ignored_if = {
          {frozen_patch = "absent"},
          rule,
        }
      }
    end
  end

  return {
    nested_object = new_rules,
  }
end

return TransportBeltAnimationSet
