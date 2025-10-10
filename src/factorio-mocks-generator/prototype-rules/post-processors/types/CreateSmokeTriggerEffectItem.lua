-- luacheck: no max line length
local CreateEntityTriggerEffectItem = require("factorio-mocks-generator.prototype-rules.post-processors.types.CreateEntityTriggerEffectItem")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.CreateSmokeTriggerEffectItem: factorio_mocks_generator.prototype_rules.post_processors.types.CreateEntityTriggerEffectItem
local CreateSmokeTriggerEffectItem = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function CreateSmokeTriggerEffectItem.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = CreateEntityTriggerEffectItem.process(_, rules).nested_object

  return {
    nested_object = new_rules,
  }
end

return CreateSmokeTriggerEffectItem
