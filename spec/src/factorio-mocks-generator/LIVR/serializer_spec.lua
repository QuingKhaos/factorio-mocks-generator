--- @diagnostic disable: invisible
insulate("[#INTEGRATION] LIVR.serializer", function()
  local serializer = require("factorio-mocks-generator.LIVR.serializer")

  describe("serialize", function()
    it("should serialize complex metadata rich tables", function()
      local complex_metadata_table = {
        item = {
          ["iron-gear-wheel"] = {
            name = {
              __meta_order__ = 1,
              __value__ = "iron-gear-wheel"
            },
            order = {
              __meta_order__ = 2,
              __value__ = "a[basic-intermediates]-a[iron-gear-wheel]"
            },
            random_tint_color = {
              __meta_oneline__ = true,
              __meta_order__ = 2039,
              __value__ = {
                a = {
                  __meta_default__ = 1,
                  __meta_order__ = 3
                },
                b = {
                  __meta_default__ = 0,
                  __meta_order__ = 2
                },
                g = {
                  __meta_default__ = 0,
                  __meta_order__ = 1
                },
                r = {
                  __meta_default__ = 0,
                  __meta_order__ = 0
                }
              }
            },
            subgroup = {
              __meta_order__ = 6,
              __value__ = "intermediate-product"
            },
            type = {
              __meta_order__ = 0,
              __value__ = "item"
            }
          },
        },
        recipe = {
          ["iron-gear-wheel"] = {
            category = {
              __meta_default__ = "crafting",
              __meta_order__ = 2000
            },
            energy_required = {
              __meta_default__ = 0.5,
              __meta_order__ = 2009
            },
            hidden = {
              __meta_default__ = false,
              __meta_order__ = 7
            },
            hidden_in_factoriopedia = {
              __meta_default__ = "__DESC__Value of `hidden`",
              __meta_order__ = 8
            },
            icon_size = {
              __meta_default__ = 64,
              __meta_order__ = 2005
            },
            ingredients = {
              __meta_order__ = 2006,
              __value__ = {
                {
                  amount = {
                    __meta_order__ = 2,
                    __value__ = 2
                  },
                  name = {
                    __meta_order__ = 1,
                    __value__ = "iron-plate"
                  },
                  type = {
                    __meta_order__ = 0,
                    __value__ = "item"
                  }
                }
              }
            },
            maximum_productivity = {
              __meta_default__ = 3,
              __meta_order__ = 2011
            },
            name = {
              __meta_order__ = 1,
              __value__ = "iron-gear-wheel"
            },
            order = {
              __meta_default__ = "",
              __meta_order__ = 2
            },
            results = {
              __meta_order__ = 2007,
              __value__ = {
                {
                  amount = {
                    __meta_order__ = 2,
                    __value__ = 1
                  },
                  name = {
                    __meta_order__ = 1,
                    __value__ = "iron-gear-wheel"
                  },
                  type = {
                    __meta_order__ = 0,
                    __value__ = "item"
                  }
                }
              }
            },
            type = {
              __meta_order__ = 0,
              __value__ = "recipe"
            },
          },
        },
      }

      local result = serializer.serialize(complex_metadata_table)

      assert.is_string(result)
      assert.is.equal('{\
  item = {\
    ["iron-gear-wheel"] = {\
      type = "item",\
      name = "iron-gear-wheel",\
      order = "a[basic-intermediates]-a[iron-gear-wheel]",\
      subgroup = "intermediate-product",\
      random_tint_color = {--[[r = 0, g = 0, b = 0, a = 1]]},\
    },\
  },\
  recipe = {\
    ["iron-gear-wheel"] = {\
      type = "recipe",\
      name = "iron-gear-wheel",\
    --order = "",\
    --hidden = false,\
    --hidden_in_factoriopedia = [[Value of `hidden`]],\
    --category = "crafting",\
    --icon_size = 64,\
      ingredients = {\
        {\
          type = "item",\
          name = "iron-plate",\
          amount = 2,\
        },\
      },\
      results = {\
        {\
          type = "item",\
          name = "iron-gear-wheel",\
          amount = 1,\
        },\
      },\
    --energy_required = 0.5,\
    --maximum_productivity = 3,\
    },\
  },\
}', result)
    end)

    describe("_sortkeys_by_meta_order", function()
      local original_formatter = serializer._serpent_options.custom

      setup(function()
        -- Disable custom formatter for dedicated sortkeys testing
        serializer._serpent_options.custom = nil
      end)

      teardown(function()
        serializer._serpent_options.custom = original_formatter
      end)

      it("should sort properties by __meta_order__ values and unwrap __value__", function()
        local data_with_order = {
          property_bar = {
            __meta_order__ = 2000,
            __value__ = "third"
          },
          property_foo = {
            __meta_order__ = 1000,
            __value__ = "first"
          },
          property_acme = {
            __meta_order__ = 1500,
            __value__ = "second"
          }
        }

        local result = serializer.serialize(data_with_order)

        assert.is_string(result)
        assert.is.equal([[{
  property_foo = "first",
  property_acme = "second",
  property_bar = "third"
}]], result)
      end)

      it("should sort nested properties by __meta_order__ and top-level keys alphabetically", function()
        local data_with_nested_order = {
          zebra_container = {
            prop_bar = {
              __meta_order__ = 2,
              __value__ = "zebra_second"
            },
            prop_foo = {
              __meta_order__ = 1,
              __value__ = "zebra_first"
            }
          },
          alpha_container = {
            child_bar = {
              __meta_order__ = 3,
              __value__ = "alpha_last"
            },
            child_foo = {
              __meta_order__ = 1,
              __value__ = "alpha_first"
            },
            child_acme = {
              __meta_order__ = 2,
              __value__ = "alpha_middle"
            }
          }
        }

        local result = serializer.serialize(data_with_nested_order)

        assert.is_string(result)
        assert.is.equal([[{
  alpha_container = {
    child_foo = "alpha_first",
    child_acme = "alpha_middle",
    child_bar = "alpha_last"
  },
  zebra_container = {
    prop_foo = "zebra_first",
    prop_bar = "zebra_second"
  }
}]], result)
      end)

      it("should preserve __meta_default__ values for custom formatter", function()
        local data_with_defaults_and_values = {
          property_bar = {
            __meta_order__ = 2000,
            __meta_default__ = "default_third"
          },
          property_foo = {
            __meta_order__ = 1000,
            __value__ = "actual_first"
          },
          property_acme = {
            __meta_order__ = 1500,
            __meta_default__ = "default_second"
          }
        }

        local result = serializer.serialize(data_with_defaults_and_values)

        assert.is_string(result)
        assert.is.equal([[{
  property_foo = "actual_first",
  property_acme = {
    __meta_default__ = "default_second"
  },
  property_bar = {
    __meta_default__ = "default_third"
  }
}]], result)
      end)

      it("should preserve __meta_oneline__ instruction for custom formatter", function()
        local data_with_defaults_and_values = {
          property_bar = {
            __meta_oneline__ = true,
            __meta_order__ = 2000,
            __value__ = {
              a = 1,
              b = 2,
              c = 3
            }
          },
          property_foo = {
            __meta_order__ = 1000,
            __value__ = "actual_first"
          },
        }

        local result = serializer.serialize(data_with_defaults_and_values)

        assert.is_string(result)
        assert.is.equal([[{
  property_foo = "actual_first",
  property_bar = {
    __meta_oneline__ = true,
    __value__ = {
      a = 1,
      b = 2,
      c = 3
    }
  }
}]], result)
      end)

      it("should fail fast when __meta_order__ is missing in comparison", function()
        local data_with_missing_order = {
          property_foo = {
            __meta_order__ = 1000,
            __value__ = "first"
          },
          property_bar = "missing_order"
        }

        assert.has_error(function()
          serializer.serialize(data_with_missing_order)
        end, "Missing __meta_order__ in property: property_bar")
      end)

      it("should preserve array key order for pure arrays", function()
        local data_with_array = {
          color_values = {1.0, 0.5, 0.2, 0.8}
        }

        local result = serializer.serialize(data_with_array)

        assert.is_string(result)
        assert.is.equal([[{
  color_values = {
    1,
    0.5,
    0.2,
    0.8
  }
}]], result)
      end)

      it("should fail fast when mixing array and object keys", function()
        local data_with_mixed_keys = {
          mixed_structure = {
            [1] = "array_value",
            property_name = "object_value"
          }
        }

        assert.has_error(function()
          serializer.serialize(data_with_mixed_keys)
        end, "Cannot mix array indices and object keys")
      end)
    end)

    describe("_custom_formatter", function()
      local original_sortkeys = serializer._serpent_options.sortkeys

      setup(function()
        -- Override sortkeys with default alphabetical sorting for dedicated formatter testing
        serializer._serpent_options.sortkeys = true
      end)

      teardown(function()
        serializer._serpent_options.sortkeys = original_sortkeys
      end)

      describe("_meta_default_formatter should convert default values to comments", function()
        local original_formatter = serializer._serpent_options.custom

        setup(function()
          -- Override custom formatter with meta default formatter only for dedicated testing
          serializer._serpent_options.custom = function(tag, head, body, tail, level)
            tag, head, body, tail = serializer._meta_default_formatter(tag, head, body, tail, level)

            return tag .. head .. body .. tail
          end
        end)

        teardown(function()
          serializer._serpent_options.custom = original_formatter
        end)

        it("with top-level default value as first key", function()
          local data_with_defaults = {
            field_with_default = {
              __meta_default__ = "default_value",
            },
            normal_field = "regular_value",
          }

          local result = serializer.serialize(data_with_defaults)

          assert.is_string(result)
          assert.is.equal([[{
--field_with_default = "default_value",
  normal_field = "regular_value"
}]], result)
        end)

        it("with top-level default value", function()
          local data_with_defaults = {
            a_normal_field = "regular_value",
            field_with_default = {
              __meta_default__ = "default_value",
            },
          }

          local result = serializer.serialize(data_with_defaults)

          assert.is_string(result)
          assert.is.equal([[{
  a_normal_field = "regular_value",
--field_with_default = "default_value"
}]], result)
        end)

        it("with string default value", function()
          local data_with_defaults = {
            nested_structure = {
              field_with_default = {
                __meta_default__ = "default_value",
              },
              normal_field = "regular_value",
            },
          }

          local result = serializer.serialize(data_with_defaults)

          assert.is_string(result)
          assert.is.equal([[{
  nested_structure = {
  --field_with_default = "default_value",
    normal_field = "regular_value"
  }
}]], result)
        end)

        it("with numeric default value", function()
          local data_with_defaults = {
            nested_structure = {
              field_with_default = {
                __meta_default__ = 42,
              },
              normal_field = "regular_value",
            },
          }

          local result = serializer.serialize(data_with_defaults)

          assert.is_string(result)
          assert.is.equal([[{
  nested_structure = {
  --field_with_default = 42,
    normal_field = "regular_value"
  }
}]], result)
        end)

        it("with description default value", function()
          local data_with_defaults = {
            nested_structure = {
              field_with_default = {
                __meta_default__ = "__DESC__The \"smoke-building\"-smoke",
              },
              normal_field = "regular_value",
            },
          }

          local result = serializer.serialize(data_with_defaults)

          assert.is_string(result)
          assert.is.equal('{\
  nested_structure = {\
  --field_with_default = [[The "smoke-building"-smoke]],\
    normal_field = "regular_value"\
  }\
}', result)
        end)

        it("with table default value", function()
          local data_with_defaults = {
            nested_structure = {
              color = {
                __meta_default__ = {r = 1, g = 1, b = 1, a = 1},
              },
              normal_field = "regular_value",
            },
          }

          local result = serializer.serialize(data_with_defaults)

          assert.is_string(result)
          assert.is.equal([[{
  nested_structure = {
  --color = {a = 1, b = 1, g = 1, r = 1},
    normal_field = "regular_value"
  }
}]], result)
        end)

        it("with nested table default value", function()
          local data_with_defaults = {
            nested_structure = {
              collision_box = {
                __meta_default__ = {{0, 0}, {0, 0}},
              },
              normal_field = "regular_value",
            },
          }

          local result = serializer.serialize(data_with_defaults)

          assert.is_string(result)
          assert.is.equal([[{
  nested_structure = {
  --collision_box = {{0, 0}, {0, 0}},
    normal_field = "regular_value"
  }
}]], result)
        end)

        it("and have consistent indentation", function()
          local data_with_defaults = {
            ["so-long-and-thanks-for-all-the-fish"] = {
              allowed_without_fight = {
                __meta_default__ = true
              },
              hidden = {
                __meta_default__ = false
              },
              icon = "__base__/graphics/achievement/so-long-and-thanks-for-all-the-fish.png",
              icon_size = 128,
              name = "so-long-and-thanks-for-all-the-fish",
              order = "h[secret]-a[so-long-and-thanks-for-all-the-fish]",
              parameter = {
                __meta_default__ = false
              },
              steam_stats_name = {
                __meta_default__ = ""
              },
              type = "achievement"
            }
          }

          local result = serializer.serialize(data_with_defaults)

          assert.is_string(result)
          assert.is.equal([[{
  ["so-long-and-thanks-for-all-the-fish"] = {
  --allowed_without_fight = true,
  --hidden = false,
    icon = "__base__/graphics/achievement/so-long-and-thanks-for-all-the-fish.png",
    icon_size = 128,
    name = "so-long-and-thanks-for-all-the-fish",
    order = "h[secret]-a[so-long-and-thanks-for-all-the-fish]",
  --parameter = false,
  --steam_stats_name = "",
    type = "achievement"
  }
}]], result)
        end)

        it("and should have closing table on next line", function()
          local data_with_defaults = {
            ["after-the-crash"] = {
              name = "after-the-crash",
              planet = "nauvis",
              sound = "__base__/sound/ambient/after-the-crash.ogg",
              track_type = "main-track",
              type = "ambient-sound",
              weight = {
                __meta_default__ = 1
              }
            },
            ["are-we-alone"] = {
              name = "are-we-alone",
              planet = "nauvis",
              sound = "__base__/sound/ambient/are-we-alone.ogg",
              track_type = "main-track",
              type = "ambient-sound",
              weight = {
                __meta_default__ = 1
              }
            },
          }

          local result = serializer.serialize(data_with_defaults)

          assert.is_string(result)
          assert.is.equal([[{
  ["after-the-crash"] = {
    name = "after-the-crash",
    planet = "nauvis",
    sound = "__base__/sound/ambient/after-the-crash.ogg",
    track_type = "main-track",
    type = "ambient-sound",
  --weight = 1
  },
  ["are-we-alone"] = {
    name = "are-we-alone",
    planet = "nauvis",
    sound = "__base__/sound/ambient/are-we-alone.ogg",
    track_type = "main-track",
    type = "ambient-sound",
  --weight = 1
  }
}]], result)
        end)

        it("and should have closing table on next line with multiple default values", function()
          local data_with_defaults = {
            layers = {
              {
                usage = {
                  __meta_default__ = "any"
                },
                x = {
                  __meta_default__ = 0
                },
                y = {
                  __meta_default__ = 0
                }
              },
            },
          }

          local result = serializer.serialize(data_with_defaults)

          assert.is_string(result)
          assert.is.equal([[{
  layers = {
    {
    --usage = "any",
    --x = 0,
    --y = 0
    }
  }
}]], result)
        end)
      end)

      describe("_meta_oneline_formatter", function()
        local original_formatter = serializer._serpent_options.custom

        setup(function()
          -- Override custom formatter with meta oneline formatter only for dedicated testing
          serializer._serpent_options.custom = function(tag, head, body, tail, level)
            tag, head, body, tail = serializer._meta_oneline_formatter(tag, head, body, tail)

            return tag .. head .. body .. tail
          end
        end)

        teardown(function()
          serializer._serpent_options.custom = original_formatter
        end)

        it("should compress simple object to single line", function()
          local color_data = {
            random_tint_color = {
              __meta_oneline__ = true,
              __value__ = {
                a = 1,
                b = 0,
                g = 0,
                r = 0
              }
            }
          }

          local result = serializer.serialize(color_data)

          assert.is_string(result)
          assert.is.equal([[{
  random_tint_color = {a = 1, b = 0, g = 0, r = 0}
}]], result)
        end)

        it("should compress nested array structures", function()
          local bounding_box_data = {
            selection_box = {
              __meta_oneline__ = true,
              __value__ = {
                {
                  __meta_oneline__ = true,
                  __value__ = {-0.5, -0.5}
                },
                {
                  __meta_oneline__ = true,
                  __value__ = {0.5, 0.5}
                }
              }
            }
          }

          local result = serializer.serialize(bounding_box_data)

          assert.is_string(result)
          assert.is.equal([[{
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
}]], result)
        end)

        it("should handle mixed oneline and non-oneline in same structure", function()
          local mixed_data = {
            properties = {
              map_color = {
                __meta_oneline__ = true,
                __value__ = {
                  r = 0.8,
                  g = 0.2,
                  b = 0.1,
                  a = 1
                }
              },
              detailed_config = {
                nested_object = {
                  setting_a = "value_a",
                  setting_b = "value_b"
                }
              }
            }
          }

          local result = serializer.serialize(mixed_data)

          assert.is_string(result)
          assert.is.equal([[{
  properties = {
    detailed_config = {
      nested_object = {
        setting_a = "value_a",
        setting_b = "value_b"
      }
    },
    map_color = {a = 1, b = 0.1, g = 0.2, r = 0.8}
  }
}]], result)
        end)

        it("should remove all metadata when value is not unwrapped", function()
          local data_with_preserved_meta = {
            color_field = {
              __meta_oneline__ = true,
              __meta_order__ = 100,
              __value__ = {
                r = 1,
                g = 0,
                b = 0,
                a = 1
              }
            }
          }

          local result = serializer.serialize(data_with_preserved_meta)

          assert.is_string(result)
          assert.is.equal([[{
  color_field = {a = 1, b = 0, g = 0, r = 1}
}]], result)
        end)

        it("should not affect non-oneline tables", function()
          local regular_data = {
            normal_table = {
              property_one = "value_one",
              property_two = "value_two"
            }
          }

          local result = serializer.serialize(regular_data)

          assert.is_string(result)
          assert.is.equal([[{
  normal_table = {
    property_one = "value_one",
    property_two = "value_two"
  }
}]], result)
        end)

        it("should handle arrays with simple numeric values", function()
          local coordinate_data = {
            position = {
              __meta_oneline__ = true,
              __value__ = {-0.5, -0.5}
            }
          }

          local result = serializer.serialize(coordinate_data)

          assert.is_string(result)
          assert.is.equal([[{
  position = {-0.5, -0.5}
}]], result)
        end)
      end)

      describe("_meta_default + _meta_oneline formatter", function()
        local original_formatter = serializer._serpent_options.custom

        setup(function()
          -- Use combined formatter for dedicated testing
          serializer._serpent_options.custom = function(tag, head, body, tail, level)
            tag, head, body, tail = serializer._meta_default_formatter(tag, head, body, tail, level)
            tag, head, body, tail = serializer._meta_oneline_formatter(tag, head, body, tail)

            return tag .. head .. body .. tail
          end
        end)

        teardown(function()
          serializer._serpent_options.custom = original_formatter
        end)

        it("should handle single default value entries", function()
          local color_data = {
            random_tint_color = {
              __meta_oneline__ = true,
              __value__ = {
                a = {
                  __meta_default__ = 1,
                },
                b = 0,
                g = 0,
                r = 0,
              }
            },
          }

          local result = serializer.serialize(color_data)

          assert.is_string(result)
          assert.is.equal("{\
  random_tint_color = {--[[a = 1,]] b = 0, g = 0, r = 0}\
}", result)
        end)

        it("should handle consecutive default value entries", function()
          local color_data = {
            item = {
              random_tint_color = {
                __meta_oneline__ = true,
                __value__ = {
                  a = 0.5,
                  b = {
                    __meta_default__ = 0,
                  },
                  g = {
                    __meta_default__ = 0,
                  },
                  r = 1
                }
              },
            }
          }

          local result = serializer.serialize(color_data)

          assert.is_string(result)
          assert.is.equal("{\
  item = {\
    random_tint_color = {a = 0.5, --[[b = 0, g = 0,]] r = 1}\
  }\
}", result)
        end)

        it("should handle whole default value entries", function()
          local color_data = {
            item = {
              random_tint_color = {
                __meta_oneline__ = true,
                __value__ = {
                  a = {
                    __meta_default__ = 1,
                  },
                  b = {
                    __meta_default__ = 0,
                  },
                  g = {
                    __meta_default__ = 0,
                  },
                  r = {
                    __meta_default__ = 0,
                  }
                }
              },
            }
          }

          local result = serializer.serialize(color_data)

          assert.is_string(result)
          assert.is.equal("{\
  item = {\
    random_tint_color = {--[[a = 1, b = 0, g = 0, r = 0]]}\
  }\
}", result)
        end)
      end)
    end)
  end)
end)
