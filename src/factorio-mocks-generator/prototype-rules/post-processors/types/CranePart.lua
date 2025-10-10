local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.CranePart: factorio_mocks_generator.prototype_rules.post_processors.types
local CranePart = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function CranePart.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Only loaded if `sprite` is not defined.
  new_rules.rotated_sprite = {
    ignored_if = {
      "sprite",
      new_rules.rotated_sprite,
    }
  }

  -- Only loaded if `sprite_shadow` is not defined.
  new_rules.rotated_sprite_shadow = {
    ignored_if = {
      "sprite_shadow",
      new_rules.rotated_sprite_shadow,
    }
  }

  -- Only loaded if `sprite_reflection` is not defined.
  new_rules.rotated_sprite_reflection = {
    ignored_if = {
      "sprite_reflection",
      new_rules.rotated_sprite_reflection,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return CranePart
