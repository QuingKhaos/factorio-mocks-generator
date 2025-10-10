local validator = require("factorio-mocks-generator.validator")
local serpent = require("serpent")

--- TAP (Test Anything Protocol) output for validator results
--- @class factorio_mocks_generator.validator_output.TAP
--- @field private _counter integer
local TAP = {
  _counter = 0
}

local serpent_options = {
  comment = false,
  sortkeys = true,
  nocode = true,
  sparse = false,
  numformat = "%.14g"
}

function TAP.on_suite_start()
  TAP._counter = 0
end

function TAP.on_suite_end()
  io.write("1.." .. TAP._counter .. "\n")
  io.flush()
end

function TAP.on_start()
  TAP._counter = TAP._counter + 1
end

function TAP.on_success(name)
  io.write(string.format("ok %d - %s\n", TAP._counter, name))
  io.flush()
end

function TAP.on_failure(name, errors)
  io.write(string.format("not ok %d - %s\n", TAP._counter, name))
  if errors then
    io.write("# " .. string.gsub(serpent.block(errors, serpent_options), "\n", "\n# ") .. "\n")
  end

  io.flush()
end

function TAP.on_error(name, err)
  io.write(string.format("not ok %d - %s\n", TAP._counter, name))
  if err then
    io.write("# " .. string.gsub(err, "\n", "\n# ") .. "\n")
  end

  io.flush()
end

validator.subscribe("suite_start", TAP.on_suite_start)
validator.subscribe("suite_end", TAP.on_suite_end)
validator.subscribe("start", TAP.on_start)
validator.subscribe("success", TAP.on_success)
validator.subscribe("failure", TAP.on_failure)
validator.subscribe("error", TAP.on_error)
