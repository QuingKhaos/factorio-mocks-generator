-- luacheck: no max line length
local ItemPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.ItemPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.SpacePlatformStarterPackPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.ItemPrototype
local SpacePlatformStarterPackPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function SpacePlatformStarterPackPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = ItemPrototype.process(_, rules)

  return new_rules
end

return SpacePlatformStarterPackPrototype
