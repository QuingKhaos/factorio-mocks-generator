-- luacheck: no max line length
local ItemWithInventoryPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.ItemWithInventoryPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.BlueprintBookPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.ItemWithInventoryPrototype
local BlueprintBookPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function BlueprintBookPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = ItemWithInventoryPrototype.process(_, rules)

  return new_rules
end

return BlueprintBookPrototype
