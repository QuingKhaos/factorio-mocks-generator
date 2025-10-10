local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.UnitAlternativeFrameSequence: factorio_mocks_generator.prototype_rules.post_processors.types
local UnitAlternativeFrameSequence = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function UnitAlternativeFrameSequence.process(_, rules)
  --- @type LIVR.Rule
  local new_rule = utils.deepcopy(rules.nested_object)

  for property_name, property_rules in pairs(new_rule) do
    if string.match(property_name, "frame_sequence$") then
      property_rules[#property_rules].metadata.oneline = true
    end
  end

  return {
    nested_object = new_rule,
  }
end

return UnitAlternativeFrameSequence
