-- luacheck: no max line length
local WorkingVisualisations = require("factorio-mocks-generator.prototype-rules.post-processors.types.WorkingVisualisations")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.CraftingMachineGraphicsSet: factorio_mocks_generator.prototype_rules.post_processors.types.WorkingVisualisations
local CraftingMachineGraphicsSet = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function CraftingMachineGraphicsSet.process(_, rules)
  --- @type LIVR.Rule
  local new_rule = WorkingVisualisations.process(_, rules).nested_object

  return {
    nested_object = new_rule,
  }
end

return CraftingMachineGraphicsSet
