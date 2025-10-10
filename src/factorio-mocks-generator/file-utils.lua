local path = require("path")
local fs = require("path.fs")

--- Utility functions for common file operations.
--- @class factorio_mocks_generator.file_utils
local file_utils = {}

--- Writes content to a file, creating directories as needed.
--- @param filepath string Relative or absolute path to the file to write
--- @param content string File content to write
function file_utils.write_file(filepath, content)
  filepath = path(filepath)
  fs.makedirs(path.parent(filepath))

  local file = io.open(filepath, "w")
  if not file then
    error(string.format("Failed to create file: %s", filepath))
  end

  --- @diagnostic disable: undefined-field
  file:write(content)
  file:close()
  --- @diagnostic enable
end

--- Reads content from a file
--- @param filepath string Relative or absolute path to the file to read
--- @return string content File content
function file_utils.read_file(filepath)
  filepath = path(filepath)

  local file = io.open(filepath, "r")
  if not file then
    error(string.format("Failed to read file: %s", filepath))
  end

  --- @diagnostic disable: undefined-field
  local content = file:read("*all")
  file:close()
  --- @diagnostic enable

  return content
end

--- Prepares output directory for new content.
--- @param output_dir string Directory to prepare
--- @param force boolean Whether to overwrite existing files
function file_utils.prepare_output_directory(output_dir, force)
  if path.isdir(output_dir) then
    if not force then
      error(string.format("Output directory '%s' already exists. Use --force to overwrite.", output_dir))
    else
      fs.removedirs(output_dir)
    end
  end
end

return file_utils
