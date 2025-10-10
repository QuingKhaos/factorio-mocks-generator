-- luacheck: no max line length
local EntityWithOwnerPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.EntityWithOwnerPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.LinkedContainerPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.EntityWithOwnerPrototype
local LinkedContainerPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function LinkedContainerPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = EntityWithOwnerPrototype.process(_, rules)

  local inventory_type_default = new_rules.inventory_type[#new_rules.inventory_type].metadata.default --[[@as string]]

  -- Only used when `inventory_type` is `"with_custom_stack_size"`.
  new_rules.inventory_properties = {
    ignored_if = {
      {
        inventory_type = {{default = inventory_type_default}, {one_of = {"normal", "with_bar", "with_filters_and_bar", "with_weight_limit"}}}
      },
      new_rules.inventory_properties,
    }
  }

  -- Only used when `inventory_type` is `"with_weight_limit"`.
  new_rules.inventory_weight_limit = {
    ignored_if = {
      {
        inventory_type = {{default = inventory_type_default}, {one_of = {"normal", "with_bar", "with_filters_and_bar", "with_custom_stack_size"}}}
      },
      new_rules.inventory_weight_limit,
    }
  }

  return new_rules
end

return LinkedContainerPrototype
