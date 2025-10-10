-- luacheck: no max line length
local TreePrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.TreePrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.PlantPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.TreePrototype
local PlantPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function PlantPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = TreePrototype.process(_, rules)

  return new_rules
end

return PlantPrototype
