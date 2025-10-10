local helpers = require("factorio-mocks-generator.LIVR.helpers")
local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.shared
local shared = {}

--- Check if the given rule is a union rule
--- @param rule LIVR.Rule The rule to check
--- @return boolean # True if the rule is a union rule, false otherwise
function shared._is_union(rule)
  if not helpers.is_object(rule) then
    return false
  end

  if rule["or"] == nil then
    return false
  end

  if not helpers.is_array(rule["or"]) then
    return false
  end

  if #rule["or"] == 0 then
    return false
  end

  return true
end

--- Check if the given rule is a `tuple_of` rule
--- @param rule LIVR.Rule The rule to check
--- @return boolean # True if the rule is a `tuple_of` rule, false otherwise
function shared._is_tuple(rule)
  if not helpers.is_object(rule) then
    return false
  end

  if rule.tuple_of == nil then
    return false
  end

  if not helpers.is_array(rule.tuple_of) then
    return false
  end

  return true
end

--- Add metadata.oneline to all union rules within the given rule
--- @param rule LIVR.Rule The existing LIVR rule to enhance
--- @return LIVR.Rule # The enhanced LIVR rule
function shared.add_metadata_oneline_to_union_all(rule)
  if not shared._is_union(rule) then
    return rule
  end

  --- @type LIVR.Rule
  local new_rule = {
    ["or"] = {},
  }

  for _, union_rule in ipairs(rule["or"]) do
    if helpers.is_object(union_rule) then
      table.insert(new_rule["or"], {utils.deepcopy(union_rule), {metadata = {oneline = true}}})
    else
      table.insert(new_rule["or"], utils.deepcopy(union_rule))
    end
  end

  return new_rule
end

--- Add metadata.oneline to all union tuple rules within the given rule
--- @param rule LIVR.Rule The existing LIVR rule to enhance
--- @return LIVR.Rule # The enhanced LIVR rule
function shared.add_metadata_oneline_to_union_tuples(rule)
  if not shared._is_union(rule) then
    return rule
  end

  --- @type LIVR.Rule
  local new_rule = {
    ["or"] = {},
  }

  for _, union_rule in ipairs(rule["or"]) do
    if helpers.is_object(union_rule) and union_rule.tuple_of ~= nil then
      table.insert(new_rule["or"], {utils.deepcopy(union_rule), {metadata = {oneline = true}}})
    else
      table.insert(new_rule["or"], utils.deepcopy(union_rule))
    end
  end

  return new_rule
end

--- Add metadata.oneline to the tuple rule within the given rule
--- @param rule LIVR.Rule The existing LIVR rule to enhance
--- @return LIVR.Rule[] # The enhanced LIVR rules
function shared.add_metadata_oneline_to_tuple(rule)
  if not shared._is_tuple(rule) then
    return rule
  end

  --- @type LIVR.Rule[]
  return {utils.deepcopy(rule), {metadata = {oneline = true}}}
end

--- If the `layers` property is present, ignore all other properties.
--- @param rules LIVR.Rules The rules to process
--- @param exceptions? {[string]: true} A set of exception rule names to skip
--- @return LIVR.Rules # The modified rules
function shared.ignore_all_if_layers(rules, exceptions)
  --- @type LIVR.Rules
  local new_rules = {}

  for property_name, property_rules in pairs(rules) do
    if property_name == "layers" then
      -- `layers` may not be be an empty array
      local new_layers = utils.deepcopy(property_rules)
      table.insert(new_layers, 1, "not_empty_list")
      new_rules[property_name] = new_layers
    else
      if exceptions == nil or not exceptions[property_name] then
        if property_rules.ignored_if == nil then
          new_rules[property_name] = {
            ignored_if = {
              "layers",
              utils.deepcopy(property_rules),
            }
          }
        else
          new_rules[property_name] = utils.deepcopy(property_rules)
          new_rules[property_name].ignored_if[1].layers = "required"
        end
      else
        new_rules[property_name] = utils.deepcopy(property_rules)
      end
    end
  end

  return new_rules
end

--- @type {[string]: {[string]: FactorioPrototypeAPI.Property}}
local property_cache = {}

--- Find a property by name in the given properties list, using an optional cache key for optimization
--- @param name string The name of the property to find
--- @param properties FactorioPrototypeAPI.Property[] The list of properties to search
--- @param cache_key? string An optional cache key to store/retrieve the property for faster access
--- @return FactorioPrototypeAPI.Property? # The found property or nil if not found
function shared.find_property_by_name(name, properties, cache_key)
  if cache_key ~= nil then
    if property_cache[cache_key] == nil then
      property_cache[cache_key] = {}
      for _, property in ipairs(properties) do
        property_cache[cache_key][property.name] = property
      end
    end

    return property_cache[cache_key][name]
  end

  for _, property in ipairs(properties) do
    if property.name == name then
      return property
    end
  end

  return nil
end

return shared
