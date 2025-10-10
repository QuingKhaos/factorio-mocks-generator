local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.LightDefinition: factorio_mocks_generator.prototype_rules.post_processors.types
local LightDefinition = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function LightDefinition.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules["or"][1].nested_object)

  local type_default = new_rules.type[#new_rules.type].metadata.default --[[@as string]]

  -- Only loaded, and mandatory if `type` is `"oriented"`.
  new_rules.picture = {
    ignored_if = {
      {
        type = {{default = type_default}, {eq = "basic"}},
      },
      new_rules.picture,
    }
  }

  -- Only loaded if `type` is `"oriented"`.
  new_rules.rotation_shift = {
    ignored_if = {
      {
        type = {{default = type_default}, {eq = "basic"}},
      },
      new_rules.rotation_shift,
    }
  }

  return {
    ["or"] = {
      {nested_object = new_rules},
      {list_of_objects = utils.deepcopy(new_rules)},
    }
  }
end

return LightDefinition
