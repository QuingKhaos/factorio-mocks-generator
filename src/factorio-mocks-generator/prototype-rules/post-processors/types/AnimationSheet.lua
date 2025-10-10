-- luacheck: no max line length
local AnimationParameters = require("factorio-mocks-generator.prototype-rules.post-processors.types.AnimationParameters")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.AnimationSheet: factorio_mocks_generator.prototype_rules.post_processors.types.AnimationParameters
local AnimationSheet = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function AnimationSheet.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = AnimationParameters.process(_, rules).nested_object

  -- Only loaded, and mandatory if `filenames` is not defined.
  new_rules.filename = {
    ignored_if = {
      "filenames",
      new_rules.filename,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return AnimationSheet
