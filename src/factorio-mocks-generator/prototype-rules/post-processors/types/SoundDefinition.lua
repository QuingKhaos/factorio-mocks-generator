local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.SoundDefinition: factorio_mocks_generator.prototype_rules.post_processors.types
local SoundDefinition = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function SoundDefinition.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules["or"][1].nested_object)

  -- Only loaded if `volume` is not defined.
  new_rules.min_volume = {
    ignored_if = {
      "volume",
      new_rules.min_volume,
    }
  }

  -- Only loaded if `min_volume` is defined.
  new_rules.max_volume = {
    ignored_if = {
      {
        min_volume = "absent",
      },
      new_rules.max_volume,
    }
  }

  -- Only loaded if `speed` is not defined.
  new_rules.min_speed = {
    ignored_if = {
      "speed",
      new_rules.min_speed,
    }
  }

  -- Only loaded, and mandatory, if `min_speed` is defined.
  new_rules.max_speed = {
    ignored_if = {
      {
        min_speed = "absent",
      },
      new_rules.max_speed,
    }
  }

  return {
    ["or"] = {
      {nested_object = new_rules},
      rules["or"][2]
    }
  }
end

return SoundDefinition
