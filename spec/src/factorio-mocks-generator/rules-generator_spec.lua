--- @diagnostic disable: invisible
insulate("[#UNIT] rules-generator", function()
  local rules_generator = require("factorio-mocks-generator.rules-generator")
  local prototype_rules_generator = require("factorio-mocks-generator.prototype-rules.generator")

  describe("_fetch_api_json", function()
    local curl = require("cURL")

    after_each(function()
      curl.easy --[[@as luassert.spy]]:revert()
    end)

    it("should fetch API data for a valid version", function()
      -- Stub the curl library to avoid actual HTTP calls
      local version = "2.0.66"

      stub(curl, "easy", function()
        return {
          -- luacheck: no unused args
          setopt = function(self, opt, fn)
            if opt == curl.OPT_WRITEFUNCTION then
              fn('{"application":"factorio","application_version":"' .. version .. '","api_version":6}')
            end
          end,
          perform = function() return true end,
          getinfo = function() return 200 end,
          close = function() end,
        }
      end)

      local result = rules_generator._fetch_api_json(version, "prototype")

      assert.is_table(result)
      assert.are.equal("factorio", result.application)
      assert.are.equal(version, result.application_version)
      assert.are.equal(6, result.api_version)
    end)

    it("should error on invalid version", function()
      -- Stub the curl library to return HTTP 404
      stub(curl, "easy", function()
        return {
          setopt = function() end,
          perform = function() return true end,
          getinfo = function() return 404 end,
          close = function() end,
        }
      end)

      assert.has_error(function()
        rules_generator._fetch_api_json("invalid-version", "prototype")
      end, "Failed to fetch prototype API data. HTTP status: 404")
    end)

    it("should error on network failure", function()
      -- Mock the curl library to simulate network failure
      stub(curl, "easy", function()
        return {
          setopt = function() end,
          perform = function()
            return nil, "Could not resolve host: lua-api.factorio.com"
          end,
          getinfo = function() return 0 end,
          close = function() end,
        }
      end)

      -- Test that the function throws an error for network failure
      assert.has_error(function()
        rules_generator._fetch_api_json("2.0.66", "prototype")
      end, "Failed to fetch prototype API data: Could not resolve host: lua-api.factorio.com")
    end)
  end)

  describe("generate_rules_for_version", function()
    local file_utils = require("factorio-mocks-generator.file-utils")

    before_each(function()
      stub(file_utils, "prepare_output_directory")
      stub(rules_generator, "_fetch_api_json")
      stub(rules_generator, "_create_entrypoint")
      stub(prototype_rules_generator, "generate_prototype_rules")
    end)

    after_each(function()
      file_utils.prepare_output_directory --[[@as luassert.spy]]:revert()
      rules_generator._fetch_api_json --[[@as luassert.spy]]:revert()
      rules_generator._create_entrypoint --[[@as luassert.spy]]:revert()
      prototype_rules_generator.generate_prototype_rules --[[@as luassert.spy]]:revert()
    end)

    it("should call _fetch_api_json for prototype API", function()
      rules_generator.generate_rules_for_version("2.0.66", ".tmp/rules/")

      assert.stub(rules_generator._fetch_api_json --[[@as luassert.spy]]).was.called_with("2.0.66", "prototype")
    end)

    it("should resolve 'stable' alias to 'stable' API endpoint", function()
      rules_generator.generate_rules_for_version("stable", ".tmp/rules/")

      assert.stub(rules_generator._fetch_api_json --[[@as luassert.spy]]).was.called_with("stable", "prototype")
    end)

    it("should resolve 'experimental' alias to 'latest' API endpoint", function()
      rules_generator.generate_rules_for_version("experimental", ".tmp/rules/")

      assert.stub(rules_generator._fetch_api_json --[[@as luassert.spy]]).was.called_with("latest", "prototype")
    end)
  end)
end)

insulate("[#INTEGRATION] rules-generator", function()
  local rules_generator = require("factorio-mocks-generator.rules-generator")

  describe("_fetch_api_json with real HTTP", function()
    it("should fetch real prototype API data for version 2.0.66", function()
      local result = rules_generator._fetch_api_json("2.0.66", "prototype")

      -- Verify basic structure
      assert.is_table(result)
      assert.are.equal("factorio", result.application)
      assert.are.equal("2.0.66", result.application_version)
      assert.is_number(result.api_version)

      -- Verify it has expected API data
      assert.is_table(result.prototypes)
      assert.is_table(result.types)
      assert.is_table(result.defines)
    end)

    it("should fetch real runtime API data for version 2.0.66", function()
      local result = rules_generator._fetch_api_json("2.0.66", "runtime")

      -- Verify basic structure
      assert.is_table(result)
      assert.are.equal("factorio", result.application)
      assert.are.equal("2.0.66", result.application_version)
      assert.is_number(result.api_version)

      -- Verify it has expected API data
      assert.is_table(result.classes)
      assert.is_table(result.events)
      assert.is_table(result.defines)
    end)

    it("should handle stable alias correctly", function()
      local result = rules_generator._fetch_api_json("stable", "prototype")

      -- Should get real data without errors
      assert.is_table(result)
      assert.are.equal("factorio", result.application)
      assert.is_string(result.application_version)
      assert.is_number(result.api_version)
    end)

    it("should handle latest alias correctly", function()
      local result = rules_generator._fetch_api_json("latest", "runtime")

      -- Should get real data without errors
      assert.is_table(result)
      assert.are.equal("factorio", result.application)
      assert.is_string(result.application_version)
      assert.is_number(result.api_version)
    end)

    it("should error on invalid version with real HTTP", function()
      assert.has_error(function()
        rules_generator._fetch_api_json("invalid-version-12345", "prototype")
      end, "Failed to fetch prototype API data. HTTP status: 404")
    end)
  end)
end)
