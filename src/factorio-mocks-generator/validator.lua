local path = require("path")
local regex = require("regex")
local livr = require("factorio-mocks-generator.LIVR")
local helpers = require("factorio-mocks-generator.LIVR.helpers")
local serializer = require("factorio-mocks-generator.LIVR.serializer")
local file_utils = require("factorio-mocks-generator.file-utils")
local loader = require("factorio-mocks-generator.loader")
local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.validator.filter.config
--- @field pattern string? The pattern to use for filtering
--- @field type "lua"|"regex" The type of pattern
local _filter_config = {}

--- @class factorio_mocks_generator.validator.filter
--- @field data_raw factorio_mocks_generator.validator.filter.config Filter for data.raw validation
local _filters = {}

--- @class factorio_mocks_generator.validator.options
--- @field debug boolean Enable debug output (overwrites files in place, creates pre-serialization data.raw files, skips checksums)
--- @field force boolean Overwrite existing files
--- @field filters factorio_mocks_generator.validator.filter
local _default_options = {
  debug = false,
  force = false,
  filters = {
    data_raw = {
      pattern = nil,
      type = "lua"
    }
  }
}

local _HASH_ALGORITHM = "adler32"
local hashings = require("hashings." .. _HASH_ALGORITHM)

--- @class factorio_mocks_generator.validator.metadata
--- @field factorio_version {__meta_order__: number, __value__: string} Factorio version used for generation
--- @field generator_version {__meta_order__: number, __value__: string} Version of factorio-mocks-generator used for generation
--- @field visibility {__meta_oneline__: boolean, __meta_order__: number, __value__: string[]} List of game expansions the rules apply to
--- @field hash_algorithm {__meta_order__: number, __value__: string} Hash algorithm + digest variant used for integrity checksums
--- @field checksums {__meta_order: number, __value__: {[string]: {__meta_order__: number, __value__: string}}} Integrity checksums for generated files
local _metadata = {}

--- @class factorio_mocks_generator.validator
--- @field private _rules? LIVR.Rules.Factorio
--- @field private _subscriber {[string]: function[]}
--- @field private _options factorio_mocks_generator.validator.options
--- @field private _collected_metadata? factorio_mocks_generator.validator.metadata
--- @field private _has_errors boolean If any validation errors/failures have occured
local validator = {
  _rules = nil,
  _subscriber = {},
  _options = utils.deepcopy(_default_options),
  _collected_metadata = nil,
  _has_errors = false,
}

function validator._filter(filter, subject)
  local _filter = validator._options.filters[filter]
  if _filter == nil then
    error("No such filter configured: " .. filter)
  end

  if _filter.pattern == nil then
    return true
  end

  if _filter.type == "lua" then
    return string.match(subject, _filter.pattern)
  elseif _filter.type == "regex" then
    local ok, err = regex.test(subject, _filter.pattern)
    if err then
      error("Invalid regex pattern for filter '" .. filter .. "': " .. err)
    end

    return ok
  end

  return false
end

--- Load LIVR rules from the specified directory.
--- @param rules_dir string Directory containing the generated LIVR rules.
function validator._load_rules(rules_dir)
  if not path.isdir(rules_dir) then
    error("rules directory does not exist: " .. rules_dir)
  end

  loader.register_loader("___GENERATED__FACTORIO__RULES___", rules_dir)
  validator._rules = require("___GENERATED__FACTORIO__RULES___")
end

--- Load LIVR rules from the specified directory.
--- @param script_output string Directory containing the generated LIVR rules.
function validator._load_generated_data(script_output)
  if not path.isdir(script_output) then
    error("script-output directory does not exist: " .. script_output)
  end

  if not path.isdir(script_output, "factorio-mocks-generator") then
    error("No generated data in script-output available, missing " ..
      path(script_output, "factorio-mocks-generator") .. " directory")
  end

  loader.register_loader(
    "___GENERATED__FACTORIO__DATA___",
    path(script_output, "factorio-mocks-generator")
  )
end

