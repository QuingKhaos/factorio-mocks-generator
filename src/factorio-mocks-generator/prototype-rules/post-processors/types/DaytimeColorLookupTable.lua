local shared = require("factorio-mocks-generator.prototype-rules.post-processors.shared")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.DaytimeColorLookupTable: factorio_mocks_generator.prototype_rules.post_processors.types
local DaytimeColorLookupTable = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function DaytimeColorLookupTable.process(_, rules)
  return {
    list_of = shared.add_metadata_oneline_to_tuple(rules.list_of)
  }
end

return DaytimeColorLookupTable
