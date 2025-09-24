# Copilot Instructions for Factorio Mocks Generator

## Project Overview

The **Factorio Mocks Generator** is a comprehensive data extraction and validation pipeline that orchestrates Factorio
execution, processes game data, validates against API schemas, and extracts localization files. This repository contains
both Factorio mod components and standalone orchestration scripts.

**Architecture**: Dual-execution environment with Factorio mod and external processing
**Philosophy**: Accurate data extraction with comprehensive validation for reliable mock generation

### Core Architecture

The generator operates across two execution environments:

1. **Factorio Mod Environment** (`/mod` directory) - Runs within Factorio's Lua sandbox
2. **External Processing** (`/src` and `/bin` directories) - Standalone Lua scripts for orchestration and validation

### Key Architectural Decisions

- **Two-Command Architecture**: `build-rules` (API interaction) and `extract-and-validate` (main pipeline)
- **Stage-Based Extraction**: Data stage (prototype) and runtime stage (control) capture
- **External Validation**: LIVR rules generated from Factorio JSON API for data validation
- **Locale Processing**: ZIP file extraction for complete localization support
- **Serpent Serialization**: Lua code output format for mock data consumption

## Development Philosophy

### Accuracy Over Speed

- Data integrity is paramount - extraction must be completely accurate
- Validation against official Factorio API schemas ensures reliability
- Conservative error handling prevents corrupted mock data

### Factorio-Native Integration

- Works within Factorio's existing mod loading and sandbox environment
- Uses standard Factorio mod structure and conventions
- Leverages Factorio's built-in data stage and runtime stage separation

## Technical Context

### Current Implementation Status

- **Phase**: Foundation complete, ready for extraction implementation
- **Architecture**: `/mod`, `/src`, `/bin` directory structure established
- **Pipeline**: Two-command workflow designed (`build-rules` and `extract-and-validate`)
- **Dependencies**: Rockspec-based dependency management configured
- **Validation**: LIVR rule generation from Factorio JSON API planned

### Key Technologies

- **Factorio Lua API**: Data extraction within game environment
- **Serpent Library**: Lua table serialization to Lua code format
- **LuaRocks**: Dependency management via `factorio-mocks-generator-dev-1.rockspec`
- **LIVR Validation**: Schema validation for extracted data quality
- **ZIP Processing**: Locale extraction from mod archives

### Execution Environments

#### Factorio Mod Environment (`/mod`)

- **Runtime**: Factorio's embedded Lua 5.2 interpreter
- **Constraints**: Factorio's sandbox restrictions apply
- **Access**: Game data via `data.raw`, `prototypes`, `mods`, `settings`, `feature_flags`
- **Output**: Data stage uses `print()` to stdout, runtime stage uses `helpers.write_file()` to `script-output` within
  Factorio data directory

#### External Processing (`/src`, `/bin`)

- **Runtime**: System Lua 5.2 interpreter with full library access
- **Capabilities**: File system access, network operations, ZIP processing
- **Responsibilities**: Orchestration, validation, locale extraction, API interaction

## Code Standards and Conventions

### Lua Development Standards

**Style Guidelines:**

- **Indentation**: 2 spaces (matches `.editorconfig`)
- **Line Length**: 120 characters for Lua code (no limit for data output)
- **Naming**: snake_case for variables and functions
- **Quotes**: Double quotes for strings
- **Comments**: Explain WHY, not WHAT (follow self-explanatory code instructions)

### Factorio-Specific Patterns

**Mod Structure:**

- `info.json` - Standard Factorio mod metadata
- `data.lua` - Data stage entry point for prototype extraction
- `control.lua` - Runtime stage entry point for runtime extraction
- Extraction logic files parallel to main mod files (no nested `src` in `/mod`)

**Data Access Patterns:**

- **Data Stage**: Access via `data.raw`, `mods`, `settings.startup`, `feature_flags`
- **Runtime Stage**: Access via `prototypes` tables and `settings` runtime interface
- **Output Separation**: Different output mechanisms for different stages

### External Script Patterns

