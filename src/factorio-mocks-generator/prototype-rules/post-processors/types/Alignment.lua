local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.Alignment: factorio_mocks_generator.prototype_rules.post_processors.types
local Alignment = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function Alignment.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules)

  -- The Factorio API documentation is missing "middle-right" alignment value
  -- that is actually used in game data (e.g., gui-style default.removed_content_table.column_alignments)
  if new_rules and new_rules["or"] and type(new_rules["or"]) == "table" then
    local has_middle_right = false

    -- Check if "middle-right" is already present
    for _, option in ipairs(new_rules["or"]) do
      if option and option.eq == "middle-right" then
        has_middle_right = true
        break
      end
    end

    -- Add "middle-right" if it's missing
    if not has_middle_right then
      table.insert(new_rules["or"], {eq = "middle-right"})
    end
  end

  return new_rules
end

return Alignment
