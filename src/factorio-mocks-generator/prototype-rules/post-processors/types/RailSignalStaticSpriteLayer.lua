local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.RailSignalStaticSpriteLayer: factorio_mocks_generator.prototype_rules.post_processors.types
local RailSignalStaticSpriteLayer = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function RailSignalStaticSpriteLayer.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Add metadata.oneline to `align_to_frame_index`
  new_rules.align_to_frame_index[#new_rules.align_to_frame_index].metadata.oneline = true

  return {
    nested_object = new_rules,
  }
end

return RailSignalStaticSpriteLayer
