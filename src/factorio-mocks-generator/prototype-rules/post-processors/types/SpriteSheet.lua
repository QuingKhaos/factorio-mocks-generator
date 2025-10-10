local shared = require("factorio-mocks-generator.prototype-rules.post-processors.shared")
-- luacheck: no max line length
local SpriteParameters = require("factorio-mocks-generator.prototype-rules.post-processors.types.SpriteParameters")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.SpriteSheet: factorio_mocks_generator.prototype_rules.post_processors.types.SpriteParameters
local SpriteSheet = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function SpriteSheet.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = SpriteParameters.process(_, rules).nested_object
  new_rules = shared.ignore_all_if_layers(new_rules)

  -- Only loaded, and mandatory if `layers` and `filenames` are not defined.
  new_rules.filename.ignored_if[1] = {new_rules.filename.ignored_if[1] --[[@as string]], "filenames"}

  return {
    nested_object = new_rules
  }
end

return SpriteSheet
