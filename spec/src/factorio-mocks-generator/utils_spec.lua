insulate("[#UNIT] utils", function()
  local utils = require("factorio-mocks-generator.utils")

  describe("camel_to_snake_case", function()
    it("should convert basic PascalCase to SNAKE_CASE", function()
      assert.are.equal("ACTIVATE_EQUIPMENT_CAPSULE_ACTION", utils.camel_to_snake_case("ActivateEquipmentCapsuleAction"))
      assert.are.equal("ANIMATION_ELEMENT", utils.camel_to_snake_case("AnimationElement"))
      assert.are.equal("LOCALISED_STRING", utils.camel_to_snake_case("LocalisedString"))
    end)

    it("should handle ID suffix pattern from Factorio types", function()
      -- These are the actual patterns from rules/2.0.66/prototype/types/
      assert.are.equal("ACTIVE_TRIGGER_ID", utils.camel_to_snake_case("ActiveTriggerID"))
      assert.are.equal("AIRBORNE_POLLUTANT_ID", utils.camel_to_snake_case("AirbornePollutantID"))
      assert.are.equal("AMMO_CATEGORY_ID", utils.camel_to_snake_case("AmmoCategoryID"))
      assert.are.equal("QUALITY_ID", utils.camel_to_snake_case("QualityID"))
    end)

    it("should handle numbers in compound names", function()
      -- Patterns like Animation4Way, Sprite16Way found in actual types
      assert.are.equal("ANIMATION_4_WAY", utils.camel_to_snake_case("Animation4Way"))
      assert.are.equal("SPRITE_16_WAY", utils.camel_to_snake_case("Sprite16Way"))
      assert.are.equal("VECTOR_3D", utils.camel_to_snake_case("Vector3D"))
      assert.are.equal("VECTOR_4F", utils.camel_to_snake_case("Vector4f"))
    end)

    it("should handle simple primitive types", function()
      -- Basic types that appear in the rules
      assert.are.equal("DOUBLE", utils.camel_to_snake_case("double"))
      assert.are.equal("FLOAT", utils.camel_to_snake_case("float"))
      assert.are.equal("NUMBER", utils.camel_to_snake_case("number"))
      assert.are.equal("TABLE", utils.camel_to_snake_case("table"))
    end)

    it("should handle edge cases", function()
      assert.are.equal("", utils.camel_to_snake_case(""))
      assert.are.equal("A", utils.camel_to_snake_case("A"))
    end)
  end)
end)
