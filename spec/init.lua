-- Support loading mods via __modname__ convention
local function factorio_mod_loader(modname)
  -- Check if this follows the Factorio mod pattern: __mod-name__.module.path
  local mod_name, mod_path = modname:match("^__([^_]+)__%.(.+)$")

  if mod_name and mod_path then
    -- Convert to file path in mods/mod-name/ directory (without double underscores)
    local file_path = "mods/" .. mod_name .. "/" .. mod_path:gsub("%.", "/") .. ".lua"

    -- Try to load the file - if it fails, that's an error since the prefix is explicit
    local module, err = loadfile(file_path)
    if module then
      return module
    else
      error("Module '" .. modname .. "' not found: " .. (err or ("no file '" .. file_path .. "'")))
    end
  end

  -- Not a factorio mod path, return nil to let other loaders handle it
  return nil
end

--- @diagnostic disable-next-line: undefined-field
table.insert(package.searchers, 1, factorio_mod_loader)

-- Standard module resolution
package.path = "src/?.lua;src/?/init.lua;" .. package.path

-- Enable testing mode
_G._TEST = true
