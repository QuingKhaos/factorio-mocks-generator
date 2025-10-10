local validator = require("factorio-mocks-generator.validator")
local serpent = require("serpent")

--- Plain terminal output for validator results
--- @class factorio_mocks_generator.validator_output.plain_terminal
--- @field private _success_counter integer
--- @field private _failure_counter integer
--- @field private _error_counter integer
--- @field private _start_time? number
--- @field private _end_time? number
--- @field private _failures {name: string, errors: table}[]
--- @field private _errors {name: string, err: string}[]
local plain_terminal = {
  _success_counter = 0,
  _failure_counter = 0,
  _error_counter = 0,
  _failures = {},
  _errors = {},
}

local serpent_options = {
  comment = false,
  sortkeys = true,
  nocode = true,
  sparse = false,
  numformat = "%.14g"
}

local successDot = "+"
local failureDot = "-"
local errorDot = "*"

function plain_terminal.on_suite_start()
  plain_terminal._success_counter = 0
  plain_terminal._failure_counter = 0
  plain_terminal._error_counter = 0

  plain_terminal._start_time = os.clock()
end

function plain_terminal.on_suite_end()
  plain_terminal._end_time = os.clock()

  local duration = plain_terminal._end_time - plain_terminal._start_time
  local success_string = plain_terminal._success_counter .. " successes / " ..
    plain_terminal._failure_counter .. " failures / " ..
    plain_terminal._error_counter .. " errors : " ..
    string.gsub(string.format("%.6f", duration), "([0-9])0+$", "%1") .. " seconds"

  io.write("\n" .. success_string .. "\n")

  for _, failure in ipairs(plain_terminal._failures) do
    io.write("\n" .. failure.name .. "\n")
    io.write("# " .. string.gsub(serpent.block(failure.errors, serpent_options), "\n", "\n# ") .. "\n")
  end

  for _, _error in ipairs(plain_terminal._errors) do
    io.write("\n" .. _error.name .. "\n")
    if _error.err then
      io.write("# " .. string.gsub(_error.err, "\n", "\n# ") .. "\n")
    end
  end

  io.flush()
end

function plain_terminal.on_success()
  plain_terminal._success_counter = plain_terminal._success_counter + 1

  io.write(successDot)
  io.flush()
end

function plain_terminal.on_failure(name, errors)
  plain_terminal._failure_counter = plain_terminal._failure_counter + 1
  table.insert(plain_terminal._failures, {name = name, errors = errors})

  io.write(failureDot)
  io.flush()
end

function plain_terminal.on_error(name, err)
  plain_terminal._error_counter = plain_terminal._error_counter + 1
  table.insert(plain_terminal._errors, {name = name, err = err})

  io.write(errorDot)
  io.flush()
end


validator.subscribe("suite_start", plain_terminal.on_suite_start)
validator.subscribe("suite_end", plain_terminal.on_suite_end)
validator.subscribe("success", plain_terminal.on_success)
validator.subscribe("failure", plain_terminal.on_failure)
validator.subscribe("error", plain_terminal.on_error)
