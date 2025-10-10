-- luacheck: no max line length
local SmokePrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.SmokePrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.SmokeWithTriggerPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.SmokePrototype
local SmokeWithTriggerPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function SmokeWithTriggerPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = SmokePrototype.process(_, rules)

  return new_rules
end

return SmokeWithTriggerPrototype
