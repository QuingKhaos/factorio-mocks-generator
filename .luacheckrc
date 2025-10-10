stds.TEST = {
  globals = {"_TEST"}
}

-- Files and directories to check
include_files = {
  "bin/**/*.lua",
  "src/**/*.lua",
  "mods/**/*.lua",
  "spec/**/*.lua",
  ".busted",
  ".luacheckrc",
  "*.rockspec",
}

-- Specific overrides for different file types
files["mods/**/*.lua"] = {
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

files["spec/mods/**/*.lua"] = files["mods/**/*.lua"]
files["spec/mods/**/*.lua"].std = "+lua54+TEST"

files["bin/**/*.lua"] = {
  std = "lua54",
}

files["src/**/*.lua"] = {
  std = "lua54+TEST",
}

files["src/**/definitions/**/*.lua"] = files["src/**/*.lua"]
files["src/**/definitions/**/*.lua"].unused = false

files["spec/src/**/*.lua"] = files["src/**/*.lua"]
files["spec/src/**/*.lua"].std = "+lua54+TEST"

files["spec/*.lua"] = {
  std = "lua54",
}

-- Code quality settings
max_line_length = 120
max_comment_line_length = false
max_string_line_length = false
