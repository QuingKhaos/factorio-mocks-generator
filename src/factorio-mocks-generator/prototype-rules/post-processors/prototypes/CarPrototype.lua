-- luacheck: no max line length
local VehiclePrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.VehiclePrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.CarPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.VehiclePrototype
local CarPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function CarPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = VehiclePrototype.process(_, rules)

  return new_rules
end

return CarPrototype
