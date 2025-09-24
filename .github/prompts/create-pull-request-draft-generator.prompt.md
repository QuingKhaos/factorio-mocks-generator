---
mode: 'agent'
description: 'Create an pull request draft document for for the current branch.'
tools: ['createFile', 'createDirectory', 'editFiles', 'search', 'terminalSelection', 'terminalLastCommand', 'runTasks', 'usages', 'vscodeAPI', 'problems', 'changes', 'testFailure', 'openSimpleBrowser', 'fetch', 'githubRepo', 'extensions']
---

<!-- Repository: factorio-mocks-generator -->

# Create Pull Request Draft

Create a pull request draft for the current branch using the repositories pull request template like we would create a
pull request from the GitHub UI.

## Inputs

- **Next PR number**: `${input:pr_number}`

## Input Validation

If any of the required inputs are not provided or cannot be determined from the conversation history, ask the user to
provide the missing information before proceeding with PR generation.

## Requirements

- Use precise, unambiguous language
- Follow standardized pull request template structure
- Ensure all sections are filled out appropriately
- Maintain professional and collaborative tone
- The title should be in the format of a conventional commit (e.g., `feat(scope): description`)
- Apply the appropriate labels based on the content of the PR

The PR draft must be saved in the `.github/drafts/pull-requests/` directory using the naming convention:
`pr-NNNN-[title-slug].md`, where NNNN is the next PR number with leading zeros.

## Required Documentation Structure

The documentation file must follow the template below, ensuring that all sections are filled out appropriately. The
front matter for the markdown should be structured correctly as per the example following:

```markdown
---
title: "docs(github): add pull request draft template"
labels: ["type: documentation"]
milestone: "Phase 1"
---
<!-- Use the correct pull request template like you would get if you created the pull request on GitHub -->
```
