-- luacheck: no max line length
local AchievementPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.AchievementPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.CreatePlatformAchievementPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.AchievementPrototype
local CreatePlatformAchievementPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function CreatePlatformAchievementPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = AchievementPrototype.process(_, rules)

  return new_rules
end

return CreatePlatformAchievementPrototype
