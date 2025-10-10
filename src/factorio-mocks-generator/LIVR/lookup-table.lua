--- @class factorio_mocks_generator.LIVR.lookup_table.options
--- @field strict? boolean If true, validation on a missing prototype type table will error.
local _default_options = {
  strict = false
}

--- @class factorio_mocks_generator.LIVR.lookup_table
--- @field private _table? table The loaded lookup table.
--- @field private _options? factorio_mocks_generator.LIVR.lookup_table.options Options for loading and validating the table.
local lookup_table = {
  _table = nil,
  _options = _default_options,
}

--- Load a lookup table reference into the internal state.
--- @param data_raw table The data.raw lookup table to load.
--- @param options? factorio_mocks_generator.LIVR.lookup_table.options Options for loading and validating the table.
function lookup_table.load(data_raw, options)
  if type(data_raw) ~= "table" then
    error("lookup-table.load: expected table, got " .. type(data_raw))
  end

  if next(data_raw) == nil then
    error("lookup-table.load: table cannot be empty, must have at least one prototype type key")
  end

  if options and type(options) ~= "table" then
    error("lookup-table.load: expected options to be a table, got " .. type(options))
  end

  if options and options.strict and type(options.strict) ~= "boolean" then
    error("lookup-table.load: expected options.strict to be a boolean, got " .. type(options.strict))
  end

  local merged_options = {
    strict = options and options.strict or _default_options.strict
  }

  lookup_table._table = data_raw
  lookup_table._options = merged_options
end

--- Get the currently loaded lookup table as reference.
--- @return table? data_raw The loaded lookup table, or nil if no table is loaded.
function lookup_table.get()
  return lookup_table._table
end

--- Unload the currently loaded lookup table and reset options to defaults.
function lookup_table.unload()
  lookup_table._table = nil
  lookup_table._options = {
    strict = _default_options.strict
  }
end

--- Get the current options used for loading and validating the lookup table.
--- @return factorio_mocks_generator.LIVR.lookup_table.options options The current options.
function lookup_table.opts()
  return {
    strict = lookup_table._options.strict
  }
end

return lookup_table
