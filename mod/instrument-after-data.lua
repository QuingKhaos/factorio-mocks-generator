helpers.remove_path("factorio-mocks-generator")

local enable_stable_split = settings.startup["factorio-mocks-generator-enable-stable-split"]

require("prototype.data-raw-generator")(data.raw, enable_stable_split --[[@as data.ModSetting]])
require("prototype.mods-generator")(mods)
require("prototype.settings-generator")(settings --[[@as data.Settings]])
require("prototype.feature-flags-generator")(feature_flags)
