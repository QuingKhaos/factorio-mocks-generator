local to_fix = {
  "behemoth-worm-turret",
  "big-worm-turret",
  "medium-worm-turret",
  "small-worm-turret",
}

for _, fixme in ipairs(to_fix) do
  local turret = data.raw["turret"][fixme]
  if turret then
    for _, spawn_decoration in ipairs(turret.spawn_decoration) do
      spawn_decoration.type = "create-decorative"
    end
  end
end
