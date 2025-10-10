local utils = require("factorio-mocks-generator.utils")

--- @class factorio_mocks_generator.prototype_rules.post_processors.types.PipeConnectionDefinition: factorio_mocks_generator.prototype_rules.post_processors.types
local PipeConnectionDefinition = {}

--- Process the given type/concept and its associated rules, potentially modifying the rules based on the type/concept.
--- @param rules LIVR.Rule|LIVR.Rule[] The type/concept rules to process
--- @return LIVR.Rule|LIVR.Rule[] # The modified type/concept rules
function PipeConnectionDefinition.process(_, rules)
  --- @type LIVR.Rules
  local new_rules = utils.deepcopy(rules.nested_object)

  -- luacheck: no max line length
  local connection_type_default = new_rules.connection_type[#new_rules.connection_type].metadata.default --[[@as string]]

  -- Only loaded, and mandatory if `connection_type` is `"normal"` or `"underground"`.
  new_rules.direction = {
    ignored_if = {
      {
        connection_type = {{default = connection_type_default}, {eq = "linked"}},
      },
      new_rules.direction,
    }
  }

  -- Only loaded if `connection_type` is `"normal"` or `"underground"`.
  new_rules.position = {
    ignored_if = {
      {
        connection_type = {{default = connection_type_default}, {eq = "linked"}},
      },
      new_rules.position,
    }
  }

  -- Only loaded, and mandatory if `position` is not defined and if `connection_type` is `"normal"` or `"underground"`.
  new_rules.positions = {
    ignored_if = {
      {
        position = {"required"},
        connection_type = {{default = connection_type_default}, {eq = "linked"}},
      },
      new_rules.positions,
    }
  }

  -- Only loaded if `connection_type` is `"normal"` or `"underground"`.
  new_rules.connection_category = {
    ignored_if = {
      {
        connection_type = {{default = connection_type_default}, {eq = "linked"}},
      },
      new_rules.connection_category,
    }
  }

  -- Only loaded if `connection_type` is `"underground"`.
  new_rules.max_underground_distance = {
    ignored_if = {
      {
        connection_type = {{default = connection_type_default}, {one_of = {"normal", "linked"}}},
      },
      new_rules.max_underground_distance,
    }
  }

  -- Only loaded if `connection_type` is `"underground"`.
  new_rules.max_distance_tint = {
    ignored_if = {
      {
        connection_type = {{default = connection_type_default}, {one_of = {"normal", "linked"}}},
      },
      new_rules.max_distance_tint,
    }
  }

  -- Only loaded if `connection_type` is `"underground"`.
  new_rules.underground_collision_mask = {
    ignored_if = {
      {
        connection_type = {{default = connection_type_default}, {one_of = {"normal", "linked"}}},
      },
      new_rules.underground_collision_mask,
    }
  }

  -- Only loaded, and mandatory if `connection_type` is `"linked"`.
  new_rules.linked_connection_id = {
    ignored_if = {
      {
        connection_type = {{default = connection_type_default}, {one_of = {"normal", "underground"}}},
      },
      new_rules.linked_connection_id,
    }
  }

  return {
    nested_object = new_rules,
  }
end

return PipeConnectionDefinition
