local default_extractors = require("factorio-mocks-generator.prototype-rules.default-extractors")
local file_utils = require("factorio-mocks-generator.file-utils")
local utils = require("factorio-mocks-generator.utils")
local serpent = require("serpent")

local _serpent_options = {
  indent = "  ",
  comment = false,
  sortkeys = true,
  sparse = false,
  fatal = true,
  fixradix = true,
  nocode = true,
  nohuge = true,
  metatostring = false,
  numformat = "%.14g",
}

--- @class factorio_mocks_generator.prototype_rules.generator.options
--- @field visibility string[] List of game expansions
local _default_options = {
  visibility = {},
}

--- @class factorio_mocks_generator.prototype_rules.generator
--- @field private _prototype_to_typename_map {[string]: string|string[]} Lookup map from prototype names to their concrete typenames
--- @field private _options factorio_mocks_generator.prototype_rules.generator.options The options used for generation
local generator = {
  _prototype_to_typename_map = {},
  _options = utils.deepcopy(_default_options),
}

--- Loads and applies a post-processor module for a given prototype or type, if it exists
--- @param _type "prototypes"|"types" The category of the post-processor
--- @param member FactorioPrototypeAPI.Prototype|FactorioPrototypeAPI.TypeConcept The prototype or type being processed
--- @param rules LIVR.Rules|LIVR.Rule|LIVR.Rule[] The current rules to potentially modify
--- @return LIVR.Rules|LIVR.Rule|LIVR.Rule[] # The potentially modified rules after post-processing
--- @private
function generator._load_post_processor_and_process(_type, member, rules)
  local module = "factorio-mocks-generator.prototype-rules.post-processors." .. _type .. "." .. member.name
  local ok, post_processor = pcall(require, module)

  if ok then
    --- @cast post_processor factorio_mocks_generator.prototype_rules.post_processors.prototypes|factorio_mocks_generator.prototype_rules.post_processors.types
    return post_processor.process(member, rules)
  else
    local module_pattern = string.gsub(module, "%.", "%%.")
    module_pattern = string.gsub(module_pattern, "%-", "%%-")

    local ignore_module_not_found_err = "module '" .. module_pattern .. "' not found"
    if not string.match(post_processor, ignore_module_not_found_err) then
      error(post_processor)
    end
  end

  return rules
end

--- Converts a Factorio API type to LIVR rule format
--- @param api_type FactorioPrototypeAPI.Type The type from Factorio API
--- @param properties? FactorioPrototypeAPI.Property[] Optional properties to populate struct types
--- @param conversion_options? {skip_default: boolean} Options for conversion
--- @return LIVR.Rule livr_rule The LIVR rule representation
--- @private
function generator._convert_type_to_livr(api_type, properties, conversion_options)
  --- @type LIVR.Rule
  local rule = nil

  if type(api_type) == "string" then
    -- Handle the single defines usage as simple type validation
    if api_type == "defines.inventory" then
      rule = "unsigned_integer"
    else
      rule = api_type
    end
  elseif api_type.complex_type == "array" then
    if type(api_type.value) == "table" and api_type.value.complex_type == "struct" and properties then
      rule = {
        list_of_objects = generator
          ._convert_type_to_livr(api_type.value, properties, conversion_options)["nested_object"]
      }
    else
      rule = {list_of = generator._convert_type_to_livr(api_type.value)}
    end
  elseif api_type.complex_type == "dictionary" then
    rule = {
      dict_of = {
        keys = generator._convert_type_to_livr(api_type.key),
        values = generator._convert_type_to_livr(api_type.value),
      }
    }
  elseif api_type.complex_type == "union" then
    local options = {}
    for _, option in ipairs(api_type.options) do
      -- For struct and array options in unions, pass the properties so they can be populated
      if (option.complex_type == "struct" or option.complex_type == "array") and properties then
        table.insert(options, generator._convert_type_to_livr(option, properties, conversion_options))
      else
        table.insert(options, generator._convert_type_to_livr(option))
      end
    end

    rule = {["or"] = options}
  elseif api_type.complex_type == "literal" then
    -- For literals, create an exact match rule using the 'eq' rule
    rule = {eq = api_type.value}
  elseif api_type.complex_type == "type" then
    -- Type with description - just use the inner type
    rule = generator._convert_type_to_livr(api_type.value)
  elseif api_type.complex_type == "tuple" then
    -- Tuples are arrays with specific types at each position
    local tuple_types = {}
    for _, value_type in ipairs(api_type.values) do
      table.insert(tuple_types, generator._convert_type_to_livr(value_type))
    end

    rule = {tuple_of = tuple_types}
  elseif api_type.complex_type == "struct" then
    -- Structs should be populated with properties if available
    if properties and #properties > 0 then
      local struct_rules = {}
      for _, property in ipairs(properties) do
        struct_rules[property.name] = generator._convert_property_to_livr(property, conversion_options)
      end

      rule = {nested_object = struct_rules}
    else
      -- No properties available, return empty object validation
      rule = "any_object"
    end
  end

  return rule
