-- luacheck: no max line length
local EntityWithOwnerPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.EntityWithOwnerPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.BeaconPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.EntityWithOwnerPrototype
local BeaconPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function BeaconPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = EntityWithOwnerPrototype.process(_, rules)

  -- Only loaded if `graphics_set` is not defined.
  new_rules.animation = {
    ignored_if = {
      "graphics_set",
      new_rules.animation,
    }
  }

  -- Only loaded if `graphics_set` is not defined.
  new_rules.base_picture = {
    ignored_if = {
      "graphics_set",
      new_rules.base_picture,
    }
  }

  return new_rules
end

return BeaconPrototype
