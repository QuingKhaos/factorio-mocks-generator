-- luacheck: no max line length
local TransportBeltConnectablePrototype = require("factorio-mocks-generator.prototype-rules.post-processors.prototypes.TransportBeltConnectablePrototype")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.LoaderPrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes.TransportBeltConnectablePrototype
local LoaderPrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function LoaderPrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = TransportBeltConnectablePrototype.process(_, rules)

  return new_rules
end

return LoaderPrototype
