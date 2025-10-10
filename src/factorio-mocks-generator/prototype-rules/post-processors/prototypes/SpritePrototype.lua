local shared = require("factorio-mocks-generator.prototype-rules.post-processors.shared")

--- @class factorio_mocks_generator.prototype_rules.post_processors.prototypes.SpritePrototype: factorio_mocks_generator.prototype_rules.post_processors.prototypes
local SpritePrototype = {}

--- Process the given prototype and its associated rules, potentially modifying the rules based on the prototype.
--- @param rules LIVR.Rules The prototype rules to process
--- @return LIVR.Rules # The modified prototype rules
function SpritePrototype.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = shared.ignore_all_if_layers(rules, {
    name = true,
    type = true,
  })

  -- Loaded only when `x` and `y` are both `0`.
  new_rules.position.ignored_if[2][#(new_rules.position.ignored_if[2])].metadata.oneline = true
  new_rules.position.ignored_if[1] = {
    layers = "required",
    x = {{default = 0}, {min_number = 1}},
    y = {{default = 0}, {min_number = 1}},
  }

  -- Only loaded if this is an icon, that is it has the flag `"group=icon"` or `"group=gui"`.
  new_rules.mipmap_count = {
    ignored_if = {
      {
        flags = {not_contains = {"icon", "gui", "gui-icon", "group=icon", "group=gui"}},
      },
      new_rules.mipmap_count,
    }
  }

  -- Unused
  new_rules.generate_sdf = {
    ignored_if = {{generate_sdf = "boolean"}, {}}
  }

  return new_rules
end

return SpritePrototype
