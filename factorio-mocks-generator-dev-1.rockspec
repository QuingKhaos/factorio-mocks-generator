package = "factorio-mocks-generator"
version = "dev-1"
source = {
  url = "git+https://github.com/QuingKhaos/factorio-mocks-generator.git"
}
description = {
  summary = "Factorio Mocks Generator",
  detailed = [[
    Data Extraction for Mod Testing
  ]],
  homepage = "https://github.com/QuingKhaos/factorio-mocks-generator",
  license = "GPL-3.0"
}
dependencies = {
  "lua >= 5.4",
  "argparse >= 0.7.0",
  "lpath >= 0.4.0",
  "lua-cjson >= 2.1.0",
  "lua-curl >= 0.3.0",
  "lua-hashings-and-nums >= 1.0.0",
  "lua-livr >= 0.5.0",
  "lua-livr-extra >= 0.3.0",
  "regex >= 0.2.0",
  "serpent >= 0.30.0",
  -- dev only dependencies
  "busted",
  "luacheck",
  "luacov",
}
build = {
  type = "builtin",
  modules = {
    -- Nothing to install with dev only file
  }
}
