local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.TileTransitions: factorio_mocks_generator.prototype_rules.post_processors.types
local TileTransitions = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function TileTransitions.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Add metadata.oneline to `*_weights`
  for field, rule in pairs(new_rules) do
    if string.match(field, "_weights$") then
      rule[#rule].metadata.oneline = true
    end
  end

  return {
    nested_object = new_rules,
  }
end

return TileTransitions
