-- luacheck: no max line length
local ItemPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.ItemPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.ItemWithEntityDataPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.ItemPrototype
local ItemWithEntityDataPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function ItemWithEntityDataPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = ItemPrototype.process(_, rules)

  -- Only loaded if `icon_tintable` is defined.
  new_rules.icon_tintable_masks = {
    ignored_if = {
      {
        icon_tintable = "absent",
      },
      new_rules.icon_tintable_masks,
    }
  }

  -- Only loaded if `icon_tintable_masks` is not defined and `icon_tintable` is defined.
  new_rules.icon_tintable_mask = {
    ignored_if = {
      {
        icon_tintable_masks = "required",
        icon_tintable = "absent",
      },
      new_rules.icon_tintable_mask,
    }
  }

  -- Only loaded if `icon_tintable_masks` is not defined and `icon_tintable` is defined.
  new_rules.icon_tintable_mask_size = {
    ignored_if = {
      {
        icon_tintable_masks = "required",
        icon_tintable = "absent",
      },
      new_rules.icon_tintable_mask_size,
    }
  }

  -- Only loaded if `icon_tintable` is defined.
  new_rules.icon_tintables = {
    ignored_if = {
      {
        icon_tintable = "absent",
      },
      new_rules.icon_tintables,
    }
  }

  -- Only loaded if `icon_tintables` is not defined.
  new_rules.icon_tintable = {
    ignored_if = {
      {
        icon_tintables = "required",
      },
      new_rules.icon_tintable,
    }
  }

  -- Only loaded if `icon_tintables` is not defined and `icon_tintable` is defined.
  new_rules.icon_tintable_size = {
    ignored_if = {
      {
        icon_tintables = "required",
        icon_tintable = "absent",
      },
      new_rules.icon_tintable_size,
    }
  }

  return new_rules
end

return ItemWithEntityDataPrototype
