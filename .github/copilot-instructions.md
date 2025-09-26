# Copilot Instructions for Factorio Mocks Generator

## Architecture Overview

**Pure Data Extraction Tool** that extracts Factorio game data for the five-repository Factorio Mocks Ecosystem.

**Core Purpose**: Extract validated, human-readable Factorio data during prototype and runtime stages for consumption
by `factorio-mocks-loader`.

**Repository Structure** (to be implemented):

```bash
factorio-mocks-generator/
├── mod/                      # Factorio mod files (runs inside Factorio)
├── src/                      # Standalone Lua scripts (validation, processing)
├── bin/                      # CLI orchestration with argparse subcommands
└── factorio-mocks-generator-dev-1.rockspec
```

## Critical Architectural Decisions

### Extraction Stages & Data Flow

**Prototype Stage**: Extract `data.raw`, `mods`, `settings`, `feature_flags` during Factorio's data loading phase
**Runtime Stage**: Extract `prototypes` and runtime `settings` during control phase initialization
**Localization**: Extract `.cfg` files from mod archives and merge per language

**Data Pipeline**: Factorio Execution → Raw Data → Serpent Serialization → LIVR Validation → File Output

### Output Format Requirements

**Serpent Configuration**: Human-readable format with 2-space indent, sorted keys, `nocode=true` for git diff-friendliness
**File Organization**: `prototype/`, `runtime/`, `locale/` directories with type-specific files
**Metadata**: Generate `metadata.json` with build timestamps, Factorio version and integrity checksums

## Development Context

### External Dependencies

**Factorio Integration**: Targets Factorio latest stable version (will be pinned)
**Validation**: Auto-generate LIVR rules from `https://lua-api.factorio.com/{version}/prototype-api.json` and `runtime-api.json`
**Libraries**: [lua-LIVR](https://fperrad.frama.io/lua-LIVR/), [lua-http](https://daurnimator.github.io/lua-http/0.4/), [argparse](https://github.com/luarocks/argparse)

### CLI Design Pattern

**Entry Point**: `bin/generator.lua` with subcommands for different extraction types
**Usage Context**: Designed for CI/CD automation but supports manual developer usage
**GitHub Actions**: Headless Factorio execution in CI to run extraction and temporarily push artifacts to `factorio-mocks-data`

### Ecosystem Integration

**Standalone Library**: No knowledge of modpacks - consumed by `factorio-mocks-modpacks` but doesn't coordinate with it
**Issue Tracking**: All issues filed in main `factorio-mocks` repo with `ecosystem: generator` label
**Temporary Responsibility**: Until Phase 2, generator GitHub Actions push artifacts to `factorio-mocks-data`

## Development Standards

### Lua Coding Conventions

**Style**: Follow `.editorconfig` - 2-space indent, double quotes, 120-char limit, `snake_case` naming
**Dependencies**: Lua 5.2 compatibility, manage via `factorio-mocks-generator-dev-1.rockspec`
**Architecture**: ADR-0005 mandates Lua-focused implementation for ecosystem consistency

### Data Quality Requirements

**Human Readability**: No compression - all outputs must be readable and git diff-friendly
**Validation**: Fail-fast validation using LIVR rules generated from Factorio's official API documentation
**Integrity**: Include checksums and metadata for downstream consumption validation

## Testing & Validation

**Unit Testing**: Use [busted](https://lunarmodules.github.io/busted/) framework for Lua unit tests following best practices
**Integration Testing**: GitHub Actions pipeline verifying complete extraction workflow with headless Factorio binary
**Local Development**: Both headless and graphical Factorio instances supported for manual testing
**Testing Scope**: Generator only extracts from vanilla Factorio - modpack configurations handled by `factorio-mocks-modpacks`

---

**Planning Context**: Cross-reference `factorio-mocks/planning/implementation-roadmap.md` Phase 1.2 before implementation
**Ecosystem Documentation**: See `factorio-mocks/planning/architecture.md` for complete ecosystem context
