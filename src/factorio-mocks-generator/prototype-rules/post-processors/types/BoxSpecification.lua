local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.BoxSpecification: factorio_mocks_generator.prototype_rules.post_processors.types
local BoxSpecification = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function BoxSpecification.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  local is_whole_box_default = new_rules.is_whole_box[#new_rules.is_whole_box].metadata.default --[[@as boolean]]

  -- Only loaded, and mandatory if `is_whole_box` is `true`.
  new_rules.side_length = {
    ignored_if = {
      {
        is_whole_box = {{default = is_whole_box_default}, {eq = false}},
      },
      new_rules.side_length,
    }
  }

  -- Only loaded, and mandatory if `is_whole_box` is `true`.
  new_rules.side_height = {
    ignored_if = {
      {
        is_whole_box = {{default = is_whole_box_default}, {eq = false}},
      },
      new_rules.side_height,
    }
  }

  -- Only loaded, and mandatory if `is_whole_box` is `false`.
  new_rules.max_side_length = {
    ignored_if = {
      {
        is_whole_box = {{default = is_whole_box_default}, {eq = true}},
      },
      new_rules.max_side_length,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return BoxSpecification
