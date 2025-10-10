insulate("[#UNIT] prototype-rules.post-processors.types.ControlPoint", function()
  local post_processor = require("factorio-mocks-generator.prototype-rules.post-processors.types.ControlPoint")

  describe("process", function()
    local test_type_concept = {
      name = "ControlPoint",
    }

    local test_rules = {
      ["or"] = {
        {nested_object = {}},
        {tuple_of = {}},
      }
    }

    it("should add metadata.oneline to union tuple rules", function()
      local result = post_processor.process(test_type_concept, test_rules)

      -- Should have same number of alternatives
      assert.are.equal(2, #result["or"])

      -- Each tuple_of should be wrapped as [original_rule, {metadata = {oneline = true}}]
      for i, alternative in ipairs(result["or"]) do
        if i == 1 then
          -- Non-tuple alternatives should remain unchanged
          assert.are.same(test_rules["or"][i], alternative)
        else
          -- Tuple alternatives should be wrapped
          assert.are.equal(2, #alternative)
          assert.are.same(test_rules["or"][i], alternative[1])
          assert.are.same({metadata = {oneline = true}}, alternative[2])
        end
      end
    end)
  end)
end)
