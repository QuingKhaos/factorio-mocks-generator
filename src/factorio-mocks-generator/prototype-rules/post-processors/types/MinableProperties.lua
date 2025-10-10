local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.MinableProperties: factorio_mocks_generator.prototype_rules.post_processors.types
local MinableProperties = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function MinableProperties.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Only loaded if `results` is not defined.
  new_rules.result = {
    ignored_if = {
      "results",
      new_rules.result,
    }
  }

  -- Only loaded if `results` is not defined.
  new_rules.count = {
    ignored_if = {
      "results",
      new_rules.count,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return MinableProperties
