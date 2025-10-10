insulate("[#UNIT] prototype-rules.post-processors.types.MapPosition", function()
  local post_processor = require("factorio-mocks-generator.prototype-rules.post-processors.types.MapPosition")

  describe("process", function()
    local test_type_concept = {
      name = "MapPosition",
    }

    local test_rules = {
      ["or"] = {
        {nested_object = {}},
        {tuple_of = {}},
        {tuple_of = {}},
      }
    }

    it("should add metadata.oneline to all union rules", function()
      local result = post_processor.process(test_type_concept, test_rules)

      -- Should have same number of alternatives
      assert.are.equal(3, #result["or"])

      -- Each alternative should be wrapped as [original_rule, {metadata = {oneline = true}}]
      for i, alternative in ipairs(result["or"]) do
        assert.are.equal(2, #alternative)
        assert.are.same(test_rules["or"][i], alternative[1])
        assert.are.same({metadata = {oneline = true}}, alternative[2])
      end
    end)
  end)
end)
