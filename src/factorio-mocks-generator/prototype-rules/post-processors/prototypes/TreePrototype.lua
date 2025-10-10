-- luacheck: no max line length
local EntityWithHealthPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.EntityWithHealthPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.TreePrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.EntityWithHealthPrototype
local TreePrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function TreePrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = EntityWithHealthPrototype.process(_, rules)

  -- Add metadata.oneline to `variation_weights`
  new_rules.variation_weights[#new_rules.variation_weights].metadata.oneline = true

  return new_rules
end

return TreePrototype
