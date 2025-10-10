-- luacheck: no max line length
local RobotWithLogisticInterfacePrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.RobotWithLogisticInterfacePrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.LogisticRobotPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.RobotWithLogisticInterfacePrototype
local LogisticRobotPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function LogisticRobotPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = RobotWithLogisticInterfacePrototype.process(_, rules)

  return new_rules
end

return LogisticRobotPrototype
