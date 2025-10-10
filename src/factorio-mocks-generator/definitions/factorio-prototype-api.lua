--- @meta

--- ref: https://lua-api.factorio.com/latest/auxiliary/json-docs-prototype.html
--- @class FactorioPrototypeAPI
--- @field application string The application this documentation is for. Will always be `"factorio"`.
--- @field application_version string The version of the game that this documentation is for. An example would be `"1.1.90"`.
--- @field api_version number The version of the machine-readable format itself. It is incremented every time the format changes.
--- @field stage string Indicates the stage this documentation is for. Will always be `"prototype"`.
--- @field prototypes FactorioPrototypeAPI.Prototype[] The list of prototypes that can be created. Equivalent to the [prototypes](https://lua-api.factorio.com/latest/prototypes.html) page.
--- @field types FactorioPrototypeAPI.TypeConcept[]  The list of types (concepts) that the format uses. Equivalent to the [types](https://lua-api.factorio.com/latest/types.html) page.
--- @field defines FactorioPrototypeAPI.Define[] The list of defines that the game uses. Equivalent to the [defines](https://lua-api.factorio.com/latest/defines.html) page.
local factorio_prototype_api = {}

--- Several API members follow a common format for their basic fields.
--- @class FactorioPrototypeAPI.BasicMember
--- @field name string The name of the member.
--- @field order number The order of the member as shown in the HTML.
--- @field description string The text description of the member. Can be `""`, but never `null`.
--- @field lists? string[] A list of Markdown lists to provide additional information. Usually contained in a spoiler tag.
--- @field examples? string[] A list of code-only examples about the member.
--- @field images? FactorioPrototypeAPI.Image[] A list of illustrative images shown next to the member.
local basic_member = {}

--- @class FactorioPrototypeAPI.Prototype: FactorioPrototypeAPI.BasicMember
--- @field visibility? string[] The list of game expansions needed to use this prototype. If not present, no restrictions apply. Possible values: `"space_age"`.
--- @field parent? string The name of the prototype's parent, if any.
--- @field abstract boolean Whether the prototype is abstract, and thus can't be created directly.
--- @field typename? string The type name of the prototype, like `"boiler"`. `null` for abstract prototypes.
--- @field instance_limit? number The maximum number of instances of this prototype that can be created, if any.
--- @field deprecated boolean Whether the prototype is deprecated and shouldn't be used anymore.
--- @field properties FactorioPrototypeAPI.Property[] The list of properties that the prototype has. May be an empty array.
--- @field custom_properties? FactorioPrototypeAPI.CustomProperties A special set of properties that the user can add an arbitrary number of. Specifies the type of the key and value of the custom property.
local prototype = {}

--- @class FactorioPrototypeAPI.TypeConcept: FactorioPrototypeAPI.BasicMember
--- @field parent? string The name of the type's parent, if any.
--- @field abstract boolean Whether the type is abstract, and thus can't be created directly.
--- @field inline boolean Whether the type is inlined inside another property's description.
--- @field type FactorioPrototypeAPI.Type|string The type of the type/concept (Yes, this naming is confusing). Either a proper Type, or the string `"builtin"`, indicating a fundamental type like `string` or `number`.
--- @field properties? FactorioPrototypeAPI.Property[] The list of properties that the type has, if its type includes a struct. null otherwise.
local type_concept = {}

--- Defines can be recursive in nature, meaning one Define can have multiple sub-Defines that have the same structure. These are singled out as `subkeys` instead of `values`.
--- @class FactorioPrototypeAPI.Define: FactorioPrototypeAPI.BasicMember
--- @field values? FactorioPrototypeAPI.DefineValue[] The members of the define.
--- @field subkeys? FactorioPrototypeAPI.Define[] A list of sub-defines.
local define = {}

--- @class FactorioPrototypeAPI.Property: FactorioPrototypeAPI.BasicMember
--- @field visibility? string[] The list of game expansions needed to use this property. If not present, no restrictions apply. Possible values: `"space_age"`.
--- @field alt_name? string An alternative name for the property. Either this or `name` can be used to refer to the property.
--- @field override boolean Whether the property overrides a property of the same name in one of its parents.
--- @field type FactorioPrototypeAPI.Type The type of the property.
--- @field optional boolean Whether the property is optional and can be omitted. If so, it falls back to a default value.
--- @field default? string|FactorioPrototypeAPI.Literal The default value of the property. Either a textual description or a literal value.
local property = {}

--- A type field can be a string, in which case that string is the simple type. Otherwise, a type is a table.
--- @alias FactorioPrototypeAPI.Type string|FactorioPrototypeAPI.Type.Array|FactorioPrototypeAPI.Type.Dictionary|FactorioPrototypeAPI.Type.Tuple|FactorioPrototypeAPI.Type.Union|FactorioPrototypeAPI.Type.Literal|FactorioPrototypeAPI.Type.Type|FactorioPrototypeAPI.Type.Struct

--- @class FactorioPrototypeAPI.Type.Array
--- @field complex_type "array" A string denoting the kind of complex type.
--- @field value FactorioPrototypeAPI.Type The type of the elements of the array.
local type_array = {}

--- @class FactorioPrototypeAPI.Type.Dictionary
--- @field complex_type "dictionary" A string denoting the kind of complex type.
--- @field key FactorioPrototypeAPI.Type The type of the keys of the dictionary.
--- @field value FactorioPrototypeAPI.Type The type of the values of the dictionary.
local type_dictionary = {}

--- @class FactorioPrototypeAPI.Type.Tuple
--- @field complex_type "tuple" A string denoting the kind of complex type.
--- @field values FactorioPrototypeAPI.Type[] The types of the members of this tuple in order.
local type_tuple = {}

--- @class FactorioPrototypeAPI.Type.Union
--- @field complex_type "union" A string denoting the kind of complex type.
--- @field options FactorioPrototypeAPI.Type[] A list of all compatible types for this type.
--- @field full_format boolean Whether the options of this union have a description or not.
local type_union = {}

--- @class FactorioPrototypeAPI.Type.Literal
--- @field complex_type "literal" A string denoting the kind of complex type.
--- @field value string|number|boolean The value of the literal.
--- @field description? string The text description of the literal, if any.
local type_literal = {}

--- @class FactorioPrototypeAPI.Type.Type
--- @field complex_type "type" A string denoting the kind of complex type.
--- @field value FactorioPrototypeAPI.Type The actual type. This format for types is used when they have descriptions attached to them.
--- @field description string The text description of the type.
local type_type = {}

--- @class FactorioPrototypeAPI.Type.Struct
--- @field complex_type "struct" A string denoting the kind of complex type.
local type_struct = {}

--- A literal has the same format as a Type that is complex and of type `literal`.
--- @class FactorioPrototypeAPI.Literal
--- @field complex_type "literal" A string denoting the kind of complex type.
--- @field value string|number|boolean The value of the literal.
local literal = {}

--- @class FactorioPrototypeAPI.Image
--- @field filename string The name of the image file to display. These files are placed into the `/static/images/` directory.
--- @field caption? string The explanatory text to show attached to the image.
local image = {}

--- @class FactorioPrototypeAPI.CustomProperties
--- @field description string The text description of the property.
--- @field lists? string[] A list of Markdown lists to provide additional information. Usually contained in a spoiler tag.
--- @field examples? string[] A list of code-only examples about the property.
--- @field images? FactorioPrototypeAPI.Image[] A list of illustrative images shown next to the property.
--- @field key_type FactorioPrototypeAPI.Type The type of the key of the custom property.
--- @field value_type FactorioPrototypeAPI.Type The type of the value of the custom property.
local custom_properties = {}

--- @class FactorioPrototypeAPI.DefineValue
--- @field name string The name of the define value.
--- @field order number The order of the member as shown in the HTML.
--- @field description string The text description of the define value.
local define_value = {}
