-- luacheck: no max line length
local EntityWithOwnerPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.EntityWithOwnerPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.FlyingRobotPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.EntityWithOwnerPrototype
local FlyingRobotPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @param options? {logistic: boolean} Processing options
--- @return LIVR.Rules # The modified prototype rules
function FlyingRobotPrototype.process(_, rules, options)
  options = options or {
    logistic = false,
  }

  --- @type LIVR.Rules
  local new_rules = EntityWithOwnerPrototype.process(_, rules)

  -- Remove default values from properties which are only relevant for robots with logistic interface.
  if not options.logistic then
    new_rules.max_energy[#new_rules.max_energy].metadata.default = nil
    new_rules.energy_per_move[#new_rules.energy_per_move].metadata.default = nil
    new_rules.energy_per_tick[#new_rules.energy_per_tick].metadata.default = nil
    new_rules.min_to_charge[#new_rules.min_to_charge].metadata.default = nil
    new_rules.max_to_charge[#new_rules.max_to_charge].metadata.default = nil
    new_rules.speed_multiplier_when_out_of_energy[#new_rules.speed_multiplier_when_out_of_energy].metadata.default = nil
  end

  return new_rules
end

return FlyingRobotPrototype
