-- luacheck: no max line length
local ContainerPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.ContainerPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.LogisticContainerPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.ContainerPrototype
local LogisticContainerPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function LogisticContainerPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = ContainerPrototype.process(_, rules)

  -- Only loaded if `animation` is defined.
  new_rules.animation_sound = {
    ignored_if = {
      {animation = "absent"},
      new_rules.animation_sound,
    }
  }

  return new_rules
end

return LogisticContainerPrototype
