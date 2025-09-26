-- Factorio Lua 5.2 environment with mod API globals
std = "lua52"

-- Files and directories to check
include_files = {
  "mod/**/*.lua",
  "src/**/*.lua",
  "bin/**/*.lua"
}

-- Specific overrides for different file types
files["mod/**/*.lua"] = {
  globals = {
    "commands",
    "data",
    "defines",
    "feature_flags",
    "game",
    "helpers",
    "log",
    "mods",
    "prototypes",
    "rcon",
    "rendering",
    "remote",
    "serpent",
    "settings",
    "storage",
    "util"
  }
}

files["bin/**/*.lua"] = {
  globals = {"arg"}
}

files["src/**/*.lua"] = {
  globals = {}
}

-- Code quality settings
max_line_length = 120
max_code_line_length = 120
