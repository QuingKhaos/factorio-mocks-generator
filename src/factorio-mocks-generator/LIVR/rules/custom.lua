local livr = require("LIVR.Validator")
local expected_type = require("LIVR.helpers").expected_type
local string_number_type = require("LIVR.helpers").string_number_type
local lookup_table = require("factorio-mocks-generator.LIVR.lookup-table")
local helpers = require("factorio-mocks-generator.LIVR.helpers")

--- @class factorio_mocks_generator.LIVR.rules.custom
local rules = {}

--- Validates that a value is an unsigned integer (0, 1, 2, ...)
--- @return LIVR.Validation.fn # Validation function to be used by LIVR
function rules.unsigned_integer()
  return function(value)
    if value ~= nil then
      if type(value) ~= "number" then
        return value, "FORMAT_ERROR"
      end

      -- Check for NaN (NaN is the only value that doesn't equal itself)
      -- Factorio truncates decimal numbers to integers, so accept any valid number
      if value ~= value or value < 0 then
        return value, "NOT_UNSIGNED_INTEGER"
      end
    end

    return value
  end
end

function rules.absent()
  return function(value)
    if value == nil then
      return value
    end

    return value, "NOT_ABSENT"
  end
end

function rules.not_contains(_, ...)
  local disallowed_values = {...}
  return function(values)
    if values ~= nil then
      if not helpers.is_array(values) then
        return values, "FORMAT_ERROR"
      end

      local has_error = false
      local errors = {}

      for j, value in ipairs(values) do
        errors[j] = nil
        for i = 1, #disallowed_values do
          if value == disallowed_values[i] then
            has_error = true
            errors[j] = "NOT_ALLOWED_VALUE"
            break
          end
        end
      end

      if has_error then
        return values, errors
      end
    end

    return values
  end
end

function rules.not_if(rule_builders, query, _rules)
  expected_type("not_if", 1, "string", query)
  if type(_rules) ~= "table" and type(_rules) ~= "string" then
    error("Rule [not_if] bad argument #2 (string or table expected)")
  end

  if #_rules == 1 then
    _rules = _rules[1]
  end

  local validator = livr.new({field = _rules}):register_rules(rule_builders):prepare()
  return function(value, params)
    -- current field not set and other field not set
    if value == nil and params[query] == nil then
      -- validate current field with further rules, no XOR violation
      local result, errors = validator:validate({field = value})
      return result and result.field or nil, errors and errors.field or nil
    end

    -- current field not set but other field present
    if value == nil and params[query] ~= nil then
      return value -- do not validate current field with further rules, no XOR violation
    end

    -- current field set and other field not set
    if value ~= nil and params[query] == nil then
      -- validate current field with further rules, no XOR violation
      local result, errors = validator:validate({field = value})
      return result and result.field or nil, errors and errors.field or nil
    end

    -- current field set and other field present
    if value ~= nil and params[query] ~= nil then
      return value, "NOT_ALLOWED" -- XOR violation
    end

    return nil, "WTF" -- should never happen
  end
end

function rules.ignored_if(rule_builders, query, _rules)
  if type(query) ~= "table" and type(query) ~= "string" then
    error("Rule [ignored_if] bad argument #1 (string or table expected)")
  end

  if type(_rules) ~= "table" and type(_rules) ~= "string" then
    error("Rule [ignored_if] bad argument #2 (string or table expected)")
  end

  if #_rules == 1 then
    _rules = _rules[1]
  end

  local validator = livr.new({field = _rules}):register_rules(rule_builders):prepare()
  return function(value, params)
    -- Only execute ignored_if if no value is set for current field.
    -- If a value is set, we need to validate it no matter what to preserve mock data accuracy for testing.
    if value == nil then
      if type(query) == "string" then
        query = {query}
      end

      if helpers.is_array(query) then
        for _, q in ipairs(query) do
          -- if query field is present, eliminate this field from validation result
          if params[q] ~= nil then
            return nil, nil
          end
        end
      elseif helpers.is_object(query) then
        for q_name, q_rules in pairs(query) do
          if #q_rules == 1 then
            q_rules = q_rules[1]
          end

          local _, q_err = livr.new({field = q_rules}):register_rules(rule_builders):validate({field = params[q_name]})

          -- if query validation was successful, eliminate this field from validation result
          if q_err == nil then
            return nil, nil
          end
        end
      else
        error("Rule [ignored_if] bad argument #1 (malformed table)")
      end
    end

    local result, errors = validator:validate({field = value})
    return result and result.field or nil, errors and errors.field or nil
  end
end

function rules.dict_of(rule_builders, params)
  expected_type("dict_of", 1, "table", params)
  if not params.keys then
    error("Rule [dict_of] missing required parameter 'keys'")
  end
  if not params.values then
    error("Rule [dict_of] missing required parameter 'values'")
  end

  local key_validator = livr.new({field = params.keys}):register_rules(rule_builders):prepare()
  local value_validator = livr.new({field = params.values}):register_rules(rule_builders):prepare()

  return function(dict)
    if dict == nil then
      return dict
    end

    if not helpers.is_object(dict) then
      return dict, "FORMAT_ERROR"
    end

    local results = {}
    local errors = {}
    local has_error = false

    for key, value in pairs(dict) do
      -- Validate key
      local key_result, key_error = key_validator:validate({field = key})
      key_result = key_result and key_result.field
      key_error = key_error and key_error.field

      if key_error then
        errors[key] = errors[key] or {}
        errors[key].key = key_error
        has_error = has_error or key_error
      else
        results[key_result] = nil -- Prepare result entry for value validation.
      end

      local value_result, value_error = value_validator:validate({field = value})
      value_result = value_result and value_result.field
      value_error = value_error and value_error.field
      if value_error then
        errors[key] = errors[key] or {}
        errors[key].value = value_error
        has_error = has_error or value_error
      elseif key_result ~= nil and results[key_result] == nil then
        results[key_result] = value_result
      end
    end

    if has_error then
      results = nil
    else
      errors = nil
    end

    return results, errors
  end
end

function rules.tuple_of(rule_builders, ...)
  local _rules = {...}
  local validators = {}

  for i, rule in ipairs(_rules) do
    if #rule == 1 then
      rule = rule[1]
    end

    validators[i] = livr.new({field = rule}):register_rules(rule_builders):prepare()
  end

  return function(values)
    if values == nil then
      return values
    end

    if not helpers.is_array(values) then
      return values, "FORMAT_ERROR"
    end

    if #values < #_rules then
      return values, "TOO_FEW_ITEMS"
    end

    if #values > #_rules then
      return values, "TOO_MANY_ITEMS"
    end

    local results = {}
    local errors = {}
    local has_error = false

    -- Validate each element against its corresponding type rule
    for i = 1, #_rules do
      local result, error = validators[i]:validate({field = values[i]})
      if error then
        errors[i] = error.field
        has_error = true
      else
        results[i] = result.field
      end
    end

    if has_error then
      return nil, errors
    end

    return results
  end
end

--- @param lookup_key string Prototype type to look up to
--- @return LIVR.Validation.fn # Validation function to be used by LIVR
function rules.lookup(_, lookup_key)
  return function(value)
    if value == nil or value == "" then
      return value
    end

    local data_raw = lookup_table.get()
    if data_raw == nil then
      return value
    end

    local type_table = data_raw[lookup_key]
    if not type_table and lookup_table.opts().strict then
      return nil, "LOOKUP_TABLE_NOT_FOUND"
    elseif not type_table and not lookup_table.opts().strict then
      return value
    end

    local entry = type_table[value]
    if not entry then
      return nil, "LOOKUP_ENTRY_NOT_FOUND"
    end

    return value
  end
end

--- @param params LIVR.Rules.Custom.metadata.params Parameters for metadata handling
--- @return LIVR.Validation.fn # Validation function to be used by LIVR
function rules.metadata(_, params)
  expected_type("metadata", 1, "table", params)

  -- Validate oneline parameter if provided
  if params.oneline ~= nil then
    if type(params.oneline) ~= "boolean" then
      error("Rule [metadata] parameter 'oneline' must be a boolean")
    end
  end

  -- Validate order parameter if provided
  if params.order ~= nil then
    if not helpers.is_integer(params.order) or params.order < 0 then
      error("Rule [metadata] parameter 'order' must be an unsigned integer")
    end
  end

  return function(value)
    -- Handle default values for nil
    if value == nil and params.default ~= nil then
      value = {__meta_default__ = params.default}
    end

    -- Handle oneline metadata for non-empty tables only
    if value ~= nil and params.oneline == true and type(value) == "table" then
      -- Check if table is non-empty (has at least one key)
      local is_non_empty = false
      -- luacheck: ignore
      for _ in pairs(value) do
        is_non_empty = true
        break
      end

      if is_non_empty and not value.__meta_default__ then
        value = {__meta_oneline__ = true, __value__ = value}
      end
    end

    -- Handle order metadata
    if value ~= nil and params.order ~= nil then
      if type(value) == "table" and value.__meta_default__ ~= nil then
        value.__meta_order__ = params.order
      else
        if type(value) == "table" and value.__meta_oneline__ ~= nil then
          -- Already wrapped with oneline, add order to existing wrapper
          value.__meta_order__ = params.order
        else
          -- Wrap with order metadata
          value = {__meta_order__ = params.order, __value__ = value}
        end
      end
    end

    return value
  end
end

return rules
