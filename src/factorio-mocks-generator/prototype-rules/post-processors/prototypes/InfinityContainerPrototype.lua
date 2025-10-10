-- luacheck: no max line length
local LogisticContainerPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.LogisticContainerPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.InfinityContainerPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.LogisticContainerPrototype
local InfinityContainerPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function InfinityContainerPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = LogisticContainerPrototype.process(_, rules)

  return new_rules
end

return InfinityContainerPrototype
