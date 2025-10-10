-- luacheck: no max line length
local CorpsePrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.CorpsePrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.RailRemnantsPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.CorpsePrototype
local RailRemnantsPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function RailRemnantsPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = CorpsePrototype.process(_, rules)

  return new_rules
end

return RailRemnantsPrototype