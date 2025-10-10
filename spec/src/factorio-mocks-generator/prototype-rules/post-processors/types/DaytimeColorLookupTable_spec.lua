insulate("[#UNIT] prototype-rules.post-processors.types.DaytimeColorLookupTable", function()
  -- luacheck: no max line length
  local post_processor = require("factorio-mocks-generator.prototype-rules.post-processors.types.DaytimeColorLookupTable")

  describe("process", function()
    local test_type_concept = {
      name = "DaytimeColorLookupTable",
    }

    local test_rules = {
      list_of = {
        tuple_of = {}
      }
    }

    it("should add metadata.oneline to tuple rule", function()
      local result = post_processor.process(test_type_concept, test_rules)

      -- tuple_of should be wrapped as [original_rule, {metadata = {oneline = true}}]
      assert.is_table(result.list_of)
      assert.are.equal(2, #result.list_of)
      assert.are.same(test_rules.list_of, result.list_of[1])
      assert.are.same({metadata = {oneline = true}}, result.list_of[2])
    end)
  end)
end)
