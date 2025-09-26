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
  "lua >= 5.2",
  "busted",
  "luacheck",
  "luacov",
  "serpent",
}
build = {
  type = "builtin",
  modules = {
    -- Nothing to install with dev only file
  }
}
