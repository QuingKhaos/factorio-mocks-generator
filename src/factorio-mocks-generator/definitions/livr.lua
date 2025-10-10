--- @meta

--- @alias LIVR.Validation.fn fun(value?: data.AnyBasic): data.AnyBasic?, string?

--- @alias LIVR.Rule LIVR.Rules.Common|LIVR.Rules.String|LIVR.Rules.Numeric|LIVR.Rules.Meta|LIVR.Rules.Extra|LIVR.Rules.Modifiers|LIVR.Rules.Custom
--- @alias LIVR.Rules {[string]: LIVR.Rule|LIVR.Rule[]}

--- @alias LIVR.Rules.Common LIVR.Rules.Common.required|LIVR.Rules.Common.not_empty_list|LIVR.Rules.Common.any_object
--- @class LIVR.Rules.Common.required: string
local required = "required"
--- @class LIVR.Rules.Common.not_empty_list: string
local not_empty_list = "not_empty_list"
--- @class LIVR.Rules.Common.any_object: string
local any_object = "any_object"

--- @alias LIVR.Rules.String LIVR.Rules.String.string|LIVR.Rules.String.eq|LIVR.Rules.String.one_of
--- @class LIVR.Rules.String.string: string
local string_rule = "string"
--- @class LIVR.Rules.String.eq
--- @field eq string|number|boolean
local eq = {}
--- @class LIVR.Rules.String.one_of
--- @field one_of string[] List of allowed string values
local one_of = {}

--- @alias LIVR.Rules.Numeric LIVR.Rules.Numeric.integer|LIVR.Rules.Numeric.decimal|LIVR.Rules.Numeric.min_number
--- @class LIVR.Rules.Numeric.integer: string
local integer = "integer"
--- @class LIVR.Rules.Numeric.decimal: string
local decimal = "decimal"
--- @class LIVR.Rules.Numeric.min_number
--- @field min_number number Minimum allowed value
local min_number = {}

--- @alias LIVR.Rules.Meta LIVR.Rules.Meta.nested_object|LIVR.Rules.Meta.list_of|LIVR.Rules.Meta.list_of_objects|LIVR.Rules.Meta.or
--- @class LIVR.Rules.Meta.nested_object
--- @field nested_object LIVR.Rules
local nested_object = {}
--- @class LIVR.Rules.Meta.list_of
--- @field list_of LIVR.Rule|LIVR.Rule[]
local list_of = {}
--- @class LIVR.Rules.Meta.list_of_objects
--- @field list_of_objects LIVR.Rules[]
local list_of_objects = {}
--- @class LIVR.Rules.Meta.or
--- @field or (LIVR.Rule|LIVR.Rule[])[]
local or_rule = {}

--- @alias LIVR.Rules.Extra LIVR.Rules.Extra.boolean|LIVR.Rules.Extra.list_length
--- @class LIVR.Rules.Extra.boolean: string
local boolean = "boolean"
--- @class LIVR.Rules.Extra.list_length
--- @field list_length number|[number, number]
local list_length = {}

--- @alias LIVR.Rules.Modifiers LIVR.Rules.Modifiers.default
--- @class LIVR.Rules.Modifiers.default
--- @field default string|number|boolean Literal value to be used as a default if the field is not present
local default = {}

--- @alias LIVR.Rules.Custom LIVR.Rules.Custom.unsigned_integer|LIVR.Rules.Custom.absent|LIVR.Rules.Custom.not_contains|LIVR.Rules.Custom.not_if|LIVR.Rules.Custom.ignored_if|LIVR.Rules.Custom.dict_of|LIVR.Rules.Custom.tuple_of|LIVR.Rules.Custom.lookup|LIVR.Rules.Custom.metadata
--- @class LIVR.Rules.Custom.unsigned_integer: string
local unsigned_integer = "unsigned_integer"
--- @class LIVR.Rules.Custom.absent: string
local absent = "absent"
--- @class LIVR.Rules.Custom.not_contains
--- @field not_contains string[] List of other field names that must not be present
local not_contains = {}
--- @class LIVR.Rules.Custom.not_if
--- @field not_if [string, LIVR.Rule|LIVR.Rule[]] #1 other field name to check for nil-ness; #2 Rule or array of Rules to validate against if the other field is nil
local not_if = {}
--- @class LIVR.Rules.Custom.ignored_if
--- @field ignored_if [string|string[]|LIVR.Rules, LIVR.Rule|LIVR.Rule[]] #1 other field name(s) to check for nil-ness or validate against rules; #2 Rule or array of Rules to validate against if the other field is(are) nil or validation failed
local ignored_if = {}
--- @class LIVR.Rules.Custom.dict_of
--- @field dict_of {keys: LIVR.Rule|LIVR.Rule[], values: LIVR.Rule|LIVR.Rule[]}
local dict_of = {}
--- @class LIVR.Rules.Custom.tuple_of
--- @field tuple_of (LIVR.Rule|LIVR.Rule[])[] Array of Rules where each element validates the corresponding tuple position
local tuple_of = {}
--- @class LIVR.Rules.Custom.lookup
--- @field lookup string Prototype typename to look up to
local lookup = {}
--- @class LIVR.Rules.Custom.metadata
--- @field metadata LIVR.Rules.Custom.metadata.params
local metadata = {}
--- @class LIVR.Rules.Custom.metadata.params
--- @field default? data.AnyBasic|data.Color|data.Color[] Value to be used as a default if the field is missing, prefix with __DESC__ if it's a description
--- @field oneline? boolean If true, serialize values in a single line
--- @field order? number Order index for serialization purposes
local metadata_params = {}

--- @class LIVR.Rules.Factorio
--- @field visibility string[] List of game expansions the rules apply to
--- @field prototype LIVR.Rules.Factorio.Prototype
local livr_rules = {}

--- @class LIVR.Rules.Factorio.Prototype
--- @field api_version? number Factorio Prototype API version used for generation
--- @field factorio_version? string Factorio version of the Prototype API used for generation
--- @field prototypes {[string]: {name: string, order: number, rules: LIVR.Rules}} Mapping of prototype type to its LIVR rules to validate `data.raw` prototypes
--- @field mods LIVR.Rule Rule to validate `mods` global
--- @field settings LIVR.Rule Rule to validate `settings` global
--- @field feature_flags LIVR.Rule Rule to validate `feature_flags` global
local livr_prototype_rules = {}

