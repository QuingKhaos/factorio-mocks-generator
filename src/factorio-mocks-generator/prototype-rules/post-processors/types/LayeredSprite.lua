-- luacheck: no max line length
local Sprite = require("factorio-mocks-generator.prototype-rules.post-processors.types.Sprite")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.LayeredSprite: factorio_mocks_generator.prototype_rules.post_processors.types.Sprite
local LayeredSprite = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function LayeredSprite.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = Sprite.process(_, rules["or"][1]).nested_object

  -- Remove `ignored_if` rule from `LayeredSprite` properties, they shouldn't be ignored.
  new_rules.render_layer = new_rules.render_layer.ignored_if[2]

  return {
    ["or"] = {
      {nested_object = new_rules},
      rules["or"][2],
    }
  }
end

return LayeredSprite