end

--- Converts a property to a LIVR rule, handling all the needed logic
--- @param property FactorioPrototypeAPI.Property The property definition to convert
--- @param options? {skip_default: boolean} Options for conversion
--- @return LIVR.Rule|LIVR.Rule[] livr_rule The LIVR rule(s) for this property
--- @private
function generator._convert_property_to_livr(property, options)
  options = options or {
    skip_default = false,
  }

  --- @type LIVR.Rules.Custom.metadata
  local metadata_rule = nil
  if property.optional and property.default and not options.skip_default then
    local default_value = nil

    if type(property.default) == "table" and property.default.complex_type == "literal" then
      -- Literal default: use the value directly
      default_value = property.default.value
    elseif type(property.default) == "string" then
      default_value = default_extractors.extract_structured_default(property)
      if default_value == nil then
        -- Fallback to textual description with __DESC__ prefix
        default_value = "__DESC__" .. property.default
      end
    end

    if default_value ~= nil then
      metadata_rule = {metadata = {default = default_value}}
    end
  end

  if property.order ~= nil then
    metadata_rule = metadata_rule or {metadata = {}}
    metadata_rule.metadata.order = property.order
  end

  --- @type LIVR.Rule|LIVR.Rule[]
  local rules = generator._convert_type_to_livr(property.type)
  local single_rule = true

  if metadata_rule then
    rules = {rules, metadata_rule}
    single_rule = false
  end

  if not property.optional then
    rules = single_rule and {rules} or rules
    table.insert(rules, 1, "required")
  end

  return rules
end

--- Collects all properties from an inheritance chain (works for both prototypes and types)
--- @param item FactorioPrototypeAPI.Prototype|FactorioPrototypeAPI.TypeConcept The item to collect properties for
--- @param parent_map {[string]: FactorioPrototypeAPI.Prototype|FactorioPrototypeAPI.TypeConcept} Lookup map of item name to item data
--- @return FactorioPrototypeAPI.Property[] all_properties Flattened list of all properties from inheritance chain
--- @private
function generator._collect_all_properties(item, parent_map)
  --- @type FactorioPrototypeAPI.Property[]
  local all_properties = {}

  --- @type {[string]: boolean}
  local property_names = {} -- Track property names to handle overrides

  --- Recursive function to collect properties from parent chain
  --- @param current_item FactorioPrototypeAPI.Prototype|FactorioPrototypeAPI.TypeConcept
  --- @param depth_from_root integer
  local function collect_properties_recursive(current_item, depth_from_root)
    -- First, collect properties from parents (bottom-up inheritance)
    if current_item.parent and parent_map[current_item.parent] then
      collect_properties_recursive(parent_map[current_item.parent], depth_from_root - 1)
    end

    -- Then add/override with current item's properties
    if current_item.properties then
      for _, property in ipairs(current_item.properties) do
        if generator._is_item_visible(property) then
          -- Create a copy of the property to avoid modifying the original
          local property_copy = utils.deepcopy(property)

          -- Apply mathematical offset to order based on depth from root
          if property_copy.order then
            property_copy.order = property_copy.order + (depth_from_root * 1000)
          end

          -- Check if property already exists from parent
          if property_names[property.name] then
            -- Property exists in parent - check if this child property overrides it
            if property.override then
              -- Find and preserve the parent property's order value
              local parent_order = nil
              for i = #all_properties, 1, -1 do
                if all_properties[i].name == property.name then
                  parent_order = all_properties[i].order
                  table.remove(all_properties, i)
                  break
                end
              end

              -- Use parent's order to maintain API documentation coherence
              if parent_order then
                property_copy.order = parent_order
              end

              -- Add the overriding child property with preserved parent order
              table.insert(all_properties, property_copy)
            end

            -- If override = false, keep the parent property (do nothing)
          else
            -- New property not in parent - always add it
            table.insert(all_properties, property_copy)
            property_names[property.name] = true
          end
        end
      end
    end
  end

  --- Calculate the total depth of the inheritance chain
  --- @param current_item FactorioPrototypeAPI.Prototype|FactorioPrototypeAPI.TypeConcept
  --- @return integer depth
  local function calculate_max_depth(current_item)
    local depth = 0
    local current = current_item

    while current.parent and parent_map[current.parent] do
      depth = depth + 1
      current = parent_map[current.parent]
    end

    return depth
  end

  local max_depth = calculate_max_depth(item)
  collect_properties_recursive(item, max_depth)

  return all_properties
