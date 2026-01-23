---
description: Generate changelog entry from recent commits
---

# Update Changelog Command

Generate a changelog entry for the current app version from recent commits.

## Procedure

1. **Determine Current Version**
   - Read `app.config.ts` or similar config file
   - Extract the current app version

2. **Confirm Changelog File Exists**
   - Look for changelog file matching current version
   - If missing, stop and notify user

3. **Load and Analyze Prior Changelog Entries**
   - Load current version changelog
   - Load previous versions to avoid duplicates

4. **Review Relevant Commits**
   - Identify commit range from previous to current version
   - Filter using strict inclusion/exclusion criteria

## Inclusion Criteria

### 1. New User-Facing Features
- New screens, UI components, settings, interactions
- New app functionality
- Updates that alter user workflows

### 2. Bug Fixes That Impact the User
- Crash fixes
- Visual/UI glitches resolved
- Fixed navigation, gestures, scroll issues
- Authentication or session-related fixes

### 3. Significant User-Visible Performance Improvements
- Only include if substantial AND directly noticeable to users

## Exclusion Criteria

These changes must **never** be included:
- Code refactors or reorganizations
- Dependency upgrades (unless user-visible effects)
- Developer tooling updates
- Configuration changes
- Comment or style fixes
- CI/CD or build pipeline changes
- Vague phrasing like "performance improvements", "minor enhancements"

## Deduplication Rules

- Do not repeat items from earlier version changelogs
- Omit follow-up commits unless they introduce new user-facing behavior

## Final Step

If changes were added to changelog, run:
```bash
npm run generate-changelog-data
```

Then confirm the changelog has been updated and script executed.
