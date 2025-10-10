local Color = require("factorio-mocks-generator.prototype-rules.default-extractors.Color")
local BoundingBox = require("factorio-mocks-generator.prototype-rules.default-extractors.BoundingBox")
local Vector3D = require("factorio-mocks-generator.prototype-rules.default-extractors.Vector3D")
local Vector = require("factorio-mocks-generator.prototype-rules.default-extractors.Vector")
local LocalisedString = require("factorio-mocks-generator.prototype-rules.default-extractors.LocalisedString")
local FuelCategoryID = require("factorio-mocks-generator.prototype-rules.default-extractors.FuelCategoryID")

--- @class factorio_mocks_generator.prototype_rules.default_extractors
local extractor = {}

--- Extracts structured default values from string representations for specific types
--- @param property FactorioPrototypeAPI.Property The complete property information
--- @return data.AnyBasic? extracted_value The extracted Lua content, if any
function extractor.extract_structured_default(property)
  -- Only process string defaults (literal defaults are handled separately)
  if type(property.default) ~= "string" then
    return nil
  end

  if type(property.type) == "string" then
    if property.type == "Color" then
      return Color.extract(property.default --[[@as string]])
    elseif property.type == "BoundingBox" then
      return BoundingBox.extract(property.default --[[@as string]])
    elseif property.type == "Vector3D" then
      return Vector3D.extract(property.default --[[@as string]])
    elseif property.type == "Vector" then
      return Vector.extract(property.default --[[@as string]])
    elseif property.type == "LocalisedString" then
      return LocalisedString.extract(property.default --[[@as string]])
    end
  elseif type(property.type) == "table" and property.type.complex_type == "array" then
    if property.type.value == "Color" then
      return Color.extract_array(property.default --[[@as string]])
    elseif property.type.value == "FuelCategoryID" then
      return FuelCategoryID.extract_array(property.default --[[@as string]])
    end
  end

  return nil
end

return extractor
