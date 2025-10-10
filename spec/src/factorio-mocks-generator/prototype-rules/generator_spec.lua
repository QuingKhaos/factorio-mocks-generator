--- @diagnostic disable: invisible
insulate("[#UNIT] prototype-rules.generator", function()
  local generator = require("factorio-mocks-generator.prototype-rules.generator")

  stub(generator, "_load_post_processor_and_process", function(_, _, rules) return rules end)

  describe("_convert_type_to_livr", function()
    describe("simple types", function()
      it("should pass through custom type names as-is", function()
        assert.are.equal("SoundDefinition", generator._convert_type_to_livr("SoundDefinition"))
      end)
    end)

    describe("complex types", function()
      it("should convert array types", function()
        --- @type FactorioPrototypeAPI.Type.Array
        local array_type = {
          complex_type = "array",
          value = "string",
        }

        local result = generator._convert_type_to_livr(array_type)

        assert.is_table(result)
        assert.are.equal("string", result.list_of)
      end)

      it("should convert dictionary types with key validation", function()
        --- @type FactorioPrototypeAPI.Type.Dictionary
        local dict_type = {
          complex_type = "dictionary",
          key = "DirectionString",
          value = "double",
        }

        local result = generator._convert_type_to_livr(dict_type)

        assert.is_table(result)
        assert.is_table(result.dict_of)
        assert.are.equal("DirectionString", result.dict_of.keys)
        assert.are.equal("double", result.dict_of.values)
      end)

      it("should convert literal types", function()
        --- @type FactorioPrototypeAPI.Type.Literal
        local literal_type = {
          complex_type = "literal",
          value = "ambient-sound",
        }

        local result = generator._convert_type_to_livr(literal_type)

        assert.is_table(result)
        assert.are.equal("ambient-sound", result.eq)
      end)

      it("should convert union types with simple options", function()
        --- @type FactorioPrototypeAPI.Type.Union
        local union_type = {
          complex_type = "union",
          options = {"string", "number"},
          full_format = false,
        }

        local result = generator._convert_type_to_livr(union_type)

        assert.is_table(result)
        assert.is_table(result["or"])
        assert.are.equal(2, #result["or"])
        assert.are.equal("string", result["or"][1])
        assert.are.equal("number", result["or"][2])
      end)

      it("should convert union types with literal options", function()
        --- @type FactorioPrototypeAPI.Type.Union
        local union_type = {
          complex_type = "union",
          options = {
            {
              complex_type = "literal",
              value = "default",
            },
            {
              complex_type = "literal",
              value = "custom",
            },
          },
          full_format = false,
        }

        local result = generator._convert_type_to_livr(union_type)

        assert.is_table(result)
        assert.is_table(result["or"])
        assert.are.equal(2, #result["or"])
        assert.is_table(result["or"][1])
        assert.are.equal("default", result["or"][1].eq)
        assert.is_table(result["or"][2])
        assert.are.equal("custom", result["or"][2].eq)
      end)

      it("should convert union types with mixed options", function()
        --- @type FactorioPrototypeAPI.Type.Union
        local union_type = {
          complex_type = "union",
          options = {
            "string",
            {
              complex_type = "literal",
              value = "default",
            },
          },
          full_format = false,
        }

        local result = generator._convert_type_to_livr(union_type)

        assert.is_table(result)
        assert.is_table(result["or"])
        assert.are.equal("string", result["or"][1])
        assert.is_table(result["or"][2])
        assert.are.equal("default", result["or"][2].eq)
      end)

      it("should convert union types with struct options that have properties", function()
        --- @type FactorioPrototypeAPI.Type.Union
        local union_type = {
          complex_type = "union",
          options = {
            {
              complex_type = "struct"
            },
            "ItemID"
          },
          full_format = false
        }

        --- @type FactorioPrototypeAPI.Property[]
        local properties = {
          {
            name = "name",
            order = 0,
            description = "",
            override = false,
            type = "ItemID",
            optional = false
          },
          {
            name = "quality",
            order = 1,
            description = "",
            override = false,
            type = "QualityID",
            optional = true
          },
          {
            name = "comparator",
            order = 2,
            description = "Only loaded if `quality` is defined.",
            override = false,
            type = "ComparatorString",
            optional = true
          }
        }

        local expected = {
          ["or"] = {
            {
              nested_object = {
                name = {"required", "ItemID", {metadata = {order = 0}}},
                quality = {"QualityID", {metadata = {order = 1}}},
                comparator = {"ComparatorString", {metadata = {order = 2}}}
              }
            },
            "ItemID"
          }
        }

        local result = generator._convert_type_to_livr(union_type, properties)
        assert.are.same(expected, result)
      end)

      it("should convert union types with type complex_type options", function()
        --- @type FactorioPrototypeAPI.Type.Union
        local union_type = {
          complex_type = "union",
          options = {
            {
              complex_type = "type",
              value = "ItemProductPrototype",
              description = "Loaded when the `type` is \"item\"."
            },
            {
              complex_type = "type",
              value = "FluidProductPrototype",
              description = "Loaded when the `type` is \"fluid\"."
            },
            {
              complex_type = "type",
              value = "ResearchProgressProductPrototype",
              description = "Loaded when the `type` is \"research-progress\"."
            }
          },
          full_format = true
        }

        local result = generator._convert_type_to_livr(union_type)

        assert.is_table(result)
        assert.is_table(result["or"])
        assert.are.equal(3, #result["or"])

        -- Each option should be converted from the type complex_type to its value
        assert.are.equal("ItemProductPrototype", result["or"][1])
        assert.are.equal("FluidProductPrototype", result["or"][2])
        assert.are.equal("ResearchProgressProductPrototype", result["or"][3])
      end)

      it("should convert tuple types with same element types", function()
        ---@type FactorioPrototypeAPI.Type.Tuple
        local tuple_type = {
          complex_type = "tuple",
          values = {"double", "double", "double", "double"}
        }

        local result = generator._convert_type_to_livr(tuple_type)

        assert.is_table(result)
        assert.is_table(result.tuple_of)
        assert.are.equal(4, #result.tuple_of)
        assert.are.equal("double", result.tuple_of[1])
        assert.are.equal("double", result.tuple_of[2])
        assert.are.equal("double", result.tuple_of[3])
        assert.are.equal("double", result.tuple_of[4])
      end)

      it("should convert tuple types with mixed element types", function()
        ---@type FactorioPrototypeAPI.Type.Tuple
        local tuple_type = {
          complex_type = "tuple",
          values = {"MapPosition", "MapPosition", "RealOrientation"}
        }

        local result = generator._convert_type_to_livr(tuple_type)

        assert.is_table(result)
        assert.is_table(result.tuple_of)
        assert.are.equal(3, #result.tuple_of)
        assert.are.equal("MapPosition", result.tuple_of[1])
        assert.are.equal("MapPosition", result.tuple_of[2])
        assert.are.equal("RealOrientation", result.tuple_of[3])
      end)

      it("should convert struct types with required properties", function()
        --- @type FactorioPrototypeAPI.Type.Struct
        local struct_type = {
          complex_type = "struct"
        }

        local properties = {
          {
            name = "required_field",
            type = "string",
            optional = false
          }
        }

        local result = generator._convert_type_to_livr(struct_type, properties)

        assert.is_table(result)
        assert.is_table(result.nested_object)
        assert.is_table(result.nested_object.required_field)
        assert.are.equal("required", result.nested_object.required_field[1])
        assert.are.equal("string", result.nested_object.required_field[2])
      end)

      it("should convert struct types with optional properties", function()
        --- @type FactorioPrototypeAPI.Type.Struct
        local struct_type = {
          complex_type = "struct"
        }

        local properties = {
          {
            name = "optional_field",
            type = "double",
            optional = true
          }
        }

        local result = generator._convert_type_to_livr(struct_type, properties)

        assert.is_table(result)
        assert.is_table(result.nested_object)
        assert.are.equal("double", result.nested_object.optional_field)
      end)

      it("should convert struct types with mixed property types", function()
        --- @type FactorioPrototypeAPI.Type.Struct
        local struct_type = {
          complex_type = "struct"
        }

        local properties = {
          {
            name = "required_field",
            type = "string",
            optional = false
          },
          {
            name = "optional_field",
            type = "double",
            optional = true
          }
        }

        local result = generator._convert_type_to_livr(struct_type, properties)

        assert.is_table(result)
        assert.is_table(result.nested_object)
        assert.is_table(result.nested_object.required_field)
        assert.are.equal("required", result.nested_object.required_field[1])
        assert.are.equal("string", result.nested_object.required_field[2])
        assert.are.equal("double", result.nested_object.optional_field)
      end)

      it("should convert struct types without properties to any_object", function()
        --- @type FactorioPrototypeAPI.Type.Struct
        local struct_type = {
          complex_type = "struct"
        }

        local result = generator._convert_type_to_livr(struct_type)

        assert.are.equal("any_object", result)
      end)
    end)
  end)

  describe("_collect_all_properties", function()
    it("should collect properties from single prototype without inheritance", function()
      local prototype = {
        name = "TestPrototype",
        properties = {
          {name = "prop1", type = "string", optional = false},
          {name = "prop2", type = "double", optional = true}
        }
      }

      local parent_map = {}
      local result = generator._collect_all_properties(prototype, parent_map)

      assert.are.equal(2, #result)
      assert.are.equal("prop1", result[1].name)
      assert.are.equal("prop2", result[2].name)
    end)

    it("should collect properties from inheritance chain", function()
      local parent_prototype = {
        name = "ParentPrototype",
        properties = {
          {name = "parent_prop", type = "string", optional = false}
        }
      }

      local child_prototype = {
        name = "ChildPrototype",
        parent = "ParentPrototype",
        properties = {
          {name = "child_prop", type = "double", optional = true}
        }
      }

      local parent_map = {
        ParentPrototype = parent_prototype
      }

      local result = generator._collect_all_properties(child_prototype, parent_map)

      assert.are.equal(2, #result)
      assert.are.equal("parent_prop", result[1].name)
      assert.are.equal("child_prop", result[2].name)
    end)

    it("should handle property overrides when override = true", function()
      local parent_prototype = {
        name = "ParentPrototype",
        properties = {
          {name = "shared_prop", type = "string", optional = false, override = false}
        }
      }

      local child_prototype = {
        name = "ChildPrototype",
        parent = "ParentPrototype",
        properties = {
          {name = "shared_prop", type = "integer", optional = true, override = true}
        }
      }

      local parent_map = {
        ParentPrototype = parent_prototype
      }

      local result = generator._collect_all_properties(child_prototype, parent_map)

      assert.are.equal(1, #result)
      assert.are.equal("shared_prop", result[1].name)
      assert.are.equal("integer", result[1].type)
      assert.are.equal(true, result[1].optional)
    end)

    it("should preserve parent properties when override = false", function()
      local parent_prototype = {
        name = "ParentPrototype",
        properties = {
          {name = "preserved_prop", type = "string", optional = false, override = false}
        }
      }

      local child_prototype = {
        name = "ChildPrototype",
        parent = "ParentPrototype",
        properties = {
          {name = "preserved_prop", type = "integer", optional = true, override = false}
        }
      }

      local parent_map = {
        ParentPrototype = parent_prototype
      }

      local result = generator._collect_all_properties(child_prototype, parent_map)

      assert.are.equal(1, #result)
      assert.are.equal("preserved_prop", result[1].name)
      assert.are.equal("string", result[1].type)
      assert.are.equal(false, result[1].optional)
    end)

    it("should combine parent and child properties correctly", function()
      local parent_prototype = {
        name = "ParentPrototype",
        properties = {
          {name = "parent_only", type = "string", optional = false, override = false}
        }
      }

      local child_prototype = {
        name = "ChildPrototype",
        parent = "ParentPrototype",
        properties = {
          {name = "child_only", type = "integer", optional = true, override = false}
        }
      }

      local parent_map = {
        ParentPrototype = parent_prototype
      }

      local result = generator._collect_all_properties(child_prototype, parent_map)

      assert.are.equal(2, #result)
      assert.are.equal("parent_only", result[1].name)
      assert.are.equal("string", result[1].type)
      assert.are.equal("child_only", result[2].name)
      assert.are.equal("integer", result[2].type)
    end)

    describe("inheritance order offset", function()
      it("should apply mathematical offset to orders based on inheritance depth", function()
        local prototype_base = {
          name = "PrototypeBase",
          properties = {
            {name = "type", order = 0, type = "string", optional = false},
            {name = "name", order = 1, type = "string", optional = false}
          }
        }

        local prototype = {
          name = "Prototype",
          parent = "PrototypeBase",
          properties = {
            {name = "factoriopedia_alternative", order = 0, type = "string", optional = true},
            {name = "custom_tooltip_fields",     order = 1, type = "array",  optional = true}
          }
        }

        local item_group = {
          name = "ItemGroup",
          parent = "Prototype",
          properties = {
            {name = "icons", order = 0, type = "array",  optional = true},
            {name = "icon",  order = 1, type = "string", optional = true}
          }
        }

        local parent_map = {
          PrototypeBase = prototype_base,
          Prototype = prototype
        }

        local expected = {
          {name = "type",                      order = 0},    -- PrototypeBase depth 0
          {name = "name",                      order = 1},    -- PrototypeBase depth 0
          {name = "factoriopedia_alternative", order = 1000}, -- Prototype depth 1
          {name = "custom_tooltip_fields",     order = 1001}, -- Prototype depth 1
          {name = "icons",                     order = 2000}, -- ItemGroup depth 2
          {name = "icon",                      order = 2001}  -- ItemGroup depth 2
        }

        local result = generator._collect_all_properties(item_group, parent_map)

        assert.are.equal(6, #result)
        for i, expected_prop in ipairs(expected) do
          assert.are.equal(expected_prop.name, result[i].name)
          assert.are.equal(expected_prop.order, result[i].order)
        end
      end)

      it("should handle deeper inheritance hierarchies with proper offset calculation", function()
        local level_0 = {
          name = "Level0",
          properties = {
            {name = "level0_prop1", order = 0, type = "string"},
            {name = "level0_prop2", order = 1, type = "string"}
          }
        }

        local level_1 = {
          name = "Level1",
          parent = "Level0",
          properties = {
            {name = "level1_prop1", order = 0, type = "string"},
            {name = "level1_prop2", order = 1, type = "string"}
          }
        }

        local level_2 = {
          name = "Level2",
          parent = "Level1",
          properties = {
            {name = "level2_prop1", order = 0, type = "string"},
            {name = "level2_prop2", order = 1, type = "string"}
          }
        }

        local level_3 = {
          name = "Level3",
          parent = "Level2",
          properties = {
            {name = "level3_prop1", order = 0, type = "string"},
            {name = "level3_prop2", order = 1, type = "string"}
          }
        }

        local parent_map = {
          Level0 = level_0,
          Level1 = level_1,
          Level2 = level_2
        }

        local expected = {
          {name = "level0_prop1", order = 0},    -- Level0 depth 0
          {name = "level0_prop2", order = 1},    -- Level0 depth 0
          {name = "level1_prop1", order = 1000}, -- Level1 depth 1
          {name = "level1_prop2", order = 1001}, -- Level1 depth 1
          {name = "level2_prop1", order = 2000}, -- Level2 depth 2
          {name = "level2_prop2", order = 2001}, -- Level2 depth 2
          {name = "level3_prop1", order = 3000}, -- Level3 depth 3
          {name = "level3_prop2", order = 3001}  -- Level3 depth 3
        }

        local result = generator._collect_all_properties(level_3, parent_map)

        assert.are.equal(8, #result)
        for i, expected_prop in ipairs(expected) do
          assert.are.equal(expected_prop.name, result[i].name)
          assert.are.equal(expected_prop.order, result[i].order)
        end
      end)

      it("should preserve original order values when no inheritance exists", function()
        local standalone_prototype = {
          name = "StandalonePrototype",
          properties = {
            {name = "prop1", order = 5,  type = "string"},
            {name = "prop2", order = 10, type = "string"},
            {name = "prop3", order = 2,  type = "string"}
          }
        }

        local parent_map = {}

        local expected = {
          {name = "prop1", order = 5},
          {name = "prop2", order = 10},
          {name = "prop3", order = 2}
        }

        local result = generator._collect_all_properties(standalone_prototype, parent_map)

        assert.are.equal(3, #result)
        for i, expected_prop in ipairs(expected) do
          assert.are.equal(expected_prop.name, result[i].name)
          assert.are.equal(expected_prop.order, result[i].order)
        end
      end)

      it("should preserve parent order for overridden properties to maintain API documentation coherence", function()
        local parent_prototype = {
          name = "ParentPrototype",
          properties = {
            {name = "base_prop",       order = 0, type = "string", optional = false},
            {name = "overridden_prop", order = 1, type = "string", optional = false, override = false}
          }
        }

        local child_prototype = {
          name = "ChildPrototype",
          parent = "ParentPrototype",
          properties = {
            {name = "child_prop",      order = 0, type = "integer", optional = true},
            {name = "overridden_prop", order = 2, type = "integer", optional = true, override = true}
          }
        }

        local parent_map = {
          ParentPrototype = parent_prototype
        }

        local expected = {
          {name = "base_prop",       order = 0,    type = "string",  optional = false}, -- Parent depth 0
          {name = "child_prop",      order = 1000, type = "integer", optional = true},  -- Child depth 1
          {name = "overridden_prop", order = 1,    type = "integer", optional = true}   -- Override preserves parent order 1 (not child order 2 + offset)
        }

        local result = generator._collect_all_properties(child_prototype, parent_map)

        assert.are.equal(3, #result)
        for i, expected_prop in ipairs(expected) do
          assert.are.equal(expected_prop.name, result[i].name)
          assert.are.equal(expected_prop.order, result[i].order)
          assert.are.equal(expected_prop.type, result[i].type)
          assert.are.equal(expected_prop.optional, result[i].optional)
        end
      end)
    end)
  end)

  describe("_extract_prototype_reference", function()
    it("should extract prototype name from standard ID description", function()
      local description = "The name of a [RecipePrototype](prototype:RecipePrototype)."
      local result = generator._extract_prototype_reference(description)

      assert.are.equal("RecipePrototype", result)
    end)

    it("should return nil for descriptions without prototype references", function()
      local description = "Some regular description without links."
      local result = generator._extract_prototype_reference(description)

      assert.is_nil(result)
    end)

    it("should return nil for empty descriptions", function()
      local description = ""
      local result = generator._extract_prototype_reference(description)

      assert.is_nil(result)
    end)

    it("should handle descriptions with different article forms", function()
      local description_a = "The name of a [ItemPrototype](prototype:ItemPrototype)."
      local description_an = "The name of an [EntityPrototype](prototype:EntityPrototype)."

      local result_a = generator._extract_prototype_reference(description_a)
      local result_an = generator._extract_prototype_reference(description_an)

      assert.are.equal("ItemPrototype", result_a)
      assert.are.equal("EntityPrototype", result_an)
    end)
  end)

  describe("_prototype_name_to_lookup_key", function()
    before_each(function()
      generator._prototype_to_typename_map = {
        RecipePrototype = "recipe",
        ActiveTriggerPrototype = {"chain-active-trigger", "delayed-active-trigger"},
        AchievementPrototype = {"achievement", "complete-objective-achievement", "dont-build-entity-achievement"}
      }
    end)

    after_each(function()
      generator._prototype_to_typename_map = {}
    end)

    it("should convert concrete prototypes to single lookup key", function()
      local result = generator._prototype_name_to_lookup_key("RecipePrototype")

      assert.is_string(result)
      assert.are.equal("recipe", result)
    end)

    it("should convert abstract prototypes to array of lookup keys", function()
      local result = generator._prototype_name_to_lookup_key("ActiveTriggerPrototype")

      assert.is_table(result)
      assert.are.equal(2, #result)
      assert.are.equal("chain-active-trigger", result[1])
      assert.are.equal("delayed-active-trigger", result[2])
    end)

    it("should convert concrete prototypes with children to array of lookup keys", function()
      local result = generator._prototype_name_to_lookup_key("AchievementPrototype")

      assert.is_table(result)
      assert.are.equal(3, #result)
      assert.are.equal("achievement", result[1])
      assert.are.equal("complete-objective-achievement", result[2])
      assert.are.equal("dont-build-entity-achievement", result[3])
    end)

    it("should error for unknown prototype names", function()
      assert.has_error(function()
        generator._prototype_name_to_lookup_key("UnknownPrototype")
      end, "Prototype reference 'UnknownPrototype' not found in lookup map. This may indicate corrupted API data.")
    end)
  end)

  describe("_generate_prototype_lookup_map", function()
    after_each(function()
      generator._prototype_to_typename_map = {}
    end)

    it("should populate map correctly with concrete prototypes", function()
      local test_prototypes = {
        {name = "RecipePrototype", typename = "recipe"},
        {name = "ItemPrototype",   typename = "item"},
        {name = "FluidPrototype",  typename = "fluid"}
      }

      generator._generate_prototype_lookup_map(test_prototypes)

      assert.are.equal("recipe", generator._prototype_to_typename_map.RecipePrototype)
      assert.are.equal("item", generator._prototype_to_typename_map.ItemPrototype)
      assert.are.equal("fluid", generator._prototype_to_typename_map.FluidPrototype)
    end)

    it("should map concrete prototypes to single typename", function()
      local test_prototypes = {
        {
          name = "ActiveTriggerPrototype",
          abstract = true
        },
        {
          name = "ChainActiveTriggerPrototype",
          typename = "chain-active-trigger",
          parent = "ActiveTriggerPrototype"
        },
        {
          name = "DelayedActiveTriggerPrototype",
          typename = "delayed-active-trigger",
          parent = "ActiveTriggerPrototype"
        },
        {
          name = "ConcretePrototype",
          typename = "concrete"
        }
      }

      generator._generate_prototype_lookup_map(test_prototypes)

      assert.are.equal("concrete", generator._prototype_to_typename_map.ConcretePrototype)
      assert.are.equal("chain-active-trigger",
        generator._prototype_to_typename_map.ChainActiveTriggerPrototype)
      assert.are.equal("delayed-active-trigger",
        generator._prototype_to_typename_map.DelayedActiveTriggerPrototype)
    end)

    it("should map abstract prototypes to array of children typenames", function()
      local test_prototypes = {
        {
          name = "ActiveTriggerPrototype",
          abstract = true
        },
        {
          name = "ChainActiveTriggerPrototype",
          typename = "chain-active-trigger",
          parent = "ActiveTriggerPrototype"
        },
        {
          name = "DelayedActiveTriggerPrototype",
          typename = "delayed-active-trigger",
          parent = "ActiveTriggerPrototype"
        }
      }

      generator._generate_prototype_lookup_map(test_prototypes)

      local abstract_result = generator._prototype_to_typename_map.ActiveTriggerPrototype
      assert.is_table(abstract_result)
      assert.are.equal(2, #abstract_result)
      assert.are.equal("chain-active-trigger", abstract_result[1])
      assert.are.equal("delayed-active-trigger", abstract_result[2])
    end)

    it("should resolve nested abstract inheritance to all concrete descendants", function()
      local test_prototypes = {
        {name = "BasePrototype",   abstract = true},
        {name = "MiddlePrototype", abstract = true,        parent = "BasePrototype"},
        {name = "ConcreteChild1",  typename = "concrete1", parent = "MiddlePrototype"},
        {name = "ConcreteChild2",  typename = "concrete2", parent = "BasePrototype"}
      }

      generator._generate_prototype_lookup_map(test_prototypes)

      local base_result = generator._prototype_to_typename_map.BasePrototype
      assert.is_table(base_result)
      assert.are.equal(2, #base_result)
      assert.are.equal("concrete1", base_result[1])
      assert.are.equal("concrete2", base_result[2])
    end)

    it("should resolve middle-level abstract prototypes to their concrete children", function()
      local test_prototypes = {
        {name = "BasePrototype",   abstract = true},
        {name = "MiddlePrototype", abstract = true,        parent = "BasePrototype"},
        {name = "ConcreteChild1",  typename = "concrete1", parent = "MiddlePrototype"},
        {name = "ConcreteChild2",  typename = "concrete2", parent = "BasePrototype"}
      }

      generator._generate_prototype_lookup_map(test_prototypes)

      local middle_result = generator._prototype_to_typename_map.MiddlePrototype
      assert.is_table(middle_result)
      assert.are.equal(1, #middle_result)
      assert.are.equal("concrete1", middle_result[1])
    end)

    it("should handle concrete prototypes with children by including own typename plus all descendant typenames",
      function()
        local test_prototypes = {
          {
            name = "AchievementPrototype",
            abstract = false,
            typename = "achievement"
          },
          {
            name = "AchievementPrototypeWithCondition",
            abstract = true,
            parent = "AchievementPrototype"
          },
          {
            name = "CompleteObjectiveAchievementPrototype",
            typename = "complete-objective-achievement",
            parent = "AchievementPrototypeWithCondition"
          },
          {
            name = "DontBuildEntityAchievementPrototype",
            typename = "dont-build-entity-achievement",
            parent = "AchievementPrototypeWithCondition"
          }
        }

        generator._generate_prototype_lookup_map(test_prototypes)

        local achievement_result = generator._prototype_to_typename_map.AchievementPrototype
        assert.is_table(achievement_result)
        assert.are.equal(3, #achievement_result)
        assert.are.equal("achievement", achievement_result[1])
        assert.are.equal("complete-objective-achievement", achievement_result[2])
        assert.are.equal("dont-build-entity-achievement", achievement_result[3])
      end)

    it("should handle abstract middle prototypes by including only children typenames", function()
      local test_prototypes = {
        {
          name = "AchievementPrototype",
          abstract = false,
          typename = "achievement"
        },
        {
          name = "AchievementPrototypeWithCondition",
          abstract = true,
          parent = "AchievementPrototype"
        },
        {
          name = "CompleteObjectiveAchievementPrototype",
          typename = "complete-objective-achievement",
          parent = "AchievementPrototypeWithCondition"
        },
        {
          name = "DontBuildEntityAchievementPrototype",
          typename = "dont-build-entity-achievement",
          parent = "AchievementPrototypeWithCondition"
        }
      }

      generator._generate_prototype_lookup_map(test_prototypes)

      local abstract_result = generator._prototype_to_typename_map.AchievementPrototypeWithCondition
      assert.is_table(abstract_result)
      assert.are.equal(2, #abstract_result)
      assert.are.equal("complete-objective-achievement", abstract_result[1])
      assert.are.equal("dont-build-entity-achievement", abstract_result[2])
    end)

    it("should handle empty prototype array", function()
      local test_prototypes = {}

      generator._generate_prototype_lookup_map(test_prototypes)

      local map_size = 0
      for _ in pairs(generator._prototype_to_typename_map) do
        map_size = map_size + 1
      end

      assert.are.equal(0, map_size)
    end)

    it("should reset map when called multiple times", function()
      local first_prototypes = {
        {name = "FirstPrototype", typename = "first"}
      }

      generator._generate_prototype_lookup_map(first_prototypes)
      assert.are.equal("first", generator._prototype_to_typename_map.FirstPrototype)

      local second_prototypes = {
        {name = "SecondPrototype", typename = "second"}
      }

      generator._generate_prototype_lookup_map(second_prototypes)

      -- First prototype should be gone
      assert.is_nil(generator._prototype_to_typename_map.FirstPrototype)
      assert.are.equal("second", generator._prototype_to_typename_map.SecondPrototype)
    end)

    it("should error on duplicate prototype names", function()
      local test_prototypes = {
        {name = "DuplicatePrototype", typename = "first"},
        {name = "DuplicatePrototype", typename = "second"}
      }

      assert.has_error(function()
        generator._generate_prototype_lookup_map(test_prototypes)
      end, "Duplicate prototype name found: DuplicatePrototype. This may indicate corrupted API data.")
    end)

    it("should not add orphaned abstract prototypes to lookup map", function()
      local test_prototypes = {
        {name = "OrphanedAbstract",  abstract = true}, -- No children at all
        {name = "ConcretePrototype", abstract = false, typename = "concrete"}
      }

      generator._generate_prototype_lookup_map(test_prototypes)

      assert.is_nil(generator._prototype_to_typename_map.OrphanedAbstract)
    end)
  end)

  describe("_convert_property_to_livr", function()
    it("should convert required properties with string type", function()
      local property = {
        name = "required_field",
        type = "string",
        optional = false
      }

      local result = generator._convert_property_to_livr(property)

      assert.is_table(result)
      assert.are.equal(2, #result)
      assert.are.equal("required", result[1])
      assert.are.equal("string", result[2])
    end)

    it("should convert optional properties with string type", function()
      local property = {
        name = "optional_field",
        type = "string",
        optional = true
      }

      local result = generator._convert_property_to_livr(property)

      assert.are.equal("string", result)
    end)

    it("should convert required properties with literal type", function()
      local property = {
        name = "required_complex",
        type = {
          complex_type = "literal",
          value = "test-value"
        },
        optional = false
      }

      local expected = {"required", {eq = "test-value"}}

      local result = generator._convert_property_to_livr(property)
      assert.are.same(expected, result)
    end)

    it("should convert optional properties with complex type", function()
      local property = {
        name = "optional_complex",
        type = {
          complex_type = "array",
          value = "string"
        },
        optional = true
      }

      local result = generator._convert_property_to_livr(property)

      assert.is_table(result)
      assert.are.equal("string", result.list_of)
    end)

    it("should convert required properties with custom type names", function()
      local property = {
        name = "sound_field",
        type = "SoundDefinition",
        optional = false
      }

      local result = generator._convert_property_to_livr(property)

      assert.is_table(result)
      assert.are.equal(2, #result)
      assert.are.equal("required", result[1])
      assert.are.equal("SoundDefinition", result[2])
    end)

    it("should convert optional properties with custom type names", function()
      local property = {
        name = "optional_sound",
        type = "SoundDefinition",
        optional = true
      }

      local result = generator._convert_property_to_livr(property)

      assert.are.equal("SoundDefinition", result)
    end)

    it("should handle properties with union types", function()
      local property = {
        name = "union_field",
        type = {
          complex_type = "union",
          options = {"string", "number"},
          full_format = false
        },
        optional = false
      }

      local result = generator._convert_property_to_livr(property)

      assert.is_table(result)
      assert.are.equal("required", result[1])
      assert.is_table(result[2])
      assert.is_table(result[2]["or"])
      assert.are.equal("string", result[2]["or"][1])
      assert.are.equal("number", result[2]["or"][2])
    end)

    describe("metadata rule", function()
      describe("default value handling", function()
        it("should convert optional properties with literal default value", function()
          local property = {
            name = "optional_with_default",
            type = "string",
            optional = true,
            default = {
              complex_type = "literal",
              value = "default-value"
            }
          }

          local expected = {
            "string",
            {metadata = {default = "default-value"}}
          }

          local result = generator._convert_property_to_livr(property)
          assert.are.same(expected, result)
        end)
      end)

      describe("order handling", function()
        it("should convert optional properties with order value", function()
          local property = {
            name = "ordered_property",
            type = "string",
            optional = true,
            order = 42
          }

          local expected = {
            "string",
            {metadata = {order = 42}}
          }

          local result = generator._convert_property_to_livr(property)
          assert.are.same(expected, result)
        end)

        it("should convert required properties with order value", function()
          local property = {
            name = "required_ordered",
            type = "double",
            optional = false,
            order = 15
          }

          local expected = {
            "required",
            "double",
            {metadata = {order = 15}}
          }

          local result = generator._convert_property_to_livr(property)
          assert.are.same(expected, result)
        end)

        describe("combined default and order handling", function()
          it("should convert properties with both default and order values", function()
            local property = {
              name = "default_and_order",
              type = "string",
              optional = true,
              default = {
                complex_type = "literal",
                value = "test-default"
              },
              order = 7
            }

            local expected = {
              "string",
              {metadata = {default = "test-default", order = 7}}
            }

            local result = generator._convert_property_to_livr(property)
            assert.are.same(expected, result)
          end)

          it("should not include metadata when no default or order is present", function()
            local property = {
              name = "no_metadata",
              type = "string",
              optional = true
            }

            local expected = "string"

            local result = generator._convert_property_to_livr(property)
            assert.are.equal(expected, result)
          end)
        end)
      end)
    end)
  end)

  describe("_generate_type_rule", function()
    it("should generate correct rule for simple type alias", function()
      local test_weight_type = {
        name = "Weight",
        order = 664,
        description = "Weight of an object.",
        abstract = false,
        inline = false,
        type = "double"
      }

      local parent_map = {}
      local result = generator._generate_type_rule(test_weight_type, parent_map)

      assert.are.equal("double", result)
    end)

    it("should generate correct rule for struct type concept with properties", function()
      local struct_type_concept = {
        name = "AgriculturalCraneSpeed",
        order = 10,
        description = "",
        abstract = false,
        inline = false,
        type = {
          complex_type = "struct"
        },
        properties = {
          {
            name = "arm",
            order = 0,
            description = "",
            override = false,
            type = "AgriculturalCraneSpeedArm",
            optional = false
          },
          {
            name = "grappler",
            order = 1,
            description = "",
            override = false,
            type = "AgriculturalCraneSpeedGrappler",
            optional = true
          }
        }
      }

      local parent_map = {}
      local result = generator._generate_type_rule(struct_type_concept, parent_map)

      -- Should generate a nested_object rule with the properties
      assert.is_table(result)
      if result then
        assert.is_table(result.nested_object)
      end
    end)

    it("should generate correct rule for struct type with parent properties only", function()
      local sprite_source = {
        name = "SpriteSourceStub",
        order = 539,
        description = "",
        abstract = false,
        inline = false,
        type = {
          complex_type = "struct"
        },
        properties = {
          {
            name = "filename",
            order = 0,
            description = "The path to the sprite file to use.",
            override = false,
            type = "FileName",
            optional = false
          },
        }
      }

      local effect_texture = {
        name = "EffectTextureStub",
        order = 192,
        description = "",
        parent = "SpriteSourceStub",
        abstract = false,
        inline = false,
        type = {
          complex_type = "struct"
        },
        properties = {}
      }

      local parent_map = {
        SpriteSourceStub = sprite_source
      }

      local result = generator._generate_type_rule(effect_texture, parent_map)

      -- Should generate a nested_object rule with the properties
      assert.is_table(result)
      if result then
        assert.is_table(result.nested_object)
      end
    end)

    describe("builtin type handling", function()
      local parent_map = {}

      it("should return nil for abstract types",
        function()
          local abstract_type = {
            name = "AchievementPrototypeWithCondition",
            order = 2,
            description = "",
            parent = "AchievementPrototype",
            abstract = true,
            deprecated = false,
            properties = {}
          }

          local result = generator._generate_type_rule(abstract_type, parent_map)
          assert.is_nil(result)
        end)

      it("should return nil for boolean builtin type", function()
        local boolean_type = {
          name = "boolean",
          order = 674,
          description = "A variable type which can have one of two values: true or false.",
          abstract = false,
          inline = false,
          type = "builtin"
        }

        local result = generator._generate_type_rule(boolean_type, parent_map)
        assert.is_nil(result)
      end)

      it("should return nil for string builtin type", function()
        local string_type = {
          name = "string",
          order = 681,
          description = "Strings are enclosed in double-quotes.",
          abstract = false,
          inline = false,
          type = "builtin"
        }

        local result = generator._generate_type_rule(string_type, parent_map)
        assert.is_nil(result)
      end)

      it("should return 'decimal' for number/double/float builtin types", function()
        local number_types = {
          {
            name = "number",
            order = 680,
            description = "Any kind of integer or floating point number.",
            abstract = false,
            inline = false,
            type = "builtin"
          },
          {
            name = "double",
            order = 675,
            description = "Format uses a dot as its decimal delimiter.",
            abstract = false,
            inline = false,
            type = "builtin"
          },
          {
            name = "float",
            order = 676,
            description = "Format uses a dot as its decimal delimiter.",
            abstract = false,
            inline = false,
            type = "builtin"
          }
        }

        for _, number_type in ipairs(number_types) do
          local result = generator._generate_type_rule(number_type, parent_map)
          assert.are.equal("decimal", result)
        end
      end)

      it("should return 'integer' for signed integer builtin types", function()
        local integer_types = {
          {
            name = "int8",
            order = 679,
            description = "8 bit signed integer. Ranges from -128 to 127.",
            abstract = false,
            inline = false,
            type = "builtin"
          },
          {
            name = "int16",
            order = 677,
            description = "16 bit signed integer. Ranges from -32 768 to 32 767.",
            abstract = false,
            inline = false,
            type = "builtin"
          },
          {
            name = "int32",
            order = 678,
            description = "32 bit signed integer. Ranges from -2 147 483 648 to 2 147 483 647.",
            abstract = false,
            inline = false,
            type = "builtin"
          }
        }

        for _, integer_type in ipairs(integer_types) do
          local result = generator._generate_type_rule(integer_type, parent_map)
          assert.are.equal("integer", result)
        end
      end)

      it("should return 'unsigned_integer' for unsigned integer builtin types", function()
        local unsigned_types = {
          {
            name = "uint8",
            order = 686,
            description = "8 bit unsigned integer. Ranges from 0 to 255.",
            abstract = false,
            inline = false,
            type = "builtin"
          },
          {
            name = "uint16",
            order = 683,
            description = "16 bit unsigned integer. Ranges from 0 to 65 535.",
            abstract = false,
            inline = false,
            type = "builtin"
          },
          {
            name = "uint32",
            order = 684,
            description = "32 bit unsigned integer. Ranges from 0 to 4 294 967 295.",
            abstract = false,
            inline = false,
            type = "builtin"
          },
          {
            name = "uint64",
            order = 685,
            description = "64 bit unsigned integer. Ranges from 0 to 18 446 744 073 709 551 615.",
            abstract = false,
            inline = false,
            type = "builtin"
          }
        }

        for _, unsigned_type in ipairs(unsigned_types) do
          local result = generator._generate_type_rule(unsigned_type, parent_map)
          assert.are.equal("unsigned_integer", result)
        end
      end)

      it("should return 'any_object' for table builtin type", function()
        local table_type = {
          name = "table",
          order = 682,
          description = "A simple Lua table.",
          abstract = false,
          inline = false,
          type = "builtin"
        }

        local result = generator._generate_type_rule(table_type, parent_map)
        assert.are.equal("any_object", result)
      end)

      it("should error for unknown builtin type", function()
        local unknown_type = {
          name = "unknown_builtin",
          order = 999,
          description = "This is not a real builtin type.",
          abstract = false,
          inline = false,
          type = "builtin"
        }

        assert.has_error(function()
            generator._generate_type_rule(unknown_type, parent_map)
          end,
          "Unknown builtin type encountered: 'unknown_builtin'. This indicates a new builtin type" ..
          " in the Factorio API that needs explicit handling."
        )
      end)
    end)

    describe("with lookup detection", function()
      before_each(function()
        generator._prototype_to_typename_map = {
          RecipePrototype = "recipe",
          ActiveTriggerPrototype = {"chain-active-trigger", "delayed-active-trigger"},
          AchievementPrototype = {"achievement", "complete-objective-achievement"}
        }
      end)

      after_each(function()
        generator._prototype_to_typename_map = {}
      end)

      it("should generate lookup rule for type with concrete prototype reference", function()
        local type_def = {
          name = "RecipeID",
          description = "The name of a [RecipePrototype](prototype:RecipePrototype).",
          type = "string"
        }

        local parent_map = {}
        local result = generator._generate_type_rule(type_def, parent_map)

        assert.is_table(result)
        assert.are.equal(2, #result)

        if result then
          assert.are.equal("string", result[1])
          assert.is_table(result[2])
          assert.are.equal("recipe", result[2].lookup)
        end
      end)

      it("should generate or-lookup rule for type referencing a prototype resolving to multiple typenames", function()
        local type_def = {
          name = "ActiveTriggerID",
          description = "The name of an [ActiveTriggerPrototype](prototype:ActiveTriggerPrototype).",
          type = "string"
        }

        local parent_map = {}
        local result = generator._generate_type_rule(type_def, parent_map)

        assert.is_table(result)
        assert.are.equal(2, #result)

        if result then
          assert.are.equal("string", result[1])
          assert.is_table(result[2])
          assert.is_table(result[2]["or"])
          assert.are.equal(2, #result[2]["or"])

          -- Check that we have lookup rules for both concrete children
          assert.is_table(result[2]["or"][1])
          assert.are.equal("chain-active-trigger", result[2]["or"][1].lookup)
          assert.is_table(result[2]["or"][2])
          assert.are.equal("delayed-active-trigger", result[2]["or"][2].lookup)
        end
      end)

      it("should generate normal rule for type without prototype reference", function()
        local type_def = {
          name = "SomeStringType",
          description = "A regular type.",
          type = "string"
        }

        local parent_map = {}
        local result = generator._generate_type_rule(type_def, parent_map)

        assert.are.equal("string", result)
      end)

      it("should error when prototype reference is not found in lookup map", function()
        local type_def = {
          name = "UnknownID",
          description = "The name of an [UnknownPrototype](prototype:UnknownPrototype).",
          type = "string"
        }

        local parent_map = {}

        assert.has_error(function()
          generator._generate_type_rule(type_def, parent_map)
        end, "Prototype reference 'UnknownPrototype' not found in lookup map. This may indicate corrupted API data.")
      end)
    end)
  end)

  describe("_generate_prototype_rule", function()
    it("should generate correct LIVR rules for complete prototype", function()
      local test_ambient_sound_prototype = {
        name = "AmbientSound",
        order = 7,
        description = "This prototype is used to make sound while playing the game.",
        abstract = false,
        typename = "ambient-sound",
        deprecated = false,
        properties = {
          {
            name = "name",
            order = 1,
            description = "Unique textual identification of the prototype.",
            override = false,
            type = "string",
            optional = false
          },
          {
            name = "planet",
            order = 4,
            description = "Track without a planet is bound to space platforms.",
            override = false,
            type = "SpaceLocationID",
            optional = true
          },
          {
            name = "sound",
            order = 5,
            description = "Static music track.",
            override = false,
            type = "Sound",
            optional = true
          },
          {
            name = "track_type",
            order = 3,
            description = "",
            override = false,
            type = "AmbientSoundType",
            optional = false
          },
          {
            name = "type",
            order = 0,
            description = "Specification of the type of the prototype.",
            override = false,
            type = {
              complex_type = "literal",
              value = "ambient-sound"
            },
            optional = false
          },
          {
            name = "variable_sound",
            order = 6,
            description = "Variable music track.",
            override = false,
            type = "VariableAmbientSoundVariableSound",
            optional = true
          },
          {
            name = "weight",
            order = 2,
            description = "Cannot be less than zero.",
            override = false,
            type = "double",
            optional = true,
            default = {
              complex_type = "literal",
              value = 1
            }
          }
        }
      }

      local parent_map = {}
      local result = generator._generate_prototype_rule(test_ambient_sound_prototype, parent_map)

      -- Verify the expected structure matches the actual generated file
      local expected = {
        name = {"required", "string", {metadata = {order = 1}}},
        planet = {"SpaceLocationID", {metadata = {order = 4}}},
        sound = {"Sound", {metadata = {order = 5}}},
        track_type = {"required", "AmbientSoundType", {metadata = {order = 3}}},
        type = {"required", {eq = "ambient-sound"}, {metadata = {order = 0}}},
        variable_sound = {"VariableAmbientSoundVariableSound", {metadata = {order = 6}}},
        weight = {"double", {metadata = {default = 1, order = 2}}}
      }

      assert.are.same(expected, result)
    end)

    it("should generate bidirectional not_if rules for alt_name properties", function()
      local test_vehicle_prototype = {
        name = "VehiclePrototype",
        typename = "vehicle",
        properties = {
          {
            name = "braking_power",
            alt_name = "braking_force",
            order = 1,
            type = {
              complex_type = "union",
              options = {"Energy", "double"}
            },
            optional = false
          },
          {
            name = "friction",
            alt_name = "friction_force",
            order = 2,
            type = "double",
            optional = false
          }
        }
      }

      local expected = {
        braking_power = {
          not_if = {
            "braking_force",
            {"required", {["or"] = {"Energy", "double"}}, {metadata = {order = 1}}},
          }
        },
        braking_force = {
          not_if = {
            "braking_power",
            {"required", {["or"] = {"Energy", "double"}}, {metadata = {order = 1}}},
          }
        },
        friction = {
          not_if = {
            "friction_force",
            {"required", "double", {metadata = {order = 2}}},
          }
        },
        friction_force = {
          not_if = {
            "friction",
            {"required", "double", {metadata = {order = 2}}},
          }
        }
      }

      local parent_map = {}
      local result = generator._generate_prototype_rule(test_vehicle_prototype, parent_map)

      assert.are.same(expected, result)
    end)
  end)
end)

describe("[#INTEGRATION] prototype-rules.generator", function()
  local generator = require("factorio-mocks-generator.prototype-rules.generator")
  local file_utils = require("factorio-mocks-generator.file-utils")
  local utils = require("factorio-mocks-generator.utils")

  stub(generator, "_load_post_processor_and_process", function(_, _, rules) return rules end)

  local helpers = {
    create_prototype_api_data = function(data)
      return utils.shallow_merge({
        application = "factorio",
        application_version = "2.0.66",
        api_version = 6,
        stage = "prototype",
        prototypes = {},
        types = {}
      }, data)
    end
  }

  local test_ambient_sound_prototype = {
    name = "AmbientSound",
    order = 7,
    description = "This prototype is used to make sound while playing the game.",
    abstract = false,
    typename = "ambient-sound",
    deprecated = false,
    properties = {
      {
        name = "name",
        order = 1,
        description = "Unique textual identification of the prototype.",
        override = false,
        type = "string",
        optional = false
      },
      {
        name = "planet",
        order = 4,
        description = "Track without a planet is bound to space platforms.",
        override = false,
        type = "SpaceLocationID",
        optional = true
      },
      {
        name = "sound",
        order = 5,
        description = "Static music track.",
        override = false,
        type = "Sound",
        optional = true
      },
      {
        name = "track_type",
        order = 3,
        description = "",
        override = false,
        type = "AmbientSoundType",
        optional = false
      },
      {
        name = "type",
        order = 0,
        description = "Specification of the type of the prototype.",
        override = false,
        type = {
          complex_type = "literal",
          value = "ambient-sound"
        },
        optional = false
      },
      {
        name = "variable_sound",
        order = 6,
        description = "Variable music track.",
        override = false,
        type = "VariableAmbientSoundVariableSound",
        optional = true
      },
      {
        name = "weight",
        order = 2,
        description = "Cannot be less than zero.",
        override = false,
        type = "double",
        optional = true,
        default = {
          complex_type = "literal",
          value = 1
        }
      }
    }
  }

  local test_active_trigger_prototype = {
    name = "ActiveTriggerPrototype",
    order = 4,
    description = "The abstract base of all active trigger prototypes.",
    parent = "Prototype",
    abstract = true,
    deprecated = false,
    properties = {}
  }

  local test_chain_active_trigger_prototype = {
    name = "ChainActiveTriggerPrototype",
    order = 41,
    description = "Jumps between targets and applies a Trigger to them.",
    parent = "ActiveTriggerPrototype",
    abstract = false,
    typename = "chain-active-trigger",
    deprecated = false,
    properties = {
      {
        name = "chain_count",
        order = 0,
        description = "Number of times to chain.",
        override = false,
        type = "uint32",
        optional = false
      }
    }
  }

  local test_delayed_active_trigger_prototype = {
    name = "DelayedActiveTriggerPrototype",
    order = 69,
    description = "Delays the delivery of triggered effect by some number of ticks.",
    parent = "ActiveTriggerPrototype",
    abstract = false,
    typename = "delayed-active-trigger",
    deprecated = false,
    properties = {
      {
        name = "delay",
        order = 0,
        description = "Number of ticks to delay the effect.",
        override = false,
        type = "uint32",
        optional = false
      }
    }
  }

  local test_active_trigger_id_type = {
    name = "ActiveTriggerID",
    order = 3,
    description = "The name of an [ActiveTriggerPrototype](prototype:ActiveTriggerPrototype).",
    examples = {
      "```\n\"chain-lightning-chain\"\n```",
      "```\n\"chain-lightning-turret-chain\"\n```"
    },
    abstract = false,
    inline = false,
    type = "string"
  }

  local test_weight_type = {
    name = "Weight",
    order = 664,
    description = "Weight of an object.",
    abstract = false,
    inline = false,
    type = "double"
  }

  local test_double_type = {
    name = "double",
    order = 675,
    description = "Format uses a dot as its decimal delimiter.",
    abstract = false,
    inline = false,
    type = "builtin"
  }

  describe("generate_prototype_rules", function()
    local temp_output_dir = ".tmp/test-rules"

    before_each(function()
      stub(file_utils, "write_file")
    end)

    after_each(function()
      file_utils.write_file --[[@as luassert.spy]]:revert()
    end)

    it("should generate correct prototype file content", function()
      local test_api_data = helpers.create_prototype_api_data({
        prototypes = {test_ambient_sound_prototype}
      })

      generator.generate_prototype_rules(test_api_data, temp_output_dir)

      local expected_prototype_content = [[return {
  name = {
    "required",
    "string",
    {
      metadata = {
        order = 1
      }
    }
  },
  planet = {
    "SpaceLocationID",
    {
      metadata = {
        order = 4
      }
    }
  },
  sound = {
    "Sound",
    {
      metadata = {
        order = 5
      }
    }
  },
  track_type = {
    "required",
    "AmbientSoundType",
    {
      metadata = {
        order = 3
      }
    }
  },
  type = {
    "required",
    {
      eq = "ambient-sound"
    },
    {
      metadata = {
        order = 0
      }
    }
  },
  variable_sound = {
    "VariableAmbientSoundVariableSound",
    {
      metadata = {
        order = 6
      }
    }
  },
  weight = {
    "double",
    {
      metadata = {
        default = 1,
        order = 2
      }
    }
  }
}
]]

      assert.stub(file_utils.write_file --[[@as luassert.spy]]).was.called_with(
        temp_output_dir .. "/prototype/prototypes/AmbientSound.lua",
        expected_prototype_content
      )
    end)

    it("should generate correct type alias file content", function()
      local test_api_data = helpers.create_prototype_api_data({
        types = {test_weight_type}
      })

      generator.generate_prototype_rules(test_api_data, temp_output_dir)

      local expected_weight_content = [[local livr = require("factorio-mocks-generator.LIVR")

livr.register_aliased_default_rule({
  name = "Weight",
  rules = "double"
})
]]

      assert.stub(file_utils.write_file --[[@as luassert.spy]]).was.called_with(
        temp_output_dir .. "/prototype/types/Weight.lua",
        expected_weight_content
      )
    end)

    it("should generate correct builtin type file content", function()
      local test_api_data = helpers.create_prototype_api_data({
        types = {test_double_type}
      })

      generator.generate_prototype_rules(test_api_data, temp_output_dir)

      local expected_double_content = [[local livr = require("factorio-mocks-generator.LIVR")

livr.register_aliased_default_rule({
  name = "double",
  rules = "decimal"
})
]]

      assert.stub(file_utils.write_file --[[@as luassert.spy]]).was.called_with(
        temp_output_dir .. "/prototype/types/double.lua",
        expected_double_content
      )
    end)

    it("should generate correct init.lua file content", function()
      local test_api_data = helpers.create_prototype_api_data({
        prototypes = {test_ambient_sound_prototype},
        types = {test_weight_type, test_double_type}
      })

      generator.generate_prototype_rules(test_api_data, temp_output_dir)

      local expected_init_content = [[require("___GENERATED__FACTORIO__RULES___.prototype.types.Weight")
require("___GENERATED__FACTORIO__RULES___.prototype.types.double")

--- @type LIVR.Rules.Factorio.Prototype
return {
  factorio_version = "2.0.66",
  api_version = 6,
  prototypes = {
    ["ambient-sound"] = {name = "AmbientSound", order = 7, rules = require("___GENERATED__FACTORIO__RULES___.prototype.prototypes.AmbientSound")}
  },
  mods = "Mods",
  settings = "Settings",
  feature_flags = "FeatureFlags",
}
]]

      assert.stub(file_utils.write_file --[[@as luassert.spy]]).was.called_with(
        temp_output_dir .. "/prototype/init.lua",
        expected_init_content
      )
    end)

    it("should call write_file for all generated files", function()
      local test_api_data = helpers.create_prototype_api_data({
        prototypes = {test_ambient_sound_prototype},
        types = {test_weight_type, test_double_type}
      })

      generator.generate_prototype_rules(test_api_data, temp_output_dir)

      -- Verify correct number of files generated
      assert.stub(file_utils.write_file --[[@as luassert.spy]]).was.called(4) -- prototype + 2 types + init
    end)

    it("should exclude abstract prototypes from generated prototypes files", function()
      local test_data = helpers.create_prototype_api_data({
        prototypes = {
          test_active_trigger_prototype,
          test_chain_active_trigger_prototype,
          test_delayed_active_trigger_prototype
        }
      })

      generator.generate_prototype_rules(test_data, temp_output_dir)

      assert.stub(file_utils.write_file --[[@as luassert.spy]]).was.not_called_with(
        temp_output_dir .. "/prototype/prototypes/ActiveTriggerPrototype.lua",
        match._
      )
    end)

    describe("lookup rule generation", function()
      it("should detect lookup rules from concrete prototype references in descriptions", function()
        local recipe_id_type = {
          name = "RecipeID",
          order = 458,
          description = "The name of a [RecipePrototype](prototype:RecipePrototype).",
          examples = {
            "```\n\"electronic-circuit\"\n```",
            "```\n\"kovarex-enrichment-process\"\n```"
          },
          abstract = false,
          inline = false,
          type = "string"
        }

        local recipe_prototype = {
          name = "RecipePrototype",
          order = 29,
          typename = "recipe"
        }

        local test_data = helpers.create_prototype_api_data({
          prototypes = {recipe_prototype},
          types = {recipe_id_type}
        })

        generator.generate_prototype_rules(test_data, temp_output_dir)

        local expected_recipe_id_content = [[local livr = require("factorio-mocks-generator.LIVR")

livr.register_aliased_default_rule({
  name = "RecipeID",
  rules = {
    "string",
    {
      lookup = "recipe"
    }
  }
})
]]

        assert.stub(file_utils.write_file --[[@as luassert.spy]]).was.called_with(
          temp_output_dir .. "/prototype/types/RecipeID.lua",
          expected_recipe_id_content
        )
      end)

      it("should generate or-lookup rules for types with multiple prototype typenames", function()
        local test_data = helpers.create_prototype_api_data({
          prototypes = {
            test_active_trigger_prototype,
            test_chain_active_trigger_prototype,
            test_delayed_active_trigger_prototype
          },
          types = {test_active_trigger_id_type}
        })

        generator.generate_prototype_rules(test_data, temp_output_dir)

        local expected_active_trigger_id_content = [[local livr = require("factorio-mocks-generator.LIVR")

livr.register_aliased_default_rule({
  name = "ActiveTriggerID",
  rules = {
    "string",
    {
      ["or"] = {
        {
          lookup = "chain-active-trigger"
        },
        {
          lookup = "delayed-active-trigger"
        }
      }
    }
  }
})
]]

        assert.stub(file_utils.write_file --[[@as luassert.spy]]).was.called_with(
          temp_output_dir .. "/prototype/types/ActiveTriggerID.lua",
          expected_active_trigger_id_content
        )
      end)

      it("should not generate lookup rules for types without prototype references", function()
        local fluidbox_linked_connection_id_type = {
          name = "FluidBoxLinkedConnectionID",
          order = 231,
          description = "",
          abstract = false,
          inline = false,
          type = "uint32"
        }

        local test_data = helpers.create_prototype_api_data({
          types = {fluidbox_linked_connection_id_type}
        })

        generator.generate_prototype_rules(test_data, temp_output_dir)

        local expected_fluidbox_linked_content = [[local livr = require("factorio-mocks-generator.LIVR")

livr.register_aliased_default_rule({
  name = "FluidBoxLinkedConnectionID",
  rules = "uint32"
})
]]

        assert.stub(file_utils.write_file --[[@as luassert.spy]]).was.called_with(
          temp_output_dir .. "/prototype/types/FluidBoxLinkedConnectionID.lua",
          expected_fluidbox_linked_content
        )
      end)

      it("should generate correct prototype rules for types with lookup dependencies", function()
        local assembling_machine_prototype = {
          name = "AssemblingMachinePrototype",
          order = 19,
          description =
            "An assembling machine - like the assembling machines 1/2/3 in the game, " ..
            "but you can use your own recipe categories.",
          parent = "CraftingMachinePrototype",
          abstract = false,
          typename = "assembling-machine",
          deprecated = false,
          properties = {
            {
              name = "fixed_recipe",
              order = 0,
              description =
                "The preset recipe of this machine. This machine does not show a recipe selection if this is set. " ..
                "The base game uses this for the [rocket silo](https://wiki.factorio.com/Rocket_silo).",
              override = false,
              type = "RecipeID",
              optional = true,
              default = {
                complex_type = "literal",
                value = ""
              }
            }
          }
        }

        local test_data = helpers.create_prototype_api_data({
          prototypes = {assembling_machine_prototype}
        })

        generator.generate_prototype_rules(test_data, temp_output_dir)

        local expected_assembling_machine_content = [[return {
  fixed_recipe = {
    "RecipeID",
    {
      metadata = {
        default = "",
        order = 0
      }
    }
  }
}
]]

        assert.stub(file_utils.write_file --[[@as luassert.spy]]).was.called_with(
          temp_output_dir .. "/prototype/prototypes/AssemblingMachinePrototype.lua",
          expected_assembling_machine_content
        )
      end)
    end)
  end)
end)
