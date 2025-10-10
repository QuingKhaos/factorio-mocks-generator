local data_raw_generator = require("__factorio-mocks-generator__.prototype.data-raw-generator")
local mods_generator = require("__factorio-mocks-generator__.prototype.mods-generator")
local settings_generator = require("__factorio-mocks-generator__.prototype.settings-generator")
local feature_flags_generator = require("__factorio-mocks-generator__.prototype.feature-flags-generator")

-- fix a few core data issues, which wouldn't pass validation otherwise
require("__factorio-mocks-generator__.data-final-fixes.sticker")
require("__factorio-mocks-generator__.data-final-fixes.turret")
require("__factorio-mocks-generator__.data-final-fixes.unit-spawner")

helpers.remove_path("factorio-mocks-generator")
data_raw_generator(data.raw)
mods_generator(mods)
settings_generator(settings --[[@as data.Settings]])
feature_flags_generator(feature_flags)
