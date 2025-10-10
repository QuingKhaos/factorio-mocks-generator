-- luacheck: no max line length
local EntityWithOwnerPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.EntityWithOwnerPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.CargoLandingPadPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.EntityWithOwnerPrototype
local CargoLandingPadPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function CargoLandingPadPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = EntityWithOwnerPrototype.process(_, rules)

  -- Only loaded if `robot_animation` is defined.
  new_rules.robot_animation_sound = {
    ignored_if = {
      {robot_animation = "absent"},
      new_rules.robot_animation_sound,
    }
  }

  return new_rules
end

return CargoLandingPadPrototype
