local shared = require("factorio-mocks-generator.prototype-rules.post-processors.shared")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.ProbabilityTableItem: factorio_mocks_generator.prototype_rules.post_processors.types
local ProbailityTableItem = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function ProbailityTableItem.process(_, rules)
  return shared.add_metadata_oneline_to_tuple(rules)
end

return ProbailityTableItem
