-- luacheck: no max line length
local TileTransitions = require("factorio-mocks-generator.prototype-rules.post-processors.types.TileTransitions")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.TileTransitionsBetweenTransitions: factorio_mocks_generator.prototype_rules.post_processors.types.TileTransitions
local TileTransitionsBetweenTransitions = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function TileTransitionsBetweenTransitions.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = TileTransitions.process(_, rules).nested_object

  return {
    nested_object = new_rules,
  }
end

return TileTransitionsBetweenTransitions