function validator._validate_prototype_data_raw(output_dir)
  --- @type data.raw
  local data_raw = require("___GENERATED__FACTORIO__DATA___.prototype.data-raw")
  local rules = validator._rules.prototype.prototypes

  -- Get sorted prototype names for deterministic iteration
  local prototype_names = utils.table_keys(data_raw)
  table.sort(prototype_names, function(a, b)
    return rules[a].order < rules[b].order
  end)

  local data_raw_init_content = "--- @type data.raw\nreturn {\n"

  for _, prototype in ipairs(prototype_names) do
    if validator._filter("data_raw", prototype) then
      local data = data_raw[prototype]
      local prototype_rules = rules[prototype].rules

      local wildcard_rule = prototype_rules["*"]
      if wildcard_rule then
        prototype_rules["*"] = nil
      end

      -- Get sorted entry names for deterministic iteration
      local entry_names = utils.table_keys(data)

      local livr_validator
      local results = {}

      for _, name in ipairs(entry_names) do
        local entry = data[name]
        local validation_key = string.format('PROTOTYPE: data.raw["%s"]["%s"]', prototype, name)
        validator._emit("start", validation_key)

        local extended_rules
        if wildcard_rule then
          local extended_order = 50000
          extended_rules = utils.deepcopy(prototype_rules)

          -- Get sorted field names for deterministic order in output
          local fields = utils.table_keys(entry)

          for _, field in ipairs(fields) do
            if extended_rules[field] == nil then
              local extended_rule = {}
              if type(wildcard_rule) == "string" then
                extended_rule = {wildcard_rule}
              elseif helpers.is_object(wildcard_rule) then
                extended_rule = {utils.deepcopy(wildcard_rule)}
              elseif helpers.is_array(wildcard_rule) then
                for _, rule in ipairs(wildcard_rule) do
                  table.insert(extended_rule, utils.deepcopy(rule))
                end
              else
                error("Invalid wildcard rule type for prototype '" .. prototype .. "': " .. type(wildcard_rule))
              end

              table.insert(extended_rule, {metadata = {order = extended_order}})
              extended_order = extended_order + 1
              extended_rules[field] = extended_rule
            end
          end
        end

        local success, result, errors = pcall(function()
          livr_validator = livr_validator or livr.new(extended_rules or prototype_rules)
          return livr_validator:validate(entry)
        end)

        -- clear validator if extended rules were used, to avoid pollution of subsequent entries
        if extended_rules then
          livr_validator = nil
        end

        if not success then
          validator._emit("error", validation_key, result)
          -- reset validator to avoid surpressed errors on subsequent validations
          livr_validator = nil
        elseif errors then
          validator._emit("failure", validation_key, errors)
        else
          validator._emit("success", validation_key)
          results[name] = result
        end
      end

      if validator._options.debug then
        file_utils.write_file(path(output_dir, "prototype", "data-raw", prototype .. ".debug.lua"),
          "return " .. require("serpent").block(results, {
            comment = false,
            sortkeys = true,
            nocode = true,
            sparse = false,
            numformat = "%.16g"
          }) .. "\n"
        )
      end

      validator._write_file_with_checksum(
        output_dir, "prototype/data-raw/" .. prototype .. ".lua", rules[prototype].order,
        "--- @type {[string]: data." .. rules[prototype].name .. "}\n" ..
        "return " .. serializer.serialize(results) .. "\n"
      )

      data_raw_init_content = data_raw_init_content ..
        '  ["' .. prototype .. '"] = ' ..
        'require("___GENERATED__FACTORIO__DATA___.prototype.data-raw.' .. prototype .. '"),\n'
    end
  end

  data_raw_init_content = data_raw_init_content .. "}\n"
  validator._write_file_with_checksum(
    output_dir, "prototype/data-raw/init.lua", 1171,
    data_raw_init_content
  )
end

function validator._validate_prototype_feature_flags(output_dir)
  --- @type data.FeatureFlags
  local feature_flags = require("___GENERATED__FACTORIO__DATA___.prototype.feature-flags")

  validator._emit("start", "PROTOTYPE: feature_flags")
  local success, result, errors = pcall(function()
    local livr_validator = livr.new({feature_flags = validator._rules.prototype.feature_flags})
    return livr_validator:validate({feature_flags = feature_flags})
  end)

  if not success then
    validator._emit("error", "PROTOTYPE: feature_flags", result)
  elseif errors then
    validator._emit("failure", "PROTOTYPE: feature_flags", errors)
  else
    validator._emit("success", "PROTOTYPE: feature_flags")

    validator._write_file_with_checksum(
      output_dir, "prototype/feature-flags.lua", 1225,
      "--- @type data.FeatureFlags\nreturn " .. serializer.serialize(result.feature_flags) .. "\n"
    )
  end
end

function validator._validate_prototype_mods(output_dir)
  --- @type data.Mods
  local mods = require("___GENERATED__FACTORIO__DATA___.prototype.mods")

  validator._emit("start", "PROTOTYPE: mods")
  local success, result, errors = pcall(function()
    local livr_validator = livr.new({mods = validator._rules.prototype.mods})
    return livr_validator:validate({mods = mods})
  end)

  if not success then
    validator._emit("error", "PROTOTYPE: mods", result)
  elseif errors then
    validator._emit("failure", "PROTOTYPE: mods", errors)
  else
    validator._emit("success", "PROTOTYPE: mods")

    validator._write_file_with_checksum(
      output_dir, "prototype/mods.lua", 1356,
      "--- @type data.Mods\nreturn " .. serializer.serialize(result.mods) .. "\n"
    )
  end
end