end

--- Extracts prototype name from markdown link in description
--- @param description string The description text to parse
--- @return string|nil prototype_name The extracted prototype name, or nil if not found
--- @private
function generator._extract_prototype_reference(description)
  if description == "" then
    return nil
  end

  -- Pattern to match the exact ID type description format
  -- Matches: "The name of a [PrototypeName](prototype:PrototypeName)." or "The name of an [EntityPrototype](prototype:EntityPrototype)."
  local prototype_name = string.match(description, "^The name of an? %[[^%]]+%]%(prototype:([^%)]+)%)%.$")

  return prototype_name
end

--- Maps prototype names to lookup table keys
--- @param prototype_name string The prototype name to map
--- @return string|string[] lookup_key Concrete lookup key(s) for the prototype name
--- @error Throws error if prototype name is not found in lookup map
--- @private
function generator._prototype_name_to_lookup_key(prototype_name)
  local lookup_key = generator._prototype_to_typename_map[prototype_name]
  if not lookup_key then
    error("Prototype reference '" .. prototype_name .. "' not found in lookup map. " ..
      "This may indicate corrupted API data.")
  end

  return lookup_key
end

--- Generates the prototype to typename lookup map from API data
--- @param prototypes FactorioPrototypeAPI.Prototype[] Array of prototype definitions
--- @private
function generator._generate_prototype_lookup_map(prototypes)
  generator._prototype_to_typename_map = {}

  -- Phase 1: Build parent-to-children relationships for inheritance resolution

  --- @type {[string]: FactorioPrototypeAPI.Prototype[]}
  local parent_to_children = {}

  for _, prototype in ipairs(prototypes) do
    if prototype.parent then
      if not parent_to_children[prototype.parent] then
        parent_to_children[prototype.parent] = {}
      end

      table.insert(parent_to_children[prototype.parent], prototype)
    end
  end

  -- Phase 2: Map prototypes to their concrete typenames

  --- Prototypes need to be resolved recursively to collect all children's typenames
  --- @param prototype FactorioPrototypeAPI.Prototype The prototype to resolve
  --- @return string|string[] typenames All resolved typenames for the prototype itself and its children
  local function resolve_typenames(prototype)
    --- @type string|string[]
    local resolved_typenames
    if prototype.typename then
      resolved_typenames = prototype.typename --[[@as string]]
    end

    local children = parent_to_children[prototype.name]
    if children then
      --- @type string[]
      local children_typenames = {}

      for _, child_prototype in ipairs(children) do
        local child_results = resolve_typenames(child_prototype)
        child_results = type(child_results) == "string" and {child_results} or child_results --[=[@as string[]]=]

        for _, typename in ipairs(child_results) do
          table.insert(children_typenames, typename)
        end
      end

      if #children_typenames > 0 then
        if type(resolved_typenames) == "string" then
          -- Merge own typename with children's typenames
          table.insert(children_typenames, resolved_typenames)
        end

        resolved_typenames = children_typenames
      end
    end

    return resolved_typenames
  end

  for _, prototype in ipairs(prototypes) do
    if generator._prototype_to_typename_map[prototype.name] then
      error("Duplicate prototype name found: " .. prototype.name .. ". This may indicate corrupted API data.")
    end

    local resolved_typenames = resolve_typenames(prototype)
    if type(resolved_typenames) == "table" and #resolved_typenames > 0 then
      -- Sort for deterministic output
      table.sort(resolved_typenames)
    end

    if resolved_typenames then
      generator._prototype_to_typename_map[prototype.name] = resolved_typenames
    end
  end
