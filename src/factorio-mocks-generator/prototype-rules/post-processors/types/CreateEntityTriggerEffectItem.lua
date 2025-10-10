local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.CreateEntityTriggerEffectItem: factorio_mocks_generator.prototype_rules.post_processors.types
local CreateEntityTriggerEffectItem = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function CreateEntityTriggerEffectItem.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Only loaded if `find_non_colliding_position` is defined.
  new_rules.non_colliding_fail_result = {
    ignored_if = {
      {
        find_non_colliding_position = "absent"
      },
      new_rules.non_colliding_fail_result,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return CreateEntityTriggerEffectItem