function validator._validate_prototype_settings(output_dir)
  --- @type data.Settings
  local settings = require("___GENERATED__FACTORIO__DATA___.prototype.settings")

  validator._emit("start", "PROTOTYPE: settings")
  local success, result, errors = pcall(function()
    local livr_validator = livr.new({settings = validator._rules.prototype.settings})
    return livr_validator:validate({settings = settings})
  end)

  if not success then
    validator._emit("error", "PROTOTYPE: settings", result)
  elseif errors then
    validator._emit("failure", "PROTOTYPE: settings", errors)
  else
    validator._emit("success", "PROTOTYPE: settings")

    validator._write_file_with_checksum(
      output_dir, "prototype/settings.lua", 1491,
      "--- @type data.Settings\nreturn " .. serializer.serialize(result.settings) .. "\n"
    )
  end
end

--- Validate all prototype stage data in the given directory against the loaded rules.
--- @param output_dir string Output directory for validated data.
function validator._validate_prototype(output_dir)
  validator._validate_prototype_data_raw(output_dir)
  validator._validate_prototype_feature_flags(output_dir)
  validator._validate_prototype_mods(output_dir)
  validator._validate_prototype_settings(output_dir)
end

--- Write a file with checksum calculation and store it in metadata.
--- @param output_dir string Directory to write the file into
--- @param relative_path string Relative path within the output directory
--- @param order number Order of the relative path for determenistic output
--- @param content string Content to write into the file
function validator._write_file_with_checksum(output_dir, relative_path, order, content)
  if not validator._options.debug then
    local hash = hashings:new(content)
    local checksum = hash:hexdigest()

    validator._collected_metadata.checksums.__value__[relative_path] = {
      __meta_order__ = order,
      __value__ = string.lower(checksum)
    }
  end

  file_utils.write_file(path(output_dir, relative_path), content)
end

--- Collect the initial metadata fields.
function validator._collect_metadata()
  local data_metadata = require("___GENERATED__FACTORIO__DATA___.metadata")

  --- @type factorio_mocks_generator.validator.metadata
  local metadata = {
    factorio_version = {
      __meta_order__ = 1,
      __value__ = data_metadata.factorio_version
    },
    generator_version = {
      __meta_order__ = 2,
      __value__ = data_metadata.generator_version
    },
    visibility = {
      __meta_oneline__ = true,
      __meta_order__ = 3,
      __value__ = validator._rules.visibility
    },
    hash_algorithm = {
      __meta_order__ = 4,
      __value__ = _HASH_ALGORITHM
    },
    checksums = {
      __meta_order__ = 5,
      __value__ = {}
    }
  }

  validator._collected_metadata = metadata
end

--- Write the collected metadata to the output directory.
--- @param output_dir string Directory to write the metadata file into
function validator._write_metadata(output_dir)
  if validator._collected_metadata == nil then
    error("No metadata collected, cannot write metadata file")
  end

  file_utils.write_file(
    path(output_dir, "metadata.lua"),
    "return " .. serializer.serialize(validator._collected_metadata) .. "\n"
  )
end

--- Run validation on generated Factorio data against LIVR rules.
--- @param script_output string Path to the Factorio script-output directory containing generated data.
--- @param rules_dir string Path to the directory containing generated LIVR rules.
--- @param output_dir string Output directory for validated data.
--- @param options factorio_mocks_generator.validator.options Additional options for validation.
--- @return boolean has_errors True if any validation errors/failures have occured, false otherwise.
function validator.run_validation(script_output, rules_dir, output_dir, options)
  local filters = options.filters or {}
  filters.data_raw = filters.data_raw or {pattern = nil, type = "lua"}

  validator._options = {
    debug = options.debug or _default_options.debug,
    force = options.force or _default_options.force,
    filters = filters
  }

  validator._load_rules(rules_dir)
  validator._load_generated_data(script_output)
  validator._collect_metadata()

  if not validator._options.debug then
    file_utils.prepare_output_directory(output_dir, validator._options.force)
  end

  validator._emit("suite_start")
  validator._validate_prototype(output_dir)
  validator._emit("suite_end")
  validator._write_metadata(output_dir)

  return validator._has_errors
end

--- Emit a validation event to all subscribers.
--- @param event string Event name to emit
--- @param ... any Additional arguments to pass to the event handlers
function validator._emit(event, ...)
  if validator._subscriber[event] then
    for _, callback in ipairs(validator._subscriber[event]) do
      callback(...)
    end
  end
end

--- Subscribe to validation events.
--- @param event string Event name to subscribe to
--- @param callback fun(...) Callback function to invoke on the event
function validator.subscribe(event, callback)
  if not validator._subscriber[event] then
    validator._subscriber[event] = {}
  end

  table.insert(validator._subscriber[event], callback)
end

--- Just a helper to mark that errors have occured
function validator._on_error_failure()
  validator._has_errors = true
end

validator.subscribe("error", validator._on_error_failure)
validator.subscribe("failure", validator._on_error_failure)

return validator
