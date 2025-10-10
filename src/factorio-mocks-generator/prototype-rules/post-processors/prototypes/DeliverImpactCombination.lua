local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.DeliverImpactCombination: factorio_mocks_generator.prototype_rules.post_processors.prototypes
local DeliverImpactCombination = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function DeliverImpactCombination.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules)

  -- The Factorio API accidently reference the abstract `TriggerEffectItem` instead of the concrete union type `TriggerEffect`.
  for i, rule in ipairs(new_rules.trigger_effect_item) do
    if type(rule) == "string" and rule == "TriggerEffectItem" then
      new_rules.trigger_effect_item[i] = "TriggerEffect"
    end
  end

  return new_rules
end

return DeliverImpactCombination
