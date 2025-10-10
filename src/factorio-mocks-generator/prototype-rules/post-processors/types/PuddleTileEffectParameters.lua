local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.PuddleTileEffectParameters: factorio_mocks_generator.prototype_rules.post_processors.types
local PuddleTileEffectParameters = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function PuddleTileEffectParameters.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Only loaded, and mandatory if `water_effect_parameters` is not defined.
  new_rules.water_effect = {
    ignored_if = {
      "water_effect_parameters",
      new_rules.water_effect,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return PuddleTileEffectParameters
