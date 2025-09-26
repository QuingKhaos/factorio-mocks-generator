stds.TEST = {
  globals = {"_TEST"}
}

-- Files and directories to check
include_files = {
  "mod/**/*.lua",
  "src/**/*.lua",
  "bin/**/*.lua",
  "spec/**/*.lua",
  ".busted",
  ".luacheckrc",
  ".luacov",
  "*.rockspec",
}

-- Specific overrides for different file types
files["mod/**/*.lua"] = {
  std = "+TEST",
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
    "script",
    "serpent",
    "settings",
    "storage",
    "util",
  },
}

files["spec/mod/**/*.lua"] = files["mod/**/*.lua"]
files["spec/mod/**/*.lua"].std = "+lua52+TEST"

files["bin/**/*.lua"] = {
  std = "lua52",
  globals = {"arg"},
}

files["src/**/*.lua"] = {
  std = "lua52",
  globals = {},
}

-- Code quality settings
max_line_length = 120
max_code_line_length = 120
