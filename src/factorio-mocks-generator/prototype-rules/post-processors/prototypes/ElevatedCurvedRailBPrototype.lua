-- luacheck: no max line length
local CurvedRailBPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.CurvedRailBPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.ElevatedCurvedRailBPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.CurvedRailBPrototype
local ElevatedCurvedRailBPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function ElevatedCurvedRailBPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = CurvedRailBPrototype.process(_, rules)

  return new_rules
end

return ElevatedCurvedRailBPrototype
