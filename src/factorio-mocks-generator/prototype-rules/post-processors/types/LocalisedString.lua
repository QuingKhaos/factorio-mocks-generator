local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.LocalisedString: factorio_mocks_generator.prototype_rules.post_processors.types
local LocalisedString = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function LocalisedString.process(_, rules)
  --- @type LIVR.Rule|LIVR.Rule[]
  local new_rules = utils.deepcopy(rules["or"][2])

  new_rules = {new_rules, {metadata = {oneline = true}}}

  return {
    ["or"] = {
      rules["or"][1],
      new_rules,
    }
  }
end

return LocalisedString
