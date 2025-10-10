-- luacheck: no max line length
local StatelessVisualisation = require("factorio-mocks-generator.prototype-rules.post-processors.types.StatelessVisualisation")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.PlumeEffect: factorio_mocks_generator.prototype_rules.post_processors.types.StatelessVisualisation
local PlumeEffect = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function PlumeEffect.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = StatelessVisualisation.process(_, rules).nested_object

  return {
    nested_object = new_rules,
  }
end

return PlumeEffect
