-- luacheck: no max line length
local EntityPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.EntityPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.FireFlamePrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.EntityPrototype
local FireFlamePrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function FireFlamePrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = EntityPrototype.process(_, rules)

  local uses_alternative_behavior_default = new_rules.uses_alternative_behavior[#new_rules.uses_alternative_behavior].metadata.default --[[@as boolean]]

  -- Only loaded if `uses_alternative_behavior` is true.
  new_rules.particle_alpha = {
    ignored_if = {
      {
        uses_alternative_behavior = {{default = uses_alternative_behavior_default}, {eq = false}}
      },
      new_rules.particle_alpha,
    }
  }

  -- Only loaded if `uses_alternative_behavior` is true.
  new_rules.particle_alpha_deviation = {
    ignored_if = {
      {
        uses_alternative_behavior = {{default = uses_alternative_behavior_default}, {eq = false}}
      },
      new_rules.particle_alpha_deviation,
    }
  }

  -- Only loaded if `uses_alternative_behavior` is false.
  new_rules.flame_alpha = {
    ignored_if = {
      {
        uses_alternative_behavior = {{default = uses_alternative_behavior_default}, {eq = true}}
      },
      new_rules.flame_alpha,
    }
  }

  -- Only loaded if `uses_alternative_behavior` is false.
  new_rules.flame_alpha_deviation = {
    ignored_if = {
      {
        uses_alternative_behavior = {{default = uses_alternative_behavior_default}, {eq = true}}
      },
      new_rules.flame_alpha_deviation,
    }
  }

  return new_rules
end

return FireFlamePrototype
