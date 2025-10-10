-- luacheck: no max line length
local RailPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.RailPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.StraightRailPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.RailPrototype
local StraightRailPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function StraightRailPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = RailPrototype.process(_, rules)

  return new_rules
end

return StraightRailPrototype
