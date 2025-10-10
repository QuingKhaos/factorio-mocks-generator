-- luacheck: no max line length
local CraftingMachinePrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.CraftingMachinePrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.AssemblingMachinePrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.CraftingMachinePrototype
local AssemblingMachinePrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function AssemblingMachinePrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = CraftingMachinePrototype.process(_, rules)

  return new_rules
end

return AssemblingMachinePrototype
