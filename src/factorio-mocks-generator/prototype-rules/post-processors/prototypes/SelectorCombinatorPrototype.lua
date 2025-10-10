-- luacheck: no max line length
local CombinatorPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.CombinatorPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.SelectorCombinatorPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.CombinatorPrototype
local SelectorCombinatorPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function SelectorCombinatorPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = CombinatorPrototype.process(_, rules)

  return new_rules
end

return SelectorCombinatorPrototype
