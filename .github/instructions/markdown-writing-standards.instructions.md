---
description: 'Guidelines for writing markdown files that comply with the repository markdownlint configuration and maintain consistency across all documentation.'
applyTo: '**/*.md'
---

# Markdown Writing Guidelines

## Core Principle

**All markdown files must comply with the repository's `.markdownlint.json` configuration to ensure consistency, readability,
and automated quality assurance.**

These guidelines help you write markdown that passes linting from the start, avoiding the need for post-writing corrections.

## Repository Markdown Configuration

*This section reflects the current `.markdownlint.json` configuration. When the configuration changes, this instruction
file must be updated accordingly.*

### Line Length and Formatting

- **Maximum line length**: 120 characters (except code blocks and tables) *[from `.markdownlint.json` → `line-length.line_length`]*
- **Code blocks**: No line length restrictions *[from `.markdownlint.json` → `line-length.code_blocks: false`]*
- **Tables**: No line length restrictions *[from `.markdownlint.json` → `line-length.tables: false`]*
- **Long URLs**: Break into reference-style links when needed

### Heading Standards

- **Style**: ATX headings (`#` `##` `###`) only
- **First line**: Must be H1 (`#`) with preamble allowed (YAML front matter)
- **Hierarchy**: Follow logical progression (H1 → H2 → H3, don't skip levels)
- **Duplicate headings**: Allowed only if they're siblings (same level)

### Code and Emphasis

- **Code blocks**: Always use fenced style with backticks
- **Code fence language**: Must specify language from allowed list
- **Emphasis**: Use asterisks (`*italic*` `**bold**`) not underscores
- **Strong text**: Use double asterisks (`**text**`)

### Lists and Structure

- **Unordered lists**: Use dashes (`-`) not asterisks or plus signs
- **Ordered lists**: Use sequential numbering (`1.` `2.` `3.`)
- **Horizontal rules**: Use three dashes (`---`)

### Links and Images

- **Link style**: Use reference-style for repeated or long URLs
- **Image style**: Use reference-style for consistency
- **No shortcuts**: Avoid collapsed reference links

## Allowed Code Block Languages

*This list must match `.markdownlint.json` → `fenced-code-language.allowed_languages`*

When using fenced code blocks, use only these languages:

```text
bash, dockerfile, gitignore, json, lua, markdown, powershell, text, yaml
```

**Sync Note**: If the configuration changes, update this list and all examples accordingly.

### Adding New Languages

**If you need a language not in the allowed list:**

1. **Consider**: Is this language truly necessary for the project's documentation?
2. **Confirm**: Get approval from project maintainers before expanding the allowed languages list
3. **Justify**: Document why this language is needed and how it supports project goals
4. **Update Config**: Add the language to `.markdownlint.json` → `fenced-code-language.allowed_languages`
5. **Update Instructions**: Include the new language in the list above
6. **Verify Sync**: Run the sync script to confirm: `PowerShell -ExecutionPolicy Bypass -File .\.github\scripts\sync-markdown-instructions.ps1`

**Common languages you might want to add:**

- `typescript` - For TypeScript code examples
- `python` - For Python scripts or examples
- `c` - For C code examples
- `rust` - For Rust code examples
- `sql` - For database queries
- `xml` - For XML configuration files
- `toml` - For TOML configuration files

### Examples

**Correct:**

```lua
-- Factorio mod code
function example()
    return "Hello Factorio"
end
```

**Incorrect:**

```javascript
// Not currently in the allowed languages list
function example() {
    return "Hello";
}
```

## Proper Nouns

*This list must match `.markdownlint.json` → `proper-names.names`*

The following proper nouns must be capitalized correctly:

- **Crowdin** (not `crowdin`, `CROWDIN`)
- **Factorio** (not `factorio`, `FACTORIO`)
- `factorio-mocks` (repository name - always use backticks)
- `factorio-mocks-generator` (repository name - always use backticks)
- `factorio-mocks-modpacks` (repository name - always use backticks)
- `factorio-mocks-data` (repository name - always use backticks)
- `factorio-mocks-loader` (repository name - always use backticks)
- **GitHub** (not `Github`, `github`)
- **.github** (folder name, used in custom html elements and URLs)
- **github.com** (not `Github.com`)
- **github.io** (not `Github.io`)
- **Ko-fi** (not `kofi`, `Ko-Fi`)
- **Lua** (not `lua`, `LUA`)
- `lua-http` (Lua HTTP library name)
- `lua-LIVR` (Lua LIVR validation library name)
- `lua-LIVR-extra` (Extended LIVR validation library name)
- **LuaRocks** (not `luarocks`, `Luarocks`)
- **ORAS** (not `oras`, `Oras`)
- **Wube** (not `wube`, `WUBE`)

**Sync Note**: When proper nouns are added to or removed from the configuration, update this list immediately.

## Repository Names

**All five ecosystem repository names must always be formatted as inline code with backticks:**

- `factorio-mocks` - Central hub repository (this repo)
- `factorio-mocks-generator` - Data extraction from Factorio installations
- `factorio-mocks-modpacks` - Curated mod combinations and configurations
- `factorio-mocks-data` - Generated mock data artifacts
- `factorio-mocks-loader` - Runtime library for consuming mock data

**Rationale**: Repository names are technical identifiers that should be distinguished from regular text, making them
easier to identify and preventing confusion with descriptive text.

**Examples:**

✅ **Correct:**

```markdown
The `factorio-mocks-generator` repository contains the extraction logic.
Install the `factorio-mocks-loader` library using LuaRocks.
```

❌ **Incorrect:**

```markdown
The factorio-mocks-generator repository contains the extraction logic.
Install the **factorio-mocks-loader** library using LuaRocks.
```

**Exception**: Repository names in URLs, file paths, and code examples maintain their original formatting.

## Writing Best Practices

### Structure and Organization

#### Document Structure

```markdown
---
# YAML front matter (optional but allowed)
---

# Document Title

Brief introduction paragraph.

## Major Section

Content organized logically.

### Subsection

Detailed information.

## Another Major Section

Continue logical organization.
```

#### Heading Guidelines

- **H1**: Document title (one per document)
- **H2**: Major sections
- **H3**: Subsections within major sections
- **H4**: Detailed subsections (use sparingly)

#### Content Flow

- Start with brief introduction
- Use headings to create clear navigation structure
- Group related information under appropriate headings
- End with summary or next steps when relevant

### Lists and Items

#### Unordered Lists

```markdown
- First item
- Second item
  - Nested item (2 spaces)
  - Another nested item
- Third item
```

#### Ordered Lists

```markdown
1. First step
2. Second step
   1. Sub-step (3 spaces for alignment)
   2. Another sub-step
3. Third step
```

#### Task Lists

```markdown
- [ ] Uncompleted task
- [x] Completed task
- [ ] Another uncompleted task
```

### Code and Technical Content

#### Inline Code

Use backticks for inline code: `variable`, `function()`, `file.md`

#### Code Blocks

Always specify language:

```markdown
Example YAML configuration:

​```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
​```
```

#### File Paths

Use inline code for file paths: `planning/architecture.md`

#### Commands

Use code blocks for terminal commands:

```bash
# Install dependencies
npm install -g markdownlint-cli
```

### Links and References

#### Reference-Style Links

For repeated or long URLs:

```markdown
See the [GitHub documentation][github-docs] for more information.
The [planning documents][planning] contain detailed specifications.

[github-docs]: https://docs.github.com/en/actions
[planning]: https://github.com/QuingKhaos/factorio-mocks/tree/main/planning
```

#### Inline Links

For short, one-time URLs:

```markdown
Visit [GitHub](https://github.com) for the source code.
```

### Tables

#### Standard Tables

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Value 1  | Value 2  | Value 3  |
| Value A  | Value B  | Value C  |
```

#### Alignment

```markdown
| Left Aligned | Center Aligned | Right Aligned |
|:-------------|:--------------:|--------------:|
| Left         |     Center     |         Right |
```

### Emphasis and Formatting

#### Text Emphasis

- **Bold text**: `**important information**`
- *Italic text*: `*emphasized text*`
- ***Bold italic***: `***very important***`

#### Avoid Emphasis as Headings

Don't use bold text as section headers - use proper headings:

**Wrong:**

```markdown
**Section Title**
Content here.
```

**Correct:**

```markdown
## Section Title
Content here.
```

## Common Patterns for This Project

### Architectural Decision Records

```markdown
---
status: "Accepted"
date: "2025-09-22"
authors: "Architecture Team"
tags: ["architecture", "decision"]
---

# ADR-NNNN: Decision Title

## Status

Accepted

## Context

Background information and problem statement.

## Decision

What was decided and why.

## Consequences

Positive and negative implications.
```

### Planning Documents

```markdown
# Document Title

## Overview

Brief description of the document's purpose.

## Key Sections

### Implementation Details

Specific implementation guidance.

### Success Criteria

How to measure success.

## Next Steps

Clear action items or follow-up work.
```

### GitHub Templates

```markdown
## Section Title

### Subsection

Description and guidance.

**Important Information**:
- Key point 1
- Key point 2

### Checklist Section

- [ ] Item to check
- [ ] Another item
- [ ] Final item
```

## Quality Checklist

Before committing markdown files, verify:

### Content Structure

- [ ] Document starts with H1 title
- [ ] Logical heading hierarchy (no skipped levels)
- [ ] Clear introduction and organization
- [ ] Appropriate use of lists and emphasis

### Technical Compliance

- [ ] All code blocks specify allowed languages
- [ ] Proper nouns are correctly capitalized
- [ ] Line length under 120 characters (except code/tables)
- [ ] Consistent list formatting (dashes for unordered)

### Links and References

- [ ] Long or repeated URLs use reference style
- [ ] All links are functional and relevant
- [ ] File paths use inline code formatting
- [ ] External links open to appropriate resources

### Project Alignment

- [ ] Content supports project goals and philosophy
- [ ] Information is accurate and current
- [ ] Examples are relevant to Factorio mod ecosystem
- [ ] Tone is professional and community-friendly

## Error Prevention

### Common Mistakes to Avoid

#### Line Length Issues

```markdown
<!-- Wrong: Line too long -->
This is an extremely long line that exceeds the 120 character limit and will cause markdownlint errors when committed to the repository.

<!-- Correct: Break long lines -->
This is an extremely long line that exceeds the 120 character limit and will cause markdownlint errors
when committed to the repository.
```

#### Improper Code Blocks

```markdown
<!-- Wrong: No language specified -->
​```
function example() {
    return "Hello";
}
​```

<!-- Correct: Language specified -->
​```lua
function example()
    return "Hello"
end
​```
```

#### Emphasis as Headers

```markdown
<!-- Wrong: Bold text as header -->
**Important Section**

<!-- Correct: Proper heading -->
## Important Section
```

#### Inconsistent List Style

```markdown
<!-- Wrong: Mixed list styles -->
* First item
- Second item
+ Third item

<!-- Correct: Consistent dashes -->
- First item
- Second item
- Third item
```

### Validation Commands

Run these commands to check markdown quality:

```bash
# Check specific file
cmd /c "markdownlint --config .markdownlint.json path/to/file.md"

# Check all markdown files
cmd /c "markdownlint --config .markdownlint.json --dot **/*.md"

# Auto-fix simple issues
cmd /c "markdownlint --config .markdownlint.json --fix --dot **/*.md"
```

## Integration with Development Workflow

### Pre-Commit Checks

- Markdown linting runs automatically in QA workflow
- All files must pass linting before merge
- Use `markdownlint --fix` for simple corrections

### Documentation Standards

- All documentation must follow these guidelines
- Consistency across all project markdown files
- Regular review and updates of guidelines as needed

### Community Contributions

- Contributors should follow these guidelines
- PR template includes markdown quality checklist
- Maintainers help contributors with formatting issues

---

Following these guidelines ensures all markdown content is consistent, professional, and automatically validated,
supporting the project's commitment to quality documentation and community accessibility.
