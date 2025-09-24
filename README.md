[![GitHub build status: Quality Assurance](https://img.shields.io/github/actions/workflow/status/QuingKhaos/factorio-mocks-generator/qa.yml?branch=main&label=QA&style=for-the-badge)](https://github.com/QuingKhaos/factorio-mocks-generator/actions?query=workflow%3A%22Quality+Assurance%22)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/QuingKhaos/factorio-mocks-generator?label=Pull%20Requests&style=for-the-badge)](https://github.com/QuingKhaos/factorio-mocks-generator/pulls)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-support%20me-hotpink?logo=kofi&logoColor=white&style=for-the-badge)](https://ko-fi.com/quingkhaos)

# Factorio Mocks Generator - Data Extraction for Mod Testing

## Overview

Factorio mod for extracting game data to generate comprehensive mocks for mod testing.

Part of the [Factorio Mocks Ecosystem](https://github.com/QuingKhaos/factorio-mocks) - a five-repository system
providing complete testing infrastructure for Factorio mod development.

## 🎯 Purpose

The `factorio-mocks-generator` is a specialized Factorio mod that extracts comprehensive game data during different
stages of Factorio's mod loading process. This extracted data is then processed into Lua tables that enable
realistic testing of other Factorio mods without requiring a full game instance.

**Modpack Compatibility**: The generator works with any Factorio installation - from vanilla setups to complex modpacks.
It's used in the ecosystem to extract data from various modpack configurations for comprehensive testing scenarios.

**What it extracts:**

- `data.raw`, `mods`, `settings`, and `feature_flags` from data stage
- `prototypes` and runtime `settings` interface from control stage
- Localization strings across all loaded languages

## 🏗️ Architecture

### Extraction Stages

The generator operates during multiple stages of Factorio's mod loading process to capture different types of data:

1. **Data Stage (Prototype Stage)** - Extract `data.raw`, `mods`, `settings`, and `feature_flags`
2. **Control Stage (Runtime)** - Extract `prototypes` and runtime `settings` interface
3. **Localization Extraction** - Capture all localization strings from active mods after Factorio has run

### Output Format

Generated data is serialized using Serpent library as Lua code, locale data is preserved in original `.cfg` format:

```text
extracted-data/
├── prototype/         # Data stage settings and prototypes
├── runtime/           # Control stage runtime examples
├── locale/            # All language strings combined, one file per language
└── metadata.json      # Extraction metadata and checksums
```

## 🚀 Current Status

**Phase**: Early Development - Planning and Architecture Complete

**Implementation Status:**

- ✅ **Foundation Setup** - Repository infrastructure and documentation
- ⏳ **Prototype Stage Extraction** - Extract `data.raw`, `mods`, `settings`, `feature_flags`
- ⏳ **Runtime Stage Extraction** - Extract `prototypes` and runtime `settings`
- ⏳ **Localization Extraction** - Extract all available localization strings
- ⏳ **Data Validation** - Data quality checks and validation logic
- ⏳ **Distribution Integration** - Git and ORAS publishing to GitHub Container Registry

## 🎮 How It Works

### Two-Command Architecture

The generator uses a dual-execution environment with external orchestration:

```bash
# Generate LIVR validation rules from Factorio JSON API
lua bin/generator.lua build-rules <factorio-version>

# Extract and validate Factorio data
lua bin/generator.lua extract-and-validate <path-to-factorio>
```

### 1. Validation Rules Generation (`build-rules`)

External script that prepares validation schemas:

- **Factorio JSON API**: Fetches official API documentation
- **LIVR Rule Generation**: Creates validation rules for data quality
- **Schema Preparation**: Sets up validation for extraction pipeline
- **No Factorio Required**: Runs independently using web APIs

### 2. Data Extraction Pipeline (`extract-and-validate`)

Orchestrates Factorio execution and processes results:

1. **Factorio Mod Installation**: Links `/mod` directory to Factorio mods folder
2. **Instrument Mode Execution**: Runs Factorio with `--instrument-mod` flag
3. **Dual-Stage Capture**:
   - **Data Stage**: Stdout capture for `data.raw`, `mods`, `settings`, `feature_flags`
   - **Runtime Stage**: File monitoring for `prototypes` and runtime `settings`
4. **External Processing**: ZIP extraction for localization, data validation, serialization
5. **Output Generation**: Serpent-serialized Lua code and `.cfg` locale files

### Technical Implementation

**Factorio Environment** (`/mod`):

- Runs in Factorio's Lua 5.2 sandbox with API access
- Limited to `print()` and `helpers.write_file()` for output

**External Processing** (`/src`, `/bin`):

- Full system Lua with file system and network access
- Handles orchestration, validation, and artifact generation

## 🔧 Development Setup

### Prerequisites

- **Factorio** (2.0.66+) installed
- **Lua 5.2** knowledge for mod development (Factorio's Lua version)
- **Git** and **GitHub CLI** for repository management

### Quick Start

For detailed development setup, see the [Contributing Guide](CONTRIBUTING.md#development-environment-setup).

**Basic Installation**:

1. Clone the repository
2. Create symlink to Factorio mods directory
3. Run extract and validate command

### Testing Strategy

- **Unit Tests**: Individual extraction functions
- **Validation Tests**: Verify extracted data against expected schemas
- **Automated Testing**: Vanilla Factorio setup for consistent CI/CD testing
- **Modpack Compatibility**: Production use with various modpack configurations

## 📚 Documentation

### For Contributors

- **[Contributing Guide](CONTRIBUTING.md)** - How to contribute to this repository
- **[Code of Conduct](CODE_OF_CONDUCT.md)** - Community standards and expectations
- **[Security Policy](SECURITY.md)** - Reporting security issues

### For Ecosystem

- **[Main Documentation](https://github.com/QuingKhaos/factorio-mocks)** - Full ecosystem overview
- **[Architecture Decisions](https://github.com/QuingKhaos/factorio-mocks/tree/main/planning/decisions)** - Technical
  decision records
- **[Implementation Roadmap](https://github.com/QuingKhaos/factorio-mocks/blob/main/planning/implementation-roadmap.md)**
  - Development phases

## 🤝 Contributing

We welcome contributions from Factorio modders and developers! The generator is a critical component that enables the
entire testing ecosystem.

### Ways to Contribute

- **Lua Development**: Improve extraction logic and add new data sources
- **Data Validation**: Help ensure extracted data validation is complete and accurate
- **Documentation**: Improve guides and API documentation
- **Testing**: Add test cases

### Getting Started

1. Read the [Contributing Guide](CONTRIBUTING.md)
2. Check [open issues](https://github.com/QuingKhaos/factorio-mocks/issues?q=is%3Aopen+label%3A%22ecosystem%3A+generator%22)
   for generator-specific tasks
3. Look for [`good-first-issue`](https://github.com/QuingKhaos/factorio-mocks/issues?q=is%3Aopen+label%3A%22good-first-issue%22+label%3A%22ecosystem%3A+generator%22)
   labels for beginner-friendly tasks

**Note**: Issues are tracked centrally in the [main repository](https://github.com/QuingKhaos/factorio-mocks/issues)
with `ecosystem: generator` labels.

## 📄 License

This project is licensed under the GNU General Public License v3.0 (GPLv3). See [LICENSE](LICENSE) for details.

**Why GPLv3?** This license ensures that improvements to the extraction tools remain open source while maintaining
strong copyleft protections for the codebase.

## 🔗 Ecosystem Links

- **[factorio-mocks](https://github.com/QuingKhaos/factorio-mocks)** - Central hub and main documentation
- **[factorio-mocks-modpacks](https://github.com/QuingKhaos/factorio-mocks-modpacks)** - Curated modpack configurations
- **[factorio-mocks-data](https://github.com/QuingKhaos/factorio-mocks-data)** - Generated mock data artifacts
- **[factorio-mocks-loader](https://github.com/QuingKhaos/factorio-mocks-loader)** - Runtime library for consuming
  mock data

## 💖 Support

If this project helps your Factorio mod development, consider supporting its development:

[![Ko-fi](https://img.shields.io/badge/Ko--fi-support%20this%20project-hotpink?logo=kofi&logoColor=white&style=for-the-badge)](https://ko-fi.com/quingkhaos)

---

**Status**: 🚧 Early Development Phase - Infrastructure setup and planning complete, implementation beginning.
