local shared = require("factorio-mocks-generator.prototype-rules.post-processors.shared")
-- luacheck: no max line length
local AnimationParameters = require("factorio-mocks-generator.prototype-rules.post-processors.types.AnimationParameters")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.Animation: factorio_mocks_generator.prototype_rules.post_processors.types.AnimationParameters
local Animation = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function Animation.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = AnimationParameters.process(_, rules).nested_object
  new_rules = shared.ignore_all_if_layers(new_rules)

  -- Only loaded if neither `layers` nor `stripes` are defined.
  new_rules.filenames.ignored_if[1] = {new_rules.filenames.ignored_if[1] --[[@as string]], "stripes"}

  -- Only loaded if `layers` is not defined and if `filenames` is defined.
  new_rules.slice.ignored_if[1] = {
    layers = "required",
    filenames = "absent",
  }

  return {
    nested_object = new_rules,
  }
end

return Animation
