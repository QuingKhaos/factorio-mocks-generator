--- @meta

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes
local prototype_rules_prototypes_post_processor = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param prototype FactorioPrototypeAPI.Prototype The prototype being processed
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function prototype_rules_prototypes_post_processor.process(prototype, rules) end

--- @class factorio_mocks_generator.prototype_rules.post_processors.types
local prototype_rules_types_post_processor = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param type_concept FactorioPrototypeAPI.TypeConcept The type/concept being processed
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function prototype_rules_types_post_processor.process(type_concept, rules) end
