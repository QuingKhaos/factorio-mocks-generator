local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.TileMainPictures: factorio_mocks_generator.prototype_rules.post_processors.types
local TileMainPictures = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function TileMainPictures.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Add metadata.oneline to `weights`
  new_rules.weights[#new_rules.weights].metadata.oneline = true

  return {
    nested_object = new_rules,
  }
end

return TileMainPictures
