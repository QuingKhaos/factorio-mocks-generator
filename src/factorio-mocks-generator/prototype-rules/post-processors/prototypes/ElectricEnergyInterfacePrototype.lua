-- luacheck: no max line length
local EntityWithOwnerPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.EntityWithOwnerPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.ElectricEnergyInterfacePrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.EntityWithOwnerPrototype
local ElectricEnergyInterfacePrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function ElectricEnergyInterfacePrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = EntityWithOwnerPrototype.process(_, rules)

  -- Only loaded if `picture` is not defined.
  new_rules.pictures = {
    ignored_if = {
      "picture",
      new_rules.pictures,
    }
  }

  -- Only loaded if both `picture` and `pictures` are not defined.
  new_rules.animation = {
    ignored_if = {
      {"picture", "pictures"},
      new_rules.animation,
    }
  }

  -- Only loaded if both `picture` and `pictures`, and `animation` are not defined.
  new_rules.animations = {
    ignored_if = {
      {"picture", "pictures", "animation"},
      new_rules.animations,
    }
  }

  return new_rules
end

return ElectricEnergyInterfacePrototype
