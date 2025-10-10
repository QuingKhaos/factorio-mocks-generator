-- luacheck: no max line length
local FlyingRobotPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.FlyingRobotPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.RobotWithLogisticInterfacePrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.FlyingRobotPrototype
local RobotWithLogisticInterfacePrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function RobotWithLogisticInterfacePrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = FlyingRobotPrototype.process(_, rules, {logistic = true})

  return new_rules
end

return RobotWithLogisticInterfacePrototype
