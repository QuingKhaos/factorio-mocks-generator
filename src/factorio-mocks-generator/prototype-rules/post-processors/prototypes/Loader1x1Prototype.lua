-- luacheck: no max line length
local LoaderPrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.LoaderPrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.Loader1x1Prototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.LoaderPrototype
local Loader1x1Prototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function Loader1x1Prototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = LoaderPrototype.process(_, rules)

  return new_rules
end

return Loader1x1Prototype
