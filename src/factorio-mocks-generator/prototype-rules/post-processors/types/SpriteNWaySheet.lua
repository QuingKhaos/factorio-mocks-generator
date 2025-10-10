-- luacheck: no max line length
local SpriteParameters = require("factorio-mocks-generator.prototype-rules.post-processors.types.SpriteParameters")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.SpriteNWaySheet: factorio_mocks_generator.prototype_rules.post_processors.types.SpriteParameters
local SpriteNWaySheet = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function SpriteNWaySheet.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = SpriteParameters.process(_, rules).nested_object

  -- Unused
  new_rules.generate_sdf = {
    ignored_if = {{generate_sdf = "boolean"}, {}}
  }

  return {
    nested_object = new_rules
  }
end

return SpriteNWaySheet
