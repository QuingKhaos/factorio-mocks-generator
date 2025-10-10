local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.SpriteSource: factorio_mocks_generator.prototype_rules.post_processors.types
local SpriteSource = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function SpriteSource.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Loaded only when `x` and `y` are both `0`.
  new_rules.position[#new_rules.position].metadata.oneline = true
  new_rules.position = {
    ignored_if = {
      {
        x = {{default = 0}, {min_number = 1}},
        y = {{default = 0}, {min_number = 1}},
      },
      new_rules.position,
    }
  }

  new_rules.size[1]["or"][2] = {new_rules.size[1]["or"][2], {metadata = {oneline = true}}}

  return {
    nested_object = new_rules,
  }
end

return SpriteSource
