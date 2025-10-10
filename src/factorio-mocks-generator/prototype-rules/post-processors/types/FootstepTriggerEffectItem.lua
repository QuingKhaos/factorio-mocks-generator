local shared = require("factorio-mocks-generator.prototype-rules.post-processors.shared")
local utils = require("factorio-mocks-generator.utils")
-- luacheck: no max line length
local CreateParticleTriggerEffectItem = require("factorio-mocks-generator.prototype-rules.post-processors.types.CreateParticleTriggerEffectItem")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.FootstepTriggerEffectItem: factorio_mocks_generator.prototype_rules.post_processors.types.CreateParticleTriggerEffectItem
local FootstepTriggerEffectItem = {}

--- If the `actions` property is present, ignore all other properties from parent types.
--- @param type_concept FactorioPrototypeAPI.TypeConcept The type/concept being processed
--- @param rules LIVR.Rules The type/concept rules to process
--- @return LIVR.Rules # The modified type/concept rules
function FootstepTriggerEffectItem._ignore_parent_properties_if_actions(type_concept, rules)
  --- @type LIVR.Rules
  local new_rules = {}

  for property_name, property_rules in pairs(rules) do
    if shared.find_property_by_name(property_name, type_concept.properties, "types.FootstepTriggerEffectItem") ~= nil then
      -- Property is defined in this type, skip ignored_if rule
      new_rules[property_name] = utils.deepcopy(property_rules)
    else
      local new_rule = utils.deepcopy(property_rules)
      if new_rule.ignored_if ~= nil then
        new_rule.ignored_if[1] = {new_rule.ignored_if[1] --[[@as string]], "actions"}
      else
        new_rule = {
          ignored_if = {
            "actions",
            new_rule
          }
        }
      end

      new_rules[property_name] = new_rule
    end
  end

  return new_rules
end

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param type_concept FactorioPrototypeAPI.TypeConcept The type/concept being processed
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function FootstepTriggerEffectItem.process(type_concept, rules)
  --- @type LIVR.Rules
  local new_rules = CreateParticleTriggerEffectItem.process(type_concept, rules).nested_object
  new_rules = FootstepTriggerEffectItem._ignore_parent_properties_if_actions(type_concept, new_rules)

  return {
    nested_object = new_rules
  }
end

return FootstepTriggerEffectItem
