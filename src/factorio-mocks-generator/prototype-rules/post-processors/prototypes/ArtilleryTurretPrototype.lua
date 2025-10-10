-- luacheck: no max line length
local EntityWithOwnerPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.EntityWithOwnerPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.ArtilleryTurretPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.EntityWithOwnerPrototype
local ArtilleryTurretPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function ArtilleryTurretPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = EntityWithOwnerPrototype.process(_, rules)

  -- Only loaded if `cannon_barrel_recoil_shiftings` is loaded.
  new_rules.cannon_barrel_recoil_shiftings_load_correction_matrix = {
    ignored_if = {
      {cannon_barrel_recoil_shiftings = "absent"},
      new_rules.cannon_barrel_recoil_shiftings_load_correction_matrix,
    }
  }

  -- Only loaded if `cannon_barrel_recoil_shiftings` is loaded.
  new_rules.cannon_barrel_light_direction = {
    ignored_if = {
      {cannon_barrel_recoil_shiftings = "absent"},
      new_rules.cannon_barrel_light_direction,
    }
  }

  return new_rules
end

return ArtilleryTurretPrototype
