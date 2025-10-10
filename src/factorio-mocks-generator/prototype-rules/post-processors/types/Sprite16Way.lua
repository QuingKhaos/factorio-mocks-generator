local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.Sprite16Way: factorio_mocks_generator.prototype_rules.post_processors.types
local Sprite16Way = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function Sprite16Way.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Only loaded if `sheets` is not defined.
  new_rules.sheet = {ignored_if = {"sheets", new_rules.sheet}}

  -- Only loaded, and mandatory if both `sheets` and `sheet` are not defined.
  new_rules.north = {ignored_if = {{"sheets", "sheet"}, new_rules.north}}
  new_rules.north_north_east = {ignored_if = {{"sheets", "sheet"}, new_rules.north_north_east}}
  new_rules.north_east = {ignored_if = {{"sheets", "sheet"}, new_rules.north_east}}
  new_rules.east_north_east = {ignored_if = {{"sheets", "sheet"}, new_rules.east_north_east}}
  new_rules.east = {ignored_if = {{"sheets", "sheet"}, new_rules.east}}
  new_rules.east_south_east = {ignored_if = {{"sheets", "sheet"}, new_rules.east_south_east}}
  new_rules.south_east = {ignored_if = {{"sheets", "sheet"}, new_rules.south_east}}
  new_rules.south_south_east = {ignored_if = {{"sheets", "sheet"}, new_rules.south_south_east}}
  new_rules.south = {ignored_if = {{"sheets", "sheet"}, new_rules.south}}
  new_rules.south_south_west = {ignored_if = {{"sheets", "sheet"}, new_rules.south_south_west}}
  new_rules.south_west = {ignored_if = {{"sheets", "sheet"}, new_rules.south_west}}
  new_rules.west_south_west = {ignored_if = {{"sheets", "sheet"}, new_rules.west_south_west}}
  new_rules.west = {ignored_if = {{"sheets", "sheet"}, new_rules.west}}
  new_rules.west_north_west = {ignored_if = {{"sheets", "sheet"}, new_rules.west_north_west}}
  new_rules.north_west = {ignored_if = {{"sheets", "sheet"}, new_rules.north_west}}
  new_rules.north_north_west = {ignored_if = {{"sheets", "sheet"}, new_rules.north_north_west}}

  return {
    nested_object = new_rules
  }
end

return Sprite16Way
