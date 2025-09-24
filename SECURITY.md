# Security Policy

## Supported Versions

This project is currently in early development phase. Security updates will be provided for:

| Version | Supported          |
| ------- | ------------------ |
| main    | :white_check_mark: |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security vulnerability, please report it by:

1. **DO NOT** open a public issue
2. Use GitHub's private vulnerability reporting feature in this repository: [Security Advisories](https://github.com/QuingKhaos/factorio-mocks-generator/security/advisories)

### What to Include

Please include as much information as possible:

- Description of the vulnerability
- Steps to reproduce the issue
- Factorio version and mod configuration (if applicable)
- Potential impact and affected components
- Suggested fix (if any)
- Your contact information for follow-up

### Response Timeline

- **Acknowledgment**: Within 72 hours
- **Initial Assessment**: Within 7 days
- **Resolution**: Varies based on complexity and severity

## Security Considerations

The Factorio Mocks Generator is a comprehensive extraction and validation pipeline that orchestrates Factorio execution,
processes game data, validates against API schemas, and extracts localization files.

### Architecture Overview

- **Rule Generation**: `lua bin/generator.lua build-rules <factorio-version>` - Generates LIVR rules from Factorio JSON API
- **Data Extraction**: `lua bin/generator.lua extract-and-validate <path-to-factorio>` - Main extraction process
- **Process Control**: Starts Factorio with instrument mode, captures stdout, manages termination
- **Data Pipeline**: Extracts prototype data (stdout) and runtime data (script-output directory)
- **Validation**: Validates extracted data against pre-generated LIVR rules
- **Locale Processing**: Extracts .cfg files from mod ZIP archives

### Security Features

- **Factorio Sandbox**: Game data extraction runs within Factorio's Lua sandbox
- **Process Isolation**: Factorio runs as separate process with controlled termination
- **Controlled File Access**: Reads from script-output and mod directories, validates paths
- **Network Boundaries**: API access limited to Factorio JSON API for LIVR rule generation (build-rules command only)
- **Output Validation**: All extracted data validated against pre-generated LIVR rules

### Security Practices

- **Path Validation**: Factorio installation path validated before process launch
- **Process Management**: Factorio process properly terminated after extraction
- **File System Safety**: ZIP extraction with path traversal protection
- **Error Isolation**: Failures in one extraction stage don't compromise others
- **Clean Output**: Generated files contain only validated game data

### For Contributors

- **Process Safety**: Ensure proper Factorio process termination in all code paths
- **Path Validation**: Validate all file system paths before operations
- **ZIP Security**: Use safe extraction methods to prevent path traversal attacks
- **API Security**: Implement error handling for JSON API access (build-rules command)
- **Output Validation**: Validate all extracted data against pre-generated LIVR rules before processing
- **Error Handling**: Ensure sensitive paths or process information aren't exposed in errors
- **Resource Cleanup**: Clean up temporary files, processes, and network connections

## Security Contacts

For security-related questions or concerns:

- **GitHub Security**: Use private vulnerability reporting in [this repository](https://github.com/QuingKhaos/factorio-mocks-generator/security/advisories)
- **Community**: General security discussions in [GitHub Discussions](https://github.com/QuingKhaos/factorio-mocks/discussions)

---

*This security policy reflects the Phase 1 implementation as a comprehensive extraction and validation pipeline.*