**Pipeline Orchestration:**

- Main script: `bin/generator.lua` with subcommand structure
- Process management for Factorio execution with proper termination
- Stdout capture for data stage output
- File system operations for runtime stage data collection

**Validation Approach:**

- LIVR rules generated from Factorio JSON API documentation
- Native Lua validation functions (no external dependencies in Factorio environment)
- Schema validation before data publication

## Development Workflow

### File Organization

```bash
factorio-mocks-generator/
├── mod/                          # Factorio mod files (runs in Factorio)
│   ├── info.json
│   ├── data.lua
│   ├── control.lua
│   ├── prototype-extractor.lua   # Data stage extraction logic
│   ├── runtime-extractor.lua     # Runtime stage extraction logic
│   └── serialization.lua         # Serpent-based data serialization
├── src/                          # External processing (runs outside Factorio)
│   ├── locale-extractor.lua      # ZIP file processing for localization
│   └── validation.lua            # LIVR-based data validation
├── bin/                          # Orchestration scripts
│   └── generator.lua             # Main pipeline orchestration
└── factorio-mocks-generator-dev-1.rockspec  # Dependency management
```

### Development Commands

**Setup Development Environment:**

```bash
# Install dependencies
luarocks install --only-deps factorio-mocks-generator-dev-1.rockspec

# Create mod symlink
New-Item -ItemType SymbolicLink -Path "$env:APPDATA\Factorio\mods\factorio-mocks-generator" -Target "$(pwd)/mod"
```

**Pipeline Operations:**

```bash
# Generate LIVR validation rules
lua bin/generator.lua build-rules <factorio-version>

# Extract and validate data
lua bin/generator.lua extract-and-validate <path-to-factorio>
```

### Testing Strategy

- **Vanilla Factorio**: Primary testing environment for consistency
- **Instrument Mode**: All testing requires `--instrument-mod` flag
- **Stage Isolation**: Test data stage and runtime stage extraction separately
- **Validation Testing**: Verify extracted data against generated LIVR rules

## Integration Points

### Factorio Game Integration

- **Mod Installation**: Standard Factorio mod installation and loading
- **Instrument Mode**: Required for extraction operations to function
- **Data Access**: Uses official Factorio Lua API for all data access
- **Output Directories**: Writes to Factorio's standard script-output directory

### External API Integration

- **Factorio JSON API**: Source for LIVR rule generation (no rate limiting)
- **GitHub Container Registry**: Future ORAS artifact distribution
- **File System**: ZIP processing and file management operations

## Common Patterns and Helpers

### Data Extraction Patterns

**Stage-Specific Access:**

```lua
-- Data stage (prototype-extractor.lua)
local function extract_data_stage()
  return {
    data_raw = data.raw,
    mods = mods,
    settings = settings.startup,
    feature_flags = feature_flags
  }
end

-- Runtime stage (runtime-extractor.lua)
local function extract_runtime_stage()
  return {
    prototypes = prototypes,
    settings = {
      startup = settings.startup,
      runtime = settings.runtime_per_player,
      global = settings.runtime_global
    }
  }
end
```

### Validation Patterns

**Schema Validation:**

```lua
-- External validation (src/validation.lua)
local function validate_extracted_data(data_path, rules_path)
  -- Load LIVR rules and validate data
  -- Return validation results with detailed errors
end
```

### Pipeline Orchestration

**Process Management:**

```lua
-- Orchestration (bin/generator.lua)
local function run_factorio_extraction(factorio_path, mod_path)
  -- Start Factorio with instrument mode
  -- Capture stdout for data stage
  -- Monitor script-output for runtime stage
  -- Ensure proper process termination
end
```

## Security Considerations

### Factorio Sandbox Environment

- **Built-in Security**: Runs within Factorio's Lua sandbox with limited file access
- **Controlled Output**: Only writes to designated script-output directory
- **No Network Access**: Factorio environment has no network capabilities

### External Processing Security

