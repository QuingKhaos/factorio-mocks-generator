local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.TreeVariation: factorio_mocks_generator.prototype_rules.post_processors.types
local TreeVariation = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function TreeVariation.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Only loaded if `shadow` is present.
  new_rules.disable_shadow_distortion_beginning_at_frame = {
    ignored_if = {
      {
        shadow = "absent",
      },
      new_rules.disable_shadow_distortion_beginning_at_frame,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return TreeVariation
