insulate("[#INTEGRATION] file-utils", function()
  _G._TEST = true
  local file_utils = require("factorio-mocks-generator.file-utils")
  local path = require("path")
  local fs = require("path.fs")

  local test_dir = ".tmp/file-utils-test"
  local test_file = test_dir .. "/test.txt"
  local nested_test_file = test_dir .. "/nested/deep/test.txt"

  before_each(function()
    fs.removedirs(test_dir)
  end)

  after_each(function()
    fs.removedirs(test_dir)
  end)

  describe("write_file", function()
    it("should write content to a file", function()
      local content = "Hello, World!"

      file_utils.write_file(test_file, content)

      assert.is_true(fs.exists(test_file))

      local actual_content = file_utils.read_file(test_file)
      assert.are.equal(content, actual_content)
    end)

    it("should create directories when they don't exist", function()
      local content = "Nested file content"

      file_utils.write_file(nested_test_file, content)

      assert.is_true(fs.exists(nested_test_file))
      assert.is_truthy(fs.isdir(test_dir .. "/nested"))
      assert.is_truthy(fs.isdir(test_dir .. "/nested/deep"))

      local actual_content = file_utils.read_file(nested_test_file)
      assert.are.equal(content, actual_content)
    end)

    it("should handle empty content", function()
      file_utils.write_file(test_file, "")

      assert.is_true(fs.exists(test_file))
      local actual_content = file_utils.read_file(test_file)
      assert.are.equal("", actual_content)
    end)

    it("should handle multi-line content", function()
      local content = "Line 1\nLine 2\nLine 3"

      file_utils.write_file(test_file, content)

      local actual_content = file_utils.read_file(test_file)
      assert.are.equal(content, actual_content)
    end)

    it("should handle special characters in content", function()
      local content = "Special chars: áéíóú ñ ü àèìòù çşğıöüç 中文 🎯"

      file_utils.write_file(test_file, content)

      local actual_content = file_utils.read_file(test_file)
      assert.are.equal(content, actual_content)
    end)

    it("should overwrite existing files", function()
      file_utils.write_file(test_file, "Original content")
      file_utils.write_file(test_file, "New content")

      local actual_content = file_utils.read_file(test_file)
      assert.are.equal("New content", actual_content)
    end)

    it("should handle files with no directory path", function()
      local cwd = path.cwd()
      fs.chdir(path(cwd, ".tmp"))

      local simple_file = "simple.txt"
      file_utils.write_file(simple_file, "No directory")
      assert.is_true(fs.exists(simple_file))

      local actual_content = file_utils.read_file(simple_file)
      assert.are.equal("No directory", actual_content)

      fs.remove(simple_file)
      fs.chdir(cwd)
    end)

    it("should error on invalid file paths", function()
      assert.has_error(function()
        file_utils.write_file("/invalid\000path/file.txt", "content")
      end)
      -- Note: We just check that it errors, the specific message may vary by platform
    end)
  end)

  describe("read_file", function()
    it("should read content from an existing file", function()
      local expected_content = "Test file content"

      -- Create file first
      file_utils.write_file(test_file, expected_content)

      local actual_content = file_utils.read_file(test_file)
      assert.are.equal(expected_content, actual_content)
    end)

    it("should read empty files", function()
      file_utils.write_file(test_file, "")

      local actual_content = file_utils.read_file(test_file)
      assert.are.equal("", actual_content)
    end)

    it("should read multi-line files", function()
      local expected_content = "Line 1\nLine 2\nLine 3\n"
      file_utils.write_file(test_file, expected_content)

      local actual_content = file_utils.read_file(test_file)
      assert.are.equal(expected_content, actual_content)
    end)

    it("should read files with special characters", function()
      local expected_content = "Special: áéíóú ñ ü 中文 🚀"
      file_utils.write_file(test_file, expected_content)

      local actual_content = file_utils.read_file(test_file)
      assert.are.equal(expected_content, actual_content)
    end)

    it("should error when file does not exist", function()
      assert.has_error(function()
        file_utils.read_file("nonexistent-file.txt")
      end, "Failed to read file: nonexistent-file.txt")
    end)

    it("should error with descriptive message for missing files", function()
      local missing_file = test_dir .. "/missing.txt"

      assert.has_error(function()
        file_utils.read_file(missing_file)
      end, "Failed to read file: " .. path(missing_file))
    end)
  end)

  describe("prepare_output_directory", function()
    before_each(function()
      fs.makedirs(".tmp/existing-rules")
    end)

    after_each(function()
      fs.removedirs(".tmp/new-rules")
      fs.removedirs(".tmp/existing-rules")
    end)

    it("should error when output directory exists and force is false", function()
      assert.has_error(function()
        file_utils.prepare_output_directory(".tmp/existing-rules", false)
      end, "Output directory '.tmp/existing-rules' already exists. Use --force to overwrite.")
    end)

    it("should remove existing output directory when force is true", function()
      -- Verify directory exists before
      assert.are.equal(path(".tmp", "existing-rules"), path.isdir(".tmp/existing-rules"))

      file_utils.prepare_output_directory(".tmp/existing-rules", true)

      -- Directory should have been removed
      assert.is_false(path.isdir(".tmp/existing-rules"))
    end)

    it("should succeed when output directory does not exist", function()
      file_utils.prepare_output_directory(".tmp/new-rules", false)

      -- Directory should still not exist, as the function does not create it
      assert.are.equal(path(".tmp", "existing-rules"), path.isdir(".tmp/existing-rules"))
    end)
  end)

  describe("Cross-platform compatibility", function()
    it("should work with different path separators", function()
      local unix_style = test_dir .. "/unix/style/file.txt"
      local windows_style = test_dir .. "\\windows\\style\\file.txt"

      file_utils.write_file(unix_style, "Unix style path")
      file_utils.write_file(windows_style, "Windows style path")

      assert.is_true(fs.exists(unix_style))
      assert.is_true(fs.exists(windows_style))

      local unix_content = file_utils.read_file(unix_style)
      local windows_content = file_utils.read_file(windows_style)

      assert.are.equal("Unix style path", unix_content)
      assert.are.equal("Windows style path", windows_content)
    end)

    it("should handle directory creation on different platforms", function()
      local deep_path = test_dir .. "/very/deep/nested/directory/structure/file.txt"

      file_utils.write_file(deep_path, "Deep nested file")

      assert.is_true(fs.exists(deep_path))
      assert.is_truthy(fs.isdir(test_dir .. "/very"))
      assert.is_truthy(fs.isdir(test_dir .. "/very/deep"))
      assert.is_truthy(fs.isdir(test_dir .. "/very/deep/nested"))
    end)

    it("should normalize mixed path separators", function()
      -- Test multiple separator styles in same path with relative paths
      local messy_path = test_dir .. "/forward\\back/mixed\\separators/file.txt"

      file_utils.write_file(messy_path, "Normalized path content")

      assert.is_true(fs.exists(messy_path))
      local actual_content = file_utils.read_file(messy_path)
      assert.are.equal("Normalized path content", actual_content)
    end)

    it("should handle absolute paths", function()
      -- Use current working directory to build absolute path
      local cwd = path.cwd()
      local abs_test_dir = cwd .. "/.tmp/abs-test"
      local abs_test_file = abs_test_dir .. "/absolute/test.txt"

      fs.removedirs(abs_test_dir)

      file_utils.write_file(abs_test_file, "Absolute path content")

      assert.is_true(fs.exists(abs_test_file))
      assert.is_truthy(fs.isdir(abs_test_dir .. "/absolute"))

      local actual_content = file_utils.read_file(abs_test_file)
      assert.are.equal("Absolute path content", actual_content)

      fs.removedirs(abs_test_dir)
    end)
  end)
end)
