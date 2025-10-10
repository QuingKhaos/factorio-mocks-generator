local function vendor_exists()
  -- Try to open a known file that should exist in the vendor directory
  local version = string.match(_VERSION, "%d+%.%d+")
  local test_file = "vendor/share/lua/" .. version .. "/argparse.lua"
  local f = io.open(test_file, "r")

  if f then
    --- @diagnostic disable-next-line: undefined-field
    f:close()
    return true
  end

  return false
end

-- Configure project local rockstree if available
if vendor_exists() then
  local version = string.match(_VERSION, "%d+%.%d+")
  package.path = "vendor/share/lua/" .. version .. "/?.lua;vendor/share/lua/" .. version .. "/?/init.lua;" .. package.path
  package.cpath = "vendor/lib/lua/" .. version .. "/?.dll;vendor/lib/lua/" .. version .. "/?.so;" .. package.cpath
end

-- Standard module resolution
package.path = "src/?.lua;src/?/init.lua;" .. package.path
