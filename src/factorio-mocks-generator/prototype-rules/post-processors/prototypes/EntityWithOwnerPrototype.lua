-- luacheck: no max line length
local EntityWithHealthPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.EntityWithHealthPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.EntityWithOwnerPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.EntityWithHealthPrototype
local EntityWithOwnerPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function EntityWithOwnerPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = EntityWithHealthPrototype.process(_, rules)

  return new_rules
end

return EntityWithOwnerPrototype
