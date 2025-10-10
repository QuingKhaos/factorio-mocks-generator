local to_fix = {
  "biter-spawner",
  "spitter-spawner",
  -- Space Age
  "gleba-spawner",
  "gleba-spawner-small",
}

for _, fixme in ipairs(to_fix) do
  local unit_spawner = data.raw["unit-spawner"][fixme]
  if unit_spawner then
    for _, spawn_decoration in ipairs(unit_spawner.spawn_decoration) do
      spawn_decoration.type = "create-decorative"
    end
  end
end
