local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.SimulationDefinition: factorio_mocks_generator.prototype_rules.post_processors.types
local SimulationDefinition = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function SimulationDefinition.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- Only loaded if `init_file` is not defined.
  new_rules.init = {
    ignored_if = {
      "init_file",
      new_rules.init,
    }
  }

  -- Only loaded if `update_file` is not defined.
  new_rules.update = {
    ignored_if = {
      "update_file",
      new_rules.update,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return SimulationDefinition
