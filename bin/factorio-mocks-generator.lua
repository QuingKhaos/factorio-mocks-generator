local argparse = require("argparse")
local path = require("path")

local parser = argparse()
parser:command_target("command")

local generate_livr_rules = parser:command("generate-livr-rules")
  :summary("Generate LIVR rules from Factorio JSON API data")
  :description("Generates LIVR rules based on the specified Factorio version's JSON API data.")
generate_livr_rules:argument("factorio_version", "Factorio version to use for generating LIVR rules")
  :args(1)
generate_livr_rules:option("--output-dir", "Output directory for the generated LIVR rules", ".tmp/rules")
  :args(1):count(1)
generate_livr_rules:option("--visibility", "The list of game expansions to include in the generated rules")
  :args("*"):choices({"space_age"})
generate_livr_rules:flag("--force", "Overwrite existing files", false)

local function handle_generate_livr_rules(args)
  print(string.format("Generating LIVR rules for Factorio version: %s", args.factorio_version))
  print(string.format("Output directory: %s", path(args.output_dir)))

  local options = {
    force = args.force,
    visibility = args.visibility or {},
  }

  if #options.visibility > 0 then
    print("Including game expansions: " .. table.concat(options.visibility, ", "))
  end

  require("factorio-mocks-generator.rules-generator").generate_rules_for_version(
    args.factorio_version,
    path(args.output_dir),
    options
  )

  os.exit(0)
end

local validate = parser:command("validate")
  :summary("Validate generated Factorio data against LIVR rules")
  :description("Validates the generated Factorio mock data against the corresponding LIVR rules to ensure correctness.")
validate:argument("script_output", "Path to the Factorio script-output directory containing generated data")
  :args(1)
validate:option("--rules-dir", "Path to the directory containing generated LIVR rules", ".tmp/rules")
  :args(1):count(1)
validate:option("--output-dir", "Output directory for validated data", ".tmp/validated")
  :args(1):count(1)
validate:flag("--force", "Overwrite existing files", false)
validate:flag(
  "--debug",
  "Enable debug output (overwrites files in place, creates pre-serialization data.raw files, skips checksums)",
  false
)
validate:option("--filter-data-raw", "Filter data.raw by prototype type against (defaults to Lua pattern)", "")
  :args(1):count(1)
validate:flag("--filter-data-raw-regex", "Treat --filter-data-raw as a regex", false)
validate:option("-o", "Output format on console for validation messages", "plain-terminal")
  :choices({"plain-terminal", "TAP"}):args(1):count(1)

local function handle_validate(args)
  print(string.format("Validating generated data in: %s", path(args.script_output)))
  print(string.format("Using LIVR rules from: %s", path(args.rules_dir)))
  print(string.format("Output directory for validated data: %s", path(args.output_dir)))

  require("factorio-mocks-generator.validator-output." .. args.o)

  local filters = {}
  if args.filter_data_raw then
    filters.data_raw = {
      pattern = args.filter_data_raw == "" and nil or args.filter_data_raw,
      type = args.filter_data_raw_regex and "regex" or "lua",
    }
  end

  local has_errors = require("factorio-mocks-generator.validator").run_validation(
    path(args.script_output),
    path(args.rules_dir),
    path(args.output_dir),
    {
      debug = args.debug,
      force = args.force,
      filters = filters,
    }
  )

  if has_errors then
    os.exit(1)
  else
    os.exit(0)
  end
end

local args = parser:parse()

if args.command == "generate-livr-rules" then
  handle_generate_livr_rules(args)
elseif args.command == "validate" then
  handle_validate(args)
else
  parser:error("Unknown command: " .. tostring(args.command))
end
