<!-- markdownlint-disable MD041 -->

<!--
Thank you for contributing to the Factorio Mocks Generator!
Please fill out this template to help us review your data extraction improvements effectively.
-->

## Overview

### Summary

<!-- Provide a brief description of what this PR accomplishes -->

### Type of Change

<!-- Please check the boxes that apply to your PR -->

- [ ] 🐛 Bug fix (fixes data extraction/validation issues)
- [ ] ✨ New feature (adds extraction/validation capabilities)
- [ ] 🔧 Technical improvement (code refactoring, better error handling)
- [ ] 📚 Documentation update (README, inline docs, examples)
- [ ] 🧪 Testing improvement (new tests, better test coverage)
- [ ] 🔨 Build/CI change (workflows, dependencies, tooling)

### Related Issues

<!-- Link any related issues from the main ecosystem repository -->

- Closes QuingKhaos/factorio-mocks#
- Related to QuingKhaos/factorio-mocks#
- Part of QuingKhaos/factorio-mocks#

## Changes Made

### Key Changes

<!-- List the main changes made in this PR -->

- Change 1
- Change 2
- Change 3

### Extraction Improvements

<!-- If this affects data extraction, describe the improvements -->

- **New Data Types**: [e.g., fluid prototypes, custom entities]
- **Accuracy Improvements**: [e.g., better property handling, fixed edge cases]
- **Compatibility**: [e.g., supports new Factorio version, handles mod X]

### Files Modified

<!-- Highlight important files and explain what changed in each -->

## Quality Checklist

### Code Quality

- [ ] My code follows Lua coding standards (2 spaces, snake_case, double quotes)
- [ ] I have performed a self-review of my extraction logic
- [ ] I have commented complex extraction/validation functions and Factorio-specific handling
- [ ] My changes generate no new warnings or errors
- [ ] Error handling is appropriate for data extraction failures

### Data Extraction Testing

- [ ] I have tested extraction with vanilla Factorio installation
- [ ] Extracted data validates against expected schemas
- [ ] Output format is correct (Lua tables/locale .cfg files)
- [ ] No data loss or corruption in the extraction process

### Documentation

- [ ] Updated documentation if new features or requirements added
- [ ] Added inline documentation for complex extraction/validation functions
- [ ] Examples provided for new capabilities

## Testing Details

### Test Environment

<!-- Describe how you tested these changes -->

- **Operating System**: [e.g., Windows 11, Ubuntu 24.04]
- **Factorio Version**: [e.g., 2.0.66]
- **Lua Version**: [e.g., 5.2.4]

### Extraction Test Results

- [ ] All entity types extracted successfully
- [ ] Data validation passes
- [ ] Output format correct

## Factorio-Specific Considerations

### Version Compatibility

- [ ] This change maintains compatibility with supported Factorio versions
- [ ] Any version-specific code is properly documented
- [ ] Breaking changes in Factorio API are handled appropriately

### Output Format Validation

- [ ] Generated data are syntactically valid Lua 5.2
- [ ] Data can be successfully loaded as Lua tables
- [ ] Data structure follows expected format

## Backward Compatibility

### Breaking Changes

- [ ] This PR introduces breaking changes to extraction output
- [ ] Migration guide provided for consumers
- [ ] Version compatibility documented

### Migration Guide

<!-- If breaking changes exist, provide migration instructions -->

```text
Example migration steps for consumers of generated data
```

## Examples

<!-- If applicable, add examples of newly extracted data -->

## Additional Notes

### Implementation Notes

<!-- Any additional context about extraction algorithms or Factorio specifics -->

### Questions for Reviewers

<!-- Specific questions about extraction logic or Factorio compatibility -->

---

## For Maintainers

### Review Checklist

<!-- Maintainers: Check these items during review -->

- [ ] Extraction logic is sound
- [ ] Data validation is comprehensive
- [ ] Factorio compatibility verified
- [ ] Output format standards maintained
- [ ] Unit tests and integration tests passed
- [ ] Documentation accurately reflects changes

### Deployment Notes

<!-- Maintainers: Any special considerations for generator deployment -->
