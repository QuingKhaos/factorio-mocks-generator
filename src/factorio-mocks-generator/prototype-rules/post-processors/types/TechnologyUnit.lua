local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.TechonologyUnit: factorio_mocks_generator.prototype_rules.post_processors.types
local TechonologyUnit = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function TechonologyUnit.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Either `count` or `count_formula` must be defined, never both.
  new_rules.count = {not_if = {"count_formula", new_rules.count}}
  new_rules.count_formula = {not_if = {"count", new_rules.count_formula}}

  return {
    nested_object = new_rules,
  }
end

return TechonologyUnit
