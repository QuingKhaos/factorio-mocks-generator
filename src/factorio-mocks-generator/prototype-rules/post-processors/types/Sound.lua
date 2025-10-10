local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.Sound: factorio_mocks_generator.prototype_rules.post_processors.types
local Sound = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function Sound.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules["or"][1].nested_object)

  -- Only loaded, and mandatory if `variations` is not defined.
  new_rules.filename = {
    ignored_if = {
      "variations",
      new_rules.filename,
    }
  }

  -- Only loaded if `variations` is not defined.
  new_rules.volume = {
    ignored_if = {
      "variations",
      new_rules.volume,
    }
  }

  -- Only loaded if `variations` and `volume` are not defined.
  new_rules.min_volume = {
    ignored_if = {
      {"variations", "volume"},
      new_rules.min_volume,
    }
  }

  -- Only loaded if `variations` is not defined. Only loaded if `min_volume` is defined.
  new_rules.max_volume = {
    ignored_if = {
      {
        variations = "required",
        min_volume = "absent",
      },
      new_rules.max_volume,
    }
  }

  -- Only loaded if `variations` is not defined.
  new_rules.speed = {
    ignored_if = {
      "variations",
      new_rules.speed,
    }
  }

  -- Only loaded if both `variations` and `speed` are not defined.
  new_rules.min_speed = {
    ignored_if = {
      {"variations", "speed"},
      new_rules.min_speed,
    }
  }

  -- Only loaded if `variations` is not defined. Only loaded, and mandatory if `min_speed` is defined.
  new_rules.max_speed = {
    ignored_if = {
      {
        variations = "required",
        min_speed = "absent",
      },
      new_rules.max_speed,
    }
  }

  -- Only loaded if `variations` is not defined.
  new_rules.modifiers = {
    ignored_if = {
      "variations",
      new_rules.modifiers,
    }
  }

  return {
    ["or"] = {
      {nested_object = new_rules},
      rules["or"][2],
      rules["or"][3],
    }
  }
end

return Sound
