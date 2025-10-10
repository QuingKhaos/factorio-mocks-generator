-- luacheck: no max line length
local EntityPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.EntityPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.ResourceEntityPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.EntityPrototype
local ResourceEntityPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function ResourceEntityPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = EntityPrototype.process(_, rules)

  return new_rules
end

return ResourceEntityPrototype