- **Path Validation**: Validate all file system paths before operations
- **ZIP Security**: Use safe extraction methods to prevent path traversal attacks
- **Process Safety**: Ensure proper Factorio process termination in all code paths
- **Input Validation**: Validate all extracted data against schemas before processing

## Troubleshooting and Common Issues

### Factorio Integration Issues

- **Instrument Mode**: Ensure `--instrument-mod` flag is used for all extractions
- **Mod Loading**: Verify mod is properly installed and enabled in Factorio
- **Output Location**: Check script-output directory for runtime stage data

### Data Quality Issues

- **Incomplete Extraction**: Verify both data stage and runtime stage completed successfully
- **Validation Failures**: Check LIVR rules are current and match Factorio version
- **Serialization Errors**: Ensure Serpent library handles all Factorio data types correctly

---

## Quick Reference

**Main Commands**: `lua bin/generator.lua build-rules <version>` and `extract-and-validate <path>`
**Architecture**: Factorio mod + external processing pipeline
**Dependencies**: Managed via `factorio-mocks-generator-dev-1.rockspec`
**Output Format**: Serpent-serialized Lua code for prototype/runtime data, .cfg files for localization
**Validation**: LIVR rules generated from Factorio JSON API
**Integration**: Standard Factorio mod with instrument mode requirement

## Technical References

### Factorio API Documentation

- **[Game Startup](https://lua-api.factorio.com/latest/auxiliary/data-lifecycle.html#game-startup)** - Game startup process
  and stage execution order for understanding mod initialization sequence
- **[Settings API](https://wiki.factorio.com/Tutorial:Mod_settings)** - Mod settings system for settings stage
  support and mocking capabilities
- **[Settings Stage](https://lua-api.factorio.com/latest/auxiliary/data-lifecycle.html#settings-stage)** - Understanding
  settings stage capabilities and data access
- **[Prototype API](https://lua-api.factorio.com/latest/index-prototype.html)** - API available during prototype stage
  (data stage) for data extraction
- **[Prototype Stage](https://lua-api.factorio.com/latest/auxiliary/data-lifecycle.html#prototype-stage)** - Understanding
  prototype-time (data stage) data availability and extraction timing
- **[Runtime API](https://lua-api.factorio.com/latest/index-runtime.html)** - API available during runtime stage
  (control stage) for Phase 3.1+ features
- **[Runtime Stage](https://lua-api.factorio.com/latest/auxiliary/data-lifecycle.html#save-startup)** - Understanding
  runtime stage (control stage) capabilities and data access
- **[Auxiliary API](https://lua-api.factorio.com/latest/index-auxiliary.html)** - Additional API documentation on important
  or advanced topics related to the modding API

### Factorio Development Resources

- **[Factorio Data Repository](https://github.com/wube/factorio-data)** - Official Factorio base game data definitions
  and prototype examples, including unreleased changes for future compatibility validation
- **[Mod Structure](https://lua-api.factorio.com/latest/auxiliary/mod-structure.html)** - Official mod file structure
  (`info.json`, `settings.lua`, `data.lua`, `control.lua`)
- **[Command Line Parameters](https://wiki.factorio.com/Command_line_parameters)** - Essential for headless Factorio
  operations and automated data extraction workflows
- **[Localisation](https://wiki.factorio.com/Tutorial:Localisation)** - Comprehensive guide to Factorio's localization
  system and LocalisedString handling
- **[Changelog Format](https://lua-api.factorio.com/latest/auxiliary/changelog-format.html)** - Standard mod changelog format
  for maintaining familiar documentation across all ecosystem repositories

## Ecosystem Context

**Main Repository**: [factorio-mocks](https://github.com/QuingKhaos/factorio-mocks) - Central coordination and documentation
**Data Distribution**: [factorio-mocks-data](https://github.com/QuingKhaos/factorio-mocks-data) - Generated mock data storage
**Data Consumption**: [factorio-mocks-loader](https://github.com/QuingKhaos/factorio-mocks-loader) - Runtime library for
mock data consumption
**Issue Tracking**: Centralized in main repository with `ecosystem: generator` labels
