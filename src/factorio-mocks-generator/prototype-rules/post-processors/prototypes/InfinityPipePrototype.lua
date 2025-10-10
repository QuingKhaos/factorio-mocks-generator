-- luacheck: no max line length
local PipePrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.PipePrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.InfinityPipePrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.PipePrototype
local InfinityPipePrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function InfinityPipePrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = PipePrototype.process(_, rules)

  return new_rules
end

return InfinityPipePrototype
