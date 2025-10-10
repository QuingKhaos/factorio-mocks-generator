-- luacheck: no max line length
local StraightRailPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.StraightRailPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.ElevatedStraightRailPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.StraightRailPrototype
local ElevatedStraightRailPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function ElevatedStraightRailPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = StraightRailPrototype.process(_, rules)

  return new_rules
end

return ElevatedStraightRailPrototype
