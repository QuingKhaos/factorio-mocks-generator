local utils = require("factorio-mocks-generator.utils")

--- @class factiorio_mocks_generator.LIVR.rules
local rules = {}

rules = utils.shallow_merge(rules, require("factorio-mocks-generator.LIVR.rules.common"))
rules = utils.shallow_merge(rules, require("factorio-mocks-generator.LIVR.rules.string"))
rules = utils.shallow_merge(rules, require("factorio-mocks-generator.LIVR.rules.numeric"))
rules = utils.shallow_merge(rules, require("factorio-mocks-generator.LIVR.rules.meta"))
rules = utils.shallow_merge(rules, require("factorio-mocks-generator.LIVR.rules.modifiers"))
rules = utils.shallow_merge(rules, require("factorio-mocks-generator.LIVR.rules.extra"))
rules = utils.shallow_merge(rules, require("factorio-mocks-generator.LIVR.rules.custom"))

return rules
