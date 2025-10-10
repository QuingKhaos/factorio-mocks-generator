local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.FluidPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes
local FluidPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function FluidPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules)

  -- Only loaded, and mandatory if `icons` is not defined.
  new_rules.icon = {
    ignored_if = {
      "icons",
      new_rules.icon,
    }
  }

  -- Only loaded if `icons` is not defined.
  new_rules.icon_size = {
    ignored_if = {
      "icons",
      new_rules.icon_size,
    }
  }

  return new_rules
end

return FluidPrototype
