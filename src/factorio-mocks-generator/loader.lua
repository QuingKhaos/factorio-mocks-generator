--- @class factorio_mocks_generator.loader
local loader = {}

--- Register a custom loader for a given prefix and directory.
--- @param prefix string The module prefix to register
--- @param dir string The directory to load modules from
function loader.register_loader(prefix, dir)
  local function custom_searcher(module_name)
    -- Check if module name starts with our prefix
    if not string.find(module_name, "^" .. prefix:gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1")) then
      return nil -- Not our prefix, let other searchers handle it
    end

    -- Remove prefix and convert to file path
    local relative_path = string.gsub(module_name, "^" .. prefix:gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1"), "")
    relative_path = string.gsub(relative_path, "^%.", "") -- Remove leading dot if present
    local file_path = string.gsub(relative_path, "%.", "/")

    -- Try both patterns: module.lua and module/init.lua
    local paths_to_try = {
      dir .. "/" .. file_path .. ".lua",
      dir .. "/" .. file_path .. "/init.lua"
    }

    local module, err
    for _, full_path in ipairs(paths_to_try) do
      module, err = loadfile(full_path)
      if module then
        return module
      end
    end

    -- If we get here, neither path worked
    error(string.format("error loading module '%s' from prefix '%s':\n\tTried paths: %s\n\tLast error: %s",
      module_name, prefix, table.concat(paths_to_try, ", "), err or "unknown error"))
  end

  --- @diagnostic disable-next-line: undefined-field
  table.insert(package.searchers, 1, custom_searcher)
end

return loader
