insulate("[#UNIT] prototype-rules.post-processors.types.ResearchIngredient", function()
  local post_processor = require("factorio-mocks-generator.prototype-rules.post-processors.types.ResearchIngredient")

  describe("process", function()
    local test_type_concept = {
      name = "ResearchIngredient",
    }

    local test_rules = {
      tuple_of = {}
    }

    it("should add metadata.oneline to tuple rule", function()
      local result = post_processor.process(test_type_concept, test_rules)

      -- tuple_of should be wrapped as [original_rule, {metadata = {oneline = true}}]
      assert.is_table(result)
      assert.are.equal(2, #result)
      assert.are.same(test_rules, result[1])
      assert.are.same({metadata = {oneline = true}}, result[2])
    end)
  end)
end)
