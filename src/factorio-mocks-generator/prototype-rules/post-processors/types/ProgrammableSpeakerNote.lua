local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.ProgrammableSpeakerNote: factorio_mocks_generator.prototype_rules.post_processors.types
local ProgrammableSpeakerNote = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function ProgrammableSpeakerNote.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- One of `sound` or `cyclic_sound` must be defined. Both cannot be defined together.
  new_rules.sound = {
    not_if = {
      "cyclic_sound",
      new_rules.sound,
    }
  }

  -- One of `sound` or `cyclic_sound` must be defined. Both cannot be defined together.
  new_rules.cyclic_sound = {
    not_if = {
      "sound",
      new_rules.cyclic_sound,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return ProgrammableSpeakerNote
