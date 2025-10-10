-- luacheck: no max line length
local SegmentPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.SegmentPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.SegmentedUnitPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.SegmentPrototype
local SegmentedUnitPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function SegmentedUnitPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = SegmentPrototype.process(_, rules)

  -- Only loaded, and mandatory if `hurt_roar` is defined.
  new_rules.hurt_thresholds = {
    ignored_if = {
      {hurt_roar = "absent"},
      new_rules.hurt_thresholds,
    }
  }

  return new_rules
end

return SegmentedUnitPrototype
