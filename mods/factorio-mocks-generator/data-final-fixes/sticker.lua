local to_fix = {
  "acid-sticker-behemoth",
  "acid-sticker-big",
  "acid-sticker-medium",
  "acid-sticker-small",
  "electric-mini-stun",
  "fire-sticker",
  "slowdown-sticker",
  "stun-sticker",
  -- Space Age
  "big-acid-sticker-stomper",
  "bioflux-speed-regen-sticker",
  "bioflux-speed-regen-sticker-behind",
  "demolisher-ash-sticker",
  "jellynut-speed-sticker",
  "jellynut-speed-sticker-behind",
  "medium-acid-sticker-stomper",
  "small-acid-sticker-stomper",
  "strafer-sticker",
  "tesla-turret-slow",
  "tesla-turret-stun",
  "yumako-regen-sticker",
  "yumako-regen-sticker-behind",
}

for _, fixme in ipairs(to_fix) do
  local sticker = data.raw["sticker"][fixme]
  if sticker then
    sticker.hidden = true
    sticker.hidden_in_factoriopedia = true
  end
end
