local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.ItemIDFilter: factorio_mocks_generator.prototype_rules.post_processors.types
local ItemIDFilter = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function ItemIDFilter.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules["or"][1].nested_object)

  -- Only loaded if `quality` is defined.
  new_rules.comparator = {
    ignored_if = {
      {
        quality = "absent",
      },
      new_rules.comparator,
    }
  }

  return {
    ["or"] = {
      {nested_object = new_rules},
      rules["or"][2],
    }
  }
end

return ItemIDFilter
