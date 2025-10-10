local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.Sprite4Way: factorio_mocks_generator.prototype_rules.post_processors.types
local Sprite4Way = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function Sprite4Way.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules["or"][1].nested_object)

  -- Only loaded if `sheets` is not defined.
  new_rules.sheet = {ignored_if = {"sheets", new_rules.sheet}}

  -- Only loaded if both `sheets` and `sheet` are not defined.
  new_rules.north = {ignored_if = {{"sheets", "sheet"}, new_rules.north}}

  -- + Only loaded if `north` is defined.
  new_rules.east = {
    ignored_if = {
      {
        sheets = "required",
        sheet = "required",
        north = "absent",
      },
      new_rules.east,
    }
  }

  new_rules.south = {
    ignored_if = {
      {
        sheets = "required",
        sheet = "required",
        north = "absent",
      },
      new_rules.south,
    }
  }

  new_rules.west = {
    ignored_if = {
      {
        sheets = "required",
        sheet = "required",
        north = "absent",
      },
      new_rules.west,
    }
  }

  return {
    ["or"] = {
      {nested_object = new_rules},
      rules["or"][2],
    }
  }
end

return Sprite4Way
