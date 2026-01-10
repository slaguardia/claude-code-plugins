---
description: Update all project documentation to reflect current codebase state
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

Update all project documentation to reflect the current state of the codebase.

## Instructions

Perform a comprehensive review and update of all documentation files:

### 1. Analyze Current State

First, gather information about the current codebase:

- Read `package.json` to get current dependencies and scripts
- Read configuration files (app.json, tsconfig.json, etc.)
- Scan source directories for current structure
- Check for any new directories or significant files

### 2. Update CLAUDE.md

Update the root `CLAUDE.md` file with:
- Current tech stack summary
- Current project structure
- Any new patterns or conventions discovered
- Updated commands section if scripts changed

### 3. Update Technical Documentation

Update technical docs (if they exist) with:
- Current dependencies (check for added/removed/version changes)
- Update any "Removed Dependencies" sections
- Add any new dependencies to appropriate categories
- Verify peer dependency information is still accurate

### 4. Update Architecture Documentation

Update architecture docs (if they exist) with:
- Current directory structure
- Current route/page map (check for new/removed routes)
- Any new data types or changes to existing types
- New patterns or architectural changes
- Updated component patterns if any

### 5. Update CHANGELOG

Add a new entry to changelog (if it exists) under `[Unreleased]` section documenting:
- Any dependencies added or removed since last update
- Any files added or removed
- Any configuration changes
- Any architectural changes

If there are no changes since the last documented update, note that the docs were reviewed and confirmed current.

### 6. Summary

After updating, provide a summary of what changed in the documentation.

## Output Format

For each file updated, briefly describe what was changed. If a file required no updates, say so.
