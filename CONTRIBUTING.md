# Contributing to Factorio Mocks Generator

Thank you for your interest in contributing to the Factorio Mocks Generator! This repository is part of the
[Factorio Mocks Ecosystem](https://github.com/QuingKhaos/factorio-mocks) and serves as the automated data extraction
engine that generates mock data from Factorio installations.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Environment Setup](#development-environment-setup)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
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
- **Factorio**: at least version 2.0.66 installed
- **Lua 5.2**: For local development and testing (matches Factorio's version)
- **Text Editor/IDE**: VS Code recommended with Lua extensions

**Development Tools:**

- **markdownlint-cli**: For documentation linting (`npm install -g markdownlint-cli`)
- **Lua**: Lua 5.2 interpreter for local testing
- **LuaRocks**: For Lua dependency management

### Factorio Setup Requirements

The generator requires specific Factorio configuration for data extraction:

1. **Factorio Installation**: Steam, standalone or headless version
2. **Instrument Mode**: All installations must run with `--instrument-mod` flag for data extraction

### First-Time Setup

1. **Fork and Clone Repository**

   ```bash
   gh repo fork QuingKhaos/factorio-mocks-generator --clone
   cd factorio-mocks-generator
   ```

2. **Set Up Development Environment**

   ```bash
   # Install documentation tools
   npm install -g markdownlint-cli

   # Verify Lua installation (should be 5.2.x)
   lua -v

   # Verify Factorio installation
   factorio --version
   ```

3. **Review Project Structure**
   - Read `README.md` for generator overview
   - Review [ecosystem documentation](https://github.com/QuingKhaos/factorio-mocks)
   - Understand data extraction architecture

## Development Environment Setup

### Local Testing Environment

1. **Create Development Setup**:

   ```bash
   # Link repository to Factorio mods directory
   # Windows (PowerShell):
   New-Item -ItemType SymbolicLink -Path "$env:APPDATA\Factorio\mods\factorio-mocks-generator" -Target "$(pwd)/mod"

   # Linux/macOS:
   ln -s "$(pwd)/mod" ~/.factorio/mods/factorio-mocks-generator
   ```

2. **Install Dependencies**:

   ```bash
   # Install Lua dependencies using rockspec
   luarocks install --only-deps factorio-mocks-generator-dev-1.rockspec
   ```

3. **Test Extraction Setup**:

   ```bash
   # Build LIVR rules and run the extraction and validation process
   lua bin/generator.lua build-rules <factorio-version>
   lua bin/generator.lua extract-and-validate <path-to-factorio>
   ```

### Development Tools Setup

**Required for Development:**

- Lua 5.2 interpreter for local script testing
- Text editor with Lua syntax highlighting
- Git with proper configuration for commits

**Recommended Extensions (VS Code):**

- Lua language server
- Factorio Modding Tool Kit
- markdownlint

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
   markdownlint --config .markdownlint.json **/*.md
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
test(integration): add modpack compatibility tests
```

## Testing Guidelines

### Test Categories

#### Unit Tests

- Test individual extraction functions
- Validate data transformation logic
- Test utility functions and helpers

#### Integration Tests

- Test complete extraction workflows
- Verify output format compliance
- Test with real Factorio data

### Testing Requirements

**Before Submitting PRs:**

- [ ] All unit tests pass
- [ ] Integration tests pass with vanilla Factorio
- [ ] No regression in extraction accuracy
- [ ] Output format validation passes
- [ ] Documentation updated for new features

### Test Data Management

- **Vanilla Data**: Automated tests use vanilla Factorio installations
- **Test Fixtures**: Maintain consistent test data for reliability
- **Output Validation**: Verify extracted data meets schema requirements

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
- Provide examples for public functions

## Generator-Specific Considerations

### Factorio Version Compatibility

- **Supported Versions**: Currently targeting minimum Factorio 2.0.66
- **Lua Version**: Must use Lua 5.2 (Factorio's embedded version)
- **Backwards Compatibility**: Document version-specific behaviors

### Data Extraction Principles

**Accuracy First:**

- Preserve original data structure and types
- Maintain referential integrity between prototypes
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
2. **Include Test Results**: Show vanilla Factorio test passes
3. **Document Breaking Changes**: Highlight any API or format changes

### Review Criteria

**Code Quality:**

- Follows Lua coding standards
- Includes appropriate error handling

**Testing:**

- Unit tests for new functionality
- Integration test compatibility

**Documentation:**

- Documentation updates for new features
- Inline code documentation

## Community Guidelines

### Code of Conduct

We follow the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/). Key principles:

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
