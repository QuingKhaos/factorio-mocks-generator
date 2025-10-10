insulate("[#UNIT] prototype-rules.default-extractors.Vector", function()
  local extractors = require("factorio-mocks-generator.prototype-rules.default-extractors")

  it("should extract bare array format as Lua table", function()
    local property = {
      name = "shift",
      type = "Vector",
      optional = true,
      default = "{1,1}"
    }

    local expected = {1, 1}

    local result = extractors.extract_structured_default(property)
    assert.are.same(expected, result)
  end)

  it("should extract bare array format decimals as Lua table", function()
    local property = {
      name = "shift",
      type = "Vector",
      optional = true,
      default = "{0, 0.7}"
    }

    local expected = {0, 0.7}

    local result = extractors.extract_structured_default(property)
    assert.are.same(expected, result)
  end)

  it("should extract backtick-wrapped array format as Lua table", function()
    local property = {
      name = "shift",
      type = "Vector",
      optional = true,
      default = "`{0, 0}`"
    }

    local expected = {0, 0}

    local result = extractors.extract_structured_default(property)
    assert.are.same(expected, result)
  end)
end)
