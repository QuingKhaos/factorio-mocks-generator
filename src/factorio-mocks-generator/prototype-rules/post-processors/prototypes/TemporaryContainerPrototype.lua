-- luacheck: no max line length
local ContainerPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.ContainerPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.TemporaryContainerPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.ContainerPrototype
local TemporaryContainerPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function TemporaryContainerPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = ContainerPrototype.process(_, rules)

  return new_rules
end

return TemporaryContainerPrototype
