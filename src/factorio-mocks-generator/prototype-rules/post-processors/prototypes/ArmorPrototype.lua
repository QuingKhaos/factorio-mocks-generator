-- luacheck: no max line length
local ToolPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.ToolPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.ArmorPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.ToolPrototype
local ArmorPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function ArmorPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = ToolPrototype.process(_, rules)

  -- Only loaded if `provides_flight` is true.
  if new_rules.provides_flight ~= nil then
    local provides_flight_default = new_rules.provides_flight[#new_rules.provides_flight].metadata.default --[[@as boolean]]

    new_rules.takeoff_sound = {
      ignored_if = {
        {provides_flight = {{default = provides_flight_default}, {eq = false}}},
        new_rules.takeoff_sound,
      }
    }

    new_rules.flight_sound = {
      ignored_if = {
        {provides_flight = {{default = provides_flight_default}, {eq = false}}},
        new_rules.flight_sound,
      }
    }

    new_rules.landing_sound = {
      ignored_if = {
        {provides_flight = {{default = provides_flight_default}, {eq = false}}},
        new_rules.landing_sound,
      }
    }
  end

  return new_rules
end

return ArmorPrototype
