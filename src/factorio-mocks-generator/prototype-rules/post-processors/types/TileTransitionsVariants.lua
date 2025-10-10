local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.TileTransitionsVariants: factorio_mocks_generator.prototype_rules.post_processors.types
local TileTransitionsVariants = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function TileTransitionsVariants.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- luacheck: no max line length
  local empty_transitions_default = new_rules.empty_transitions[#new_rules.empty_transitions].metadata.default --[[@as boolean]]

  -- Only loaded, and mandatory if `empty_transitions` is false.
  new_rules.transition = {
    ignored_if = {
      {
        empty_transitions = {{default = empty_transitions_default}, {eq = true}},
      },
      new_rules.transition,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return TileTransitionsVariants
