local livr = require("LIVR.Validator")
local original_rules = require("LIVR.Rules.Meta")
local serpent = require("serpent")
local helpers = require("factorio-mocks-generator.LIVR.helpers")

--- @class factorio_mocks_generator.LIVR.rules.meta
local rules = {}

rules["or"] = original_rules["or"]

local validators_cache = {}
local rule_key_serpent_options = {
  sortkeys = true,
  comment = false,
  compact = true,
  nocode = true,
  sparse = false,
  numformat = "%.14g",
}

function rules.nested_object(rule_builders, rule_schema)
  local rule_key = "nested_object:" .. serpent.line(rule_schema, rule_key_serpent_options)
  validators_cache[rule_key] = validators_cache[rule_key] or livr.new(rule_schema):register_rules(rule_builders)

  return function(nested_object)
    if nested_object == nil then
      return nested_object
    end

    if not helpers.is_object(nested_object) then
      return nested_object, "FORMAT_ERROR"
    end

    return validators_cache[rule_key]:validate(nested_object)
  end
end

function rules.list_of(rule_builders, ...)
  local rule_args = {...}
  if #rule_args == 1 then
    rule_args = rule_args[1]
  end

  local rule_key = "list_of:" .. serpent.line(rule_args, rule_key_serpent_options)
  validators_cache[rule_key] = validators_cache[rule_key] or livr.new({field = rule_args}):register_rules(rule_builders)

  return function(values)
    if values == nil then
      return values
    end

    if not helpers.is_array(values) then
      return values, "FORMAT_ERROR"
    end

    local results = {}
    local errors = {}
    local has_error = false
    for i = 1, #values do
      local val = values[i]
      local result, err = validators_cache[rule_key]:validate({field = val})

      result = result and result.field
      err = err and err.field
      results[i] = result
      errors[i] = err
      has_error = has_error or err
    end

    if has_error then
      results = nil
    else
      errors = nil
    end
    return results, errors
  end
end

function rules.list_of_objects(rule_builders, rule_schema)
  local validator = livr.new(rule_schema):register_rules(rule_builders):prepare()
  return function(objects)
    if objects == nil then
      return objects
    end

    if not helpers.is_array(objects) then
      return objects, "FORMAT_ERROR"
    end

    local results = {}
    local errors = {}
    local has_error = false
    for i = 1, #objects do
      local obj = objects[i]
      local result, err = validator:validate(obj)

      results[i] = result
      errors[i] = err
      has_error = has_error or err
    end

    if has_error then
      results = nil
    else
      errors = nil
    end

    return results, errors
  end
end

return rules
