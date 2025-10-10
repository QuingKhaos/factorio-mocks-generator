local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.SmokeSource: factorio_mocks_generator.prototype_rules.post_processors.types
local SmokeSource = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function SmokeSource.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- luacheck: no max line length
  local has_8_directions_default = new_rules.has_8_directions[#new_rules.has_8_directions].metadata.default --[[@as string]]

  -- Only loaded if `has_8_directions` is `true`.
  new_rules.north_east_position = {
    ignored_if = {
      {
        has_8_directions = {{default = has_8_directions_default}, {eq = false}},
      },
      new_rules.north_east_position,
    }
  }

  -- Only loaded if `has_8_directions` is `true`.
  new_rules.south_east_position = {
    ignored_if = {
      {
        has_8_directions = {{default = has_8_directions_default}, {eq = false}},
      },
      new_rules.south_east_position,
    }
  }

  -- Only loaded if `has_8_directions` is `true`.
  new_rules.south_west_position = {
    ignored_if = {
      {
        has_8_directions = {{default = has_8_directions_default}, {eq = false}},
      },
      new_rules.south_west_position,
    }
  }

  -- Only loaded if `has_8_directions` is `true`.
  new_rules.north_west_position = {
    ignored_if = {
      {
        has_8_directions = {{default = has_8_directions_default}, {eq = false}},
      },
      new_rules.north_west_position,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return SmokeSource