end

--- Generates LIVR rules for a single prototype
--- @param prototype FactorioPrototypeAPI.Prototype The prototype data from API
--- @param parent_map {[string]: FactorioPrototypeAPI.Prototype} Lookup map for inheritance resolution
--- @return LIVR.Rules livr_rules The LIVR rules for this prototype
--- @private
function generator._generate_prototype_rule(prototype, parent_map)
  --- @type LIVR.Rules
  local rules = {}

  -- Collect all properties from inheritance chain
  local all_properties = generator._collect_all_properties(prototype, parent_map)

  -- Add rules for each property
  for _, property in ipairs(all_properties) do
    local property_rules = generator._convert_property_to_livr(property)

    if property.alt_name ~= nil then
      rules[property.name] = {not_if = {property.alt_name, utils.deepcopy(property_rules)}}
      rules[property.alt_name] = {not_if = {property.name, utils.deepcopy(property_rules)}}
    else
      rules[property.name] = property_rules
    end
  end

  if prototype.custom_properties then
    if prototype.custom_properties.key_type ~= "string" then
      error("Unsupported custom_properties key_type '" .. tostring(prototype.custom_properties.key_type) ..
        "' in prototype '" .. prototype.name .. "'. Only 'string' keys are supported.")
    end

    rules["*"] = generator._convert_type_to_livr(prototype.custom_properties.value_type)
  end

  rules = generator._load_post_processor_and_process("prototypes", prototype, rules)

  return rules
end

--- Generates LIVR rules for a single type concept
--- @param type_concept FactorioPrototypeAPI.TypeConcept The type concept data from API
--- @param type_parent_map {[string]: FactorioPrototypeAPI.TypeConcept} Lookup map for inheritance resolution
--- @return (LIVR.Rule|LIVR.Rule[])? livr_rule The LIVR rule(s) for this type, or nil if not applicable
--- @private
function generator._generate_type_rule(type_concept, type_parent_map)
  -- Skip abstract types that don't have concrete implementations
  if type_concept.abstract then
    -- except FeatureFlags, Mods and Settings. They are declared abstract, but used as concrete types during validation
    if type_concept.name ~= "FeatureFlags" and type_concept.name ~= "Mods" and type_concept.name ~= "Settings" then
      return nil
    end
  end

  -- Handle builtin types with proper LIVR rules
  if type_concept.type == "builtin" then
    if type_concept.name == "boolean" then
      -- Skip boolean - it already exists in lua-LIVR-extra
      return nil
    elseif type_concept.name == "string" then
      -- Skip string - it already exists in lua-LIVR
      return nil
    elseif type_concept.name == "number" or type_concept.name == "double" or type_concept.name == "float" then
      return "decimal"
    elseif type_concept.name == "int8" or type_concept.name == "int16" or type_concept.name == "int32" then
      return "integer"
    elseif type_concept.name == "uint8" or type_concept.name == "uint16" or type_concept.name == "uint32" or
      type_concept.name == "uint64" then
      return "unsigned_integer"
    elseif type_concept.name == "table" then
      -- Generic table validation - allows any table structure
      return "any_object"
    elseif type_concept.name == "DataExtendMethod" then
      return "function"
    else
      -- Fail explicitly for unknown builtin types to detect API changes
      error("Unknown builtin type encountered: '" .. type_concept.name ..
        "'. This indicates a new builtin type in the Factorio API that needs explicit handling.")
    end
  end

  --- @type LIVR.Rule|LIVR.Rule[]
  local rules

  -- Handle type aliases (simple types that reference other types)
  if type(type_concept.type) == "string" then
    rules = generator._convert_type_to_livr(type_concept.type)

    -- Check if this is an ID type with a prototype reference
    if type_concept.description then
      local prototype_name = generator._extract_prototype_reference(type_concept.description)
      if prototype_name then
        rules = {rules}

        local lookup_key = generator._prototype_name_to_lookup_key(prototype_name)
        if type(lookup_key) == "string" then
          table.insert(rules, {lookup = lookup_key})
        else
          local or_options = {}
          for _, typename in ipairs(lookup_key) do
            table.insert(or_options, {lookup = typename})
          end

          table.insert(rules, {["or"] = or_options})
        end
      end
    end
  else
    local options = {
      skip_default = false,
    }

    -- Collect all properties from inheritance chain
    local all_properties = generator._collect_all_properties(type_concept, type_parent_map)

    -- Style specifications have their own inheritance system and should not show default values.
    if string.match(type_concept.name, "Specification$") then
      for _, property in ipairs(all_properties) do
        if property.name == "parent" then
          options.skip_default = true
          break
        end
      end
    -- Special case: ElementImageSetLayer is only used within gui styles and should not show default values.
    elseif type_concept.name == "ElementImageSetLayer" then
      options.skip_default = true
    -- Another set of special property inheritance during runtime, thus rendering defaults is rather useless.
    elseif type_concept.name == "TileSpriteLayoutVariant" or type_concept.name == "TileTransitionSpritesheetLayout" or
      type_concept.name == "TileTransitionVariantLayout" or type_concept.name == "TileTransitions" or
      type_concept.name == "TileTransitionsBetweenTransitions" or type_concept.name == "TileTransitionsToTiles" then
      options.skip_default = true
    end

    rules = generator._convert_type_to_livr(type_concept.type, all_properties, options)
  end

  rules = generator._load_post_processor_and_process("types", type_concept, rules)

  return rules
