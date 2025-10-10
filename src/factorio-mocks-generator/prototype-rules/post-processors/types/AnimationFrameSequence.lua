local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.AnimationFrameSequence: factorio_mocks_generator.prototype_rules.post_processors.types
local AnimationFrameSequence = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function AnimationFrameSequence.process(_, rules)
  return {
    utils.deepcopy(rules),
    {metadata = {oneline = true}},
  }
end

return AnimationFrameSequence
