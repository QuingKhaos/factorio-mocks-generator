-- luacheck: no max line length
local RailSignalBasePrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.RailSignalBasePrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.RailChainSignalPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.RailSignalBasePrototype
local RailChainSignalPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function RailChainSignalPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = RailSignalBasePrototype.process(_, rules)

  return new_rules
end

return RailChainSignalPrototype
