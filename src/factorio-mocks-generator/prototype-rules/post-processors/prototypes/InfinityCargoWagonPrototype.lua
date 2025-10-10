-- luacheck: no max line length
local CargoWagonPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.CargoWagonPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.InfinityCargoWagonPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.CargoWagonPrototype
local InfinityCargoWagonPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function InfinityCargoWagonPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = CargoWagonPrototype.process(_, rules)

  return new_rules
end

return InfinityCargoWagonPrototype
