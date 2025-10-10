local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.StatelessVisualisation: factorio_mocks_generator.prototype_rules.post_processors.types
local StatelessVisualisation = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function StatelessVisualisation.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Only loaded if `animation` is defined.
  new_rules.shadow = {
    ignored_if = {
      {
        animation = "absent",
      },
      new_rules.shadow,
    }
  }

  -- Only loaded if `count` is not defined.
  new_rules.min_count = {
    ignored_if = {
      "count",
      new_rules.min_count,
    }
  }

  -- Only loaded if `count` is not defined.
  new_rules.max_count = {
    ignored_if = {
      "count",
      new_rules.max_count,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return StatelessVisualisation
