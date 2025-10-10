local utils = require("factorio-mocks-generator.utils")
-- luacheck: no max line length
local TransportBeltAnimationSet = require("factorio-mocks-generator.prototype-rules.post-processors.types.TransportBeltAnimationSet")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.TransportBeltAnimationSetWithCorners: factorio_mocks_generator.prototype_rules.post_processors.types.TransportBeltAnimationSet
local TransportBeltAnimationSetWithCorners = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function TransportBeltAnimationSetWithCorners.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = TransportBeltAnimationSet.process(_, rules).nested_object

  return {
    nested_object = new_rules,
  }
end

return TransportBeltAnimationSetWithCorners
