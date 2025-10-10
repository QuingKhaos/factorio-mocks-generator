# Contributing to Factorio Mocks Generator

Thank you for your interest in contributing to the Factorio Mocks Generator! This repository is part of the
[Factorio Mocks Ecosystem](https://github.com/QuingKhaos/factorio-mocks) and serves as the automated data extraction
engine that generates mock data from Factorio installations.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Environment Setup](#development-environment-setup)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Documentation Guidelines](#documentation-guidelines)
- [Generator-Specific Considerations](#generator-specific-considerations)
- [Issue and Pull Request Process](#issue-and-pull-request-process)
- [Community Guidelines](#community-guidelines)
- [Security Considerations](#security-considerations)
- [Useful Resources](#useful-resources)

## Getting Started

### Prerequisites

**Core Requirements:**

- **Git**: For version control
- **GitHub Account**: For collaboration
- **GitHub CLI** (recommended): For easier repository management
- **Factorio**: at least version 2.0.69 installed
- **Lua**: Lua 5.4 interpreter for local testing
- **LuaRocks**: For Lua dependency management
- **Text Editor/IDE**: VS Code recommended with Lua extensions

**Development Tools:**

- **markdownlint-cli**: For documentation linting (`npm install -g markdownlint-cli`)

**Windows-Specific Setup:**

If you're on Windows and need to set up a complete Lua development environment with native compilation support,
see the [Windows Lua Setup Guide](https://gist.github.com/QuingKhaos/9181110762b3a0367ea2e49764f9195e) which covers
Lua 5.4 + LuaRocks + MinGW-w64 installation.

### First-Time Setup

1. **Fork and Clone Repository**

   ```bash
   gh repo fork QuingKhaos/factorio-mocks-generator --clone
   cd factorio-mocks-generator
   ```

2. **Link the mods in `mods/` to `.factorio/mods/`**

   ```bash
   # Linux/macOS - create symbolic link:
   ln --symbolic --relative $(pwd)/mods/factorio-mocks-generator $(pwd)/.factorio/mods/factorio-mocks-generator

   # Windows - create junction link:
   cmd /c "mklink /J .factorio\mods\factorio-mocks-generator mods\factorio-mocks-generator"
   ```

3. **Set Up Development Environment**

   ```bash
   # Install documentation tools
   npm install -g markdownlint-cli

   # Verify Lua and LuaRocks installation
   lua -v
   luarocks --version

   # Verify Factorio installation
   factorio --version
   ```

4. **Install Dependencies**:

   ```bash
   # Install Lua dependencies using rockspec
   luarocks install --tree vendor --only-deps factorio-mocks-generator-dev-1.rockspec
   ```

5. **Review Project Structure**
   - Read `README.md` for generator overview
   - Review [ecosystem documentation](https://github.com/QuingKhaos/factorio-mocks)
   - Understand data extraction architecture

## Development Environment Setup

### Local Testing Environment

1. **Test Extraction Setup**:

   ```bash
   # Run factorio to extract data
   factorio --config .factorio/config/config.ini --load-scenario base/freeplay
   ```

2. **Generate LIVR rules**:

   ```bash
   lua -lpaths bin/factorio-mocks-generator.lua generate-livr-rules stable
   ```

3. **Validate extracted data**:

   ```bash
   lua -lpaths bin/factorio-mocks-generator.lua validate .factorio/script-output
   ```

### Development Tools Setup

**Required for Development:**

- Lua 5.4 interpreter for local testing
- Text editor with Lua syntax highlighting
- Git with proper configuration for commits

**Recommended Extensions (VS Code):**

- Lua language server
- Factorio Modding Tool Kit
- markdownlint

For optional but full IntelliSense support, follow these steps:

1. Enable [Manage Library Data Links](vscode://settings/factorio.workspace.manageLibraryDataLinks) in the workspace settings.

2. **Select Factorio version** to link to the correct data files:
   - Open Command Palette (`Ctrl+Shift+P`)
   - Run: `Factorio: Select Version`

3. Add the LuaRocks vendor path `vendor/share/lua/5.4` to
   the [`Lua.workspace.library`](vscode://settings/Lua.workspace.library) workspace setting.

4. Enable the following libs via **LLS-Addons**:
   - Open Command Palette (`Ctrl+Shift+P`)
   - Run: `Lua: Open Addon Manager`
   - Enable:
     - argparse
     - busted
     - CJSON
     - luassert

   Choose `factorio-mocks-generator` to enable these libraries. This will modify the projects `.vscode/settings.json`.
   You need to move these changes to the workspace settings file to avoid committing them:

   - Open Command Palette (`Ctrl+Shift+P`)
   - Run: `Preferences: Open Workspace Settings (JSON)`
   - Merge the content of the projects `Lua.workspace.library` with your workspaces `Lua.workspace.library` setting.
   - Discard any changes to `.vscode/settings.json` via `git restore .vscode/settings.json`.

## Development Workflow

### Branch Strategy

- **main**: Stable, tested generator code
- **feature branches**: `feat/extraction-improvement` for new extraction features
- **fix branches**: `fix/vanilla-data-bug` for bug fixes
- **docs branches**: `docs/api-documentation` for documentation updates

### Standard Workflow

1. **Create Feature Branch**

   ```bash
   git checkout -b feat/your-extraction-feature
   ```

2. **Develop and Test**
   - Write Lua code following project standards
   - Test with local Factorio installation
   - Verify data extraction accuracy

3. **Quality Checks**

   ```bash
   # Run documentation linting
   markdownlint --config .markdownlint.json --dot **/*.md

   # Run code linting
   vendor/bin/luacheck .

   # Run unit and integration tests with coverage reporting
   rm luacov.*.out; vendor/bin/busted; vendor/bin/luacov
   ```

4. **Commit and Push**

   ```bash
   git add .
   git commit -m "feat: improve entity data extraction accuracy"
   git push origin feat/your-extraction-feature
   ```

5. **Create Pull Request**

   ```bash
   # Push your changes first
   git push origin feat/your-extraction-feature
   ```

   Then create a pull request through the GitHub web interface to ensure the PR template is properly applied:
   `https://github.com/QuingKhaos/factorio-mocks-generator/compare/main...your-branch-name`

## Coding Standards

### Lua Code Standards

**Style Guidelines:**

- **Indentation**: 2 spaces (no tabs)
- **Line Length**: 120
- **Naming**: snake_case for variables and functions
- **Quotes**: Double quotes
- **Comments**: Explain WHY, not WHAT (see self-explanatory code instructions)

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Generator-Specific Types:**

- `feat`: New extraction features or capabilities
- `fix`: Bug fixes in data extraction or output
- `test`: Adding or updating tests
- `docs`: Documentation changes

**Examples:**

```text
feat(extraction): add support for fluid prototype extraction
fix(validation): correct entity property validation schema
```

## Documentation Guidelines

### Markdown Standards

Follow the repository's `.markdownlint.json` configuration:

- Maximum line length: 120 characters
- Use ATX headings (`#`, `##`, `###`)
- Consistent list formatting with dashes (`-`)
- Proper noun capitalization (Factorio, GitHub, Lua, ORAS)

### Code Documentation

**Lua Documentation:**

- Document complex extraction algorithms
- Explain Factorio-specific data handling

## Generator-Specific Considerations

### Factorio Version Compatibility

- **Supported Versions**: Currently targeting minimum Factorio 2.0.69
- **Backwards Compatibility**: Document version-specific behaviors

### Data Extraction Principles

**Accuracy First:**

- Preserve original data structure and types
- Validate extracted data against known schemas

## Issue and Pull Request Process

### Reporting Issues

**Important**: Report all issues in the [main ecosystem repository](https://github.com/QuingKhaos/factorio-mocks/issues)
for centralized tracking. Use the component selector to specify "Generator" as the affected component.

**Issue Categories:**

- **Data Extraction Bugs**: Incorrect or missing data in output
- **Compatibility Problems**: Issues with specific Factorio versions or mods
- **Feature Requests**: New extraction capabilities or improvements

### Pull Request Guidelines

1. **Use Conventional Commit Format** in PR titles
2. **Document Breaking Changes**: Highlight any API or format changes

### Review Criteria

**Code Quality:**

- Follows Lua coding standards
- Includes appropriate error handling

**Testing:**

- Tests for new functionality

**Documentation:**

- Documentation updates for new features
- Inline code documentation

## Community Guidelines

### Code of Conduct

We follow the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). Key principles:

- **Be Respectful**: Treat all contributors with respect
- **Be Inclusive**: Welcome people of all backgrounds and experience levels
- **Be Collaborative**: Work together constructively
- **Be Professional**: Maintain professional conduct in all interactions

### Getting Help

- **New Contributors**: Look for `good-first-issue` labels
- **Questions**: Use [GitHub Discussions](https://github.com/QuingKhaos/factorio-mocks/discussions) in the main repository
- **Technical Issues**: Reference generator documentation and existing issues
- **Stuck?**: Ask for help in discussions or comment on relevant issues

## Security Considerations

### Reporting Security Issues

- **Never** create public issues for security vulnerabilities
- Use GitHub's private vulnerability reporting feature
- Follow responsible disclosure practices

## Useful Resources

- [Main Ecosystem Repository](https://github.com/QuingKhaos/factorio-mocks)
- [Factorio Lua API Documentation](https://lua-api.factorio.com/)
- [Factorio Data Lifecycle](https://lua-api.factorio.com/latest/auxiliary/data-lifecycle.html)
- [Conventional Commits](https://www.conventionalcommits.org/)

Thank you for contributing to the Factorio Mocks Generator! 🏭⚙️
