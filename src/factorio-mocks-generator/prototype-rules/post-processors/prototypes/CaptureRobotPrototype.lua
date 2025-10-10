-- luacheck: no max line length
local FlyingRobotPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.FlyingRobotPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.CaptureRobotPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.FlyingRobotPrototype
local CaptureRobotPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function CaptureRobotPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = FlyingRobotPrototype.process(_, rules)

  return new_rules
end

return CaptureRobotPrototype
