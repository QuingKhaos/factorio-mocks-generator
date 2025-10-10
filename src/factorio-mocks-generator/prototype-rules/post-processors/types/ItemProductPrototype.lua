local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.ItemProductPrototype: factorio_mocks_generator.prototype_rules.post_processors.types
local ItemProductPrototype = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function ItemProductPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Only loaded, and mandatory if `amount` is not defined.
  new_rules.amount_min = {
    ignored_if = {
      "amount",
      new_rules.amount_min,
    }
  }

  -- Only loaded, and mandatory if `amount` is not defined.
  new_rules.amount_max = {
    ignored_if = {
      "amount",
      new_rules.amount_max,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return ItemProductPrototype
