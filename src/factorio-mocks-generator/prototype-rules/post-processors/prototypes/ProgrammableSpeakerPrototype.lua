-- luacheck: no max line length
local EntityWithOwnerPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.EntityWithOwnerPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.ProgrammableSpeakerPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.EntityWithOwnerPrototype
local ProgrammableSpeakerPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function ProgrammableSpeakerPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = EntityWithOwnerPrototype.process(_, rules)

  return new_rules
end

return ProgrammableSpeakerPrototype
