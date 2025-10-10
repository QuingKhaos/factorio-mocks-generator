-- luacheck: no max line length
local SpriteSource = require("factorio-mocks-generator.prototype-rules.post-processors.types.SpriteSource")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.SpriteParameters: factorio_mocks_generator.prototype_rules.post_processors.types.SpriteSource
local SpriteParameters = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function SpriteParameters.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = SpriteSource.process(_, rules).nested_object

  -- Loaded only if `draw_as_shadow`, `draw_as_glow` and `draw_as_light` are `false`, ...
  new_rules.occludes_light = {
    ignored_if = {
      {
        draw_as_shadow = {"required", {eq = true}},
        draw_as_glow = {"required", {eq = true}},
        draw_as_light = {"required", {eq = true}},
      },
      new_rules.occludes_light,
    }
  }

  -- Only loaded if this is an icon, that is it has the flag `"group=icon"` or `"group=gui"`.
  new_rules.mipmap_count = {
    ignored_if = {
      {
        flags = {not_contains = {"icon", "gui", "gui-icon", "group=icon", "group=gui"}},
      },
      new_rules.mipmap_count,
    }
  }

  -- This property is only used by sprites used in `UtilitySprites` that have the `"icon"` flag set.
  new_rules.generate_sdf = {
    ignored_if = {
      {
        flags = {not_contains = {"icon"}},
      },
      new_rules.generate_sdf,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return SpriteParameters