end

--- Generates all type definition rules from API data
--- @param types FactorioPrototypeAPI.TypeConcept[] Array of type concept definitions
--- @return {[string]: LIVR.Rules} type_rules Map of type names to their LIVR rules
--- @private
function generator._generate_all_type_rules(types)
  local all_rules = {}

  -- Create parent lookup map for efficient inheritance resolution
  local type_parent_map = {}
  for _, type_concept in ipairs(types) do
    if type_concept.name then
      type_parent_map[type_concept.name] = type_concept
    end
  end

  for _, type_concept in ipairs(types) do
    local rules = generator._generate_type_rule(type_concept, type_parent_map)
    if rules then
      all_rules[type_concept.name] = rules
    end
  end

  return all_rules
end

--- Generates all prototype rules from API data
--- @param prototypes FactorioPrototypeAPI.Prototype[] Array of prototype definitions
--- @return {[string]: {typename: string, rules: LIVR.Rules}} prototype_rules Map of prototype names to their typename and LIVR rules
--- @private
function generator._generate_all_prototype_rules(prototypes)
  local all_rules = {}

  -- Create parent lookup map for efficient inheritance resolution
  local parent_map = {}
  for _, prototype in ipairs(prototypes) do
    if prototype.name then
      parent_map[prototype.name] = prototype
    end
  end

  for _, prototype in ipairs(prototypes) do
    -- Skip abstract prototypes as they can't be instantiated
    if not prototype.abstract and prototype.typename then
      if generator._is_item_visible(prototype) then
        all_rules[prototype.name] = {
          typename = prototype.typename,
          rules = generator._generate_prototype_rule(prototype, parent_map)
        }
      end
    end
  end

  return all_rules
end

--- Checks if a prototype or property is visible based on the configured visibility options
--- @param item FactorioPrototypeAPI.Prototype|FactorioPrototypeAPI.Property The item to check visibility for
--- @return boolean is_visible True if the item is visible, false otherwise
function generator._is_item_visible(item)
  if not item.visibility or #item.visibility == 0 then
    return true -- Always include vanilla content (no visibility restrictions)
  end

  -- Include only if ALL of the item's required expansions are allowed in the options
  for _, required_expansion in ipairs(item.visibility) do
    local found = false
    for _, target_expansion in ipairs(generator._options.visibility) do
      if required_expansion == target_expansion then
        found = true
        break
      end
    end

    if not found then
      return false -- Missing a required expansion
    end
  end

  return true -- All required expansions are available
end

