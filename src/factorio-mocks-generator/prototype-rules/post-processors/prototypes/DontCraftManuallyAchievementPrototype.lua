-- luacheck: no max line length
local AchievementPrototypeWithCondition = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.AchievementPrototypeWithCondition")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.DontCraftManuallyAchievementPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.AchievementPrototypeWithCondition
local DontCraftManuallyAchievementPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function DontCraftManuallyAchievementPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = AchievementPrototypeWithCondition.process(_, rules)

  return new_rules
end

return DontCraftManuallyAchievementPrototype
