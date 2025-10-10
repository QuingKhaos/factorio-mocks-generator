-- luacheck: no max line length
local RollingStockPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.RollingStockPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.CargoWagonPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.RollingStockPrototype
local CargoWagonPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function CargoWagonPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = RollingStockPrototype.process(_, rules)

  return new_rules
end

return CargoWagonPrototype