--- Generates LIVR rules for the prototype stage.
--- @param api_data FactorioPrototypeAPI Decoded prototype API JSON data
--- @param output_dir string Directory to save generated LIVR rules
--- @param options? factorio_mocks_generator.prototype_rules.generator.options Options for generation
function generator.generate_prototype_rules(api_data, output_dir, options)
  options = utils.deepcopy(options) or {}
  generator._options.visibility = options.visibility or utils.deepcopy(_default_options.visibility)

  if api_data.api_version ~= 6 then
    error("Unsupported Factorio API version: " .. tostring(api_data.api_version) .. ". Only version 6 is supported.")
  end

  output_dir = output_dir .. "/prototype"

  generator._generate_prototype_lookup_map(api_data.prototypes)
  local prototype_rules = generator._generate_all_prototype_rules(api_data.prototypes)

  -- Create lookup map for prototype order values
  local prototype_order_map = {}
  for _, prototype in ipairs(api_data.prototypes) do
    if not prototype.abstract and prototype.typename then
      prototype_order_map[prototype.name] = prototype.order or "zzz" -- Default to end if no order
    end
  end

  -- Generate separate file for each prototype type
  local requires_list = {}
  for prototype_name, prototype_data in pairs(prototype_rules) do
    local prototype_file = "prototypes/" .. prototype_name .. ".lua"
    local prototype_content = "return " .. serpent.block(prototype_data.rules, _serpent_options) .. "\n"

    file_utils.write_file(output_dir .. "/" .. prototype_file, prototype_content)
    table.insert(requires_list, {
      prototype_name = prototype_name,
      typename = prototype_data.typename,
      order = prototype_order_map[prototype_name] or "zzz"
    })
  end

  -- Sort requires_list by order field for deterministic output
  table.sort(requires_list, function(a, b)
    return a.order < b.order
  end)

  local sorted_requires = {}
  for _, item in ipairs(requires_list) do
    table.insert(sorted_requires,
      string.format(
        -- luacheck: no max line length
        '    ["%s"] = {name = "%s", order = %d, rules = require("___GENERATED__FACTORIO__RULES___.prototype.prototypes.%s")}',
        item.typename, item.prototype_name, item.order, item.prototype_name
      ))
  end

  local type_rules = generator._generate_all_type_rules(api_data.types)

  -- Create lookup map for type order values
  local type_order_map = {}
  for _, type_concept in ipairs(api_data.types) do
    if type_rules[type_concept.name] then
      type_order_map[type_concept.name] = type_concept.order or "zzz"
    end
  end

  -- Generate separate file for each type definition
  local type_requires_list = {}
  for typename, rules in pairs(type_rules) do
    local type_file = "types/" .. typename .. ".lua"
    local type_content = string.format(
      'local livr = require("factorio-mocks-generator.LIVR")\n\nlivr.register_aliased_default_rule(%s)\n',
      serpent.block({name = typename, rules = rules}, _serpent_options)
    )

    file_utils.write_file(output_dir .. "/" .. type_file, type_content)
    table.insert(type_requires_list, {
      typename = typename,
      order = type_order_map[typename] or "zzz"
    })
  end

  -- Sort type requires by order for deterministic output
  table.sort(type_requires_list, function(a, b)
    return a.order < b.order
  end)

  local sorted_type_requires = {}
  for _, item in ipairs(type_requires_list) do
    table.insert(sorted_type_requires,
      string.format('require("___GENERATED__FACTORIO__RULES___.prototype.types.%s")', item.typename))
  end

  local template = file_utils.read_file("src/factorio-mocks-generator/templates/rules/prototype/init.lua")
  local prototype_requires = table.concat(sorted_requires, ",\n")
  local types_code = table.concat(sorted_type_requires, "\n")

  local output = template
  output = string.gsub(output, "factorio_version = nil",
    string.format('factorio_version = "%s"', api_data.application_version))
  output = string.gsub(output, "api_version = nil", string.format("api_version = %d", api_data.api_version))
  output = string.gsub(output, "%-%-prototypes%-%-", prototype_requires)
  output = string.gsub(output, "%-%-types%-%-", types_code)

  file_utils.write_file(output_dir .. "/init.lua", output)
end

return generator
