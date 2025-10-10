local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.WorkingVisualisations: factorio_mocks_generator.prototype_rules.post_processors.types
local WorkingVisualisations = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function WorkingVisualisations.process(_, rules)
  --- @type LIVR.Rules
  local new_rule = utils.deepcopy(rules.nested_object)

  -- Only loaded if `idle_animation` is defined.
  new_rule.always_draw_idle_animation = {
    ignored_if = {
      {
        idle_animation = "absent",
      },
      new_rule.always_draw_idle_animation,
    }
  }

  -- Only loaded if `shift_animation_waypoints` is defined.
  new_rule.shift_animation_waypoint_stop_duration = {
    ignored_if = {
      {
        shift_animation_waypoints = "absent",
      },
      new_rule.shift_animation_waypoint_stop_duration,
    }
  }

  -- Only loaded if `shift_animation_waypoints` is defined.
  new_rule.shift_animation_transition_duration = {
    ignored_if = {
      {
        shift_animation_waypoints = "absent",
      },
      new_rule.shift_animation_transition_duration,
    }
  }

  return {
    nested_object = new_rule,
  }
end

return WorkingVisualisations
