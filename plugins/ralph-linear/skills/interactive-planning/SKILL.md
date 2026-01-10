---
name: interactive-planning
description: 'Create or update Linear issues with user stories and acceptance criteria. Triggers on: create linear issue, draft issue for, plan issue for, linear ticket for, /interactive-planning.'
---

# Interactive Planning

Create detailed Linear issues that are clear, actionable, and suitable for implementation.

**End goal:** One parent issue (feature design) with sub-issues (user stories with acceptance criteria).

- **Parent issue:** Feature design only - Summary, Out of Scope, Technical Considerations. NO acceptance criteria, NO open questions.
- **Sub-issues:** User stories with acceptance criteria. Each is independently implementable.

## The Job

1. Receive a feature description from the user (or existing issue ID to edit)
2. **If existing issue ID provided:** Fetch issue AND sub-issues first, review what's already planned
3. Ask 3-5 essential clarifying questions (with lettered options)
4. Generate a structured issue with multiple user stories
5. Show draft to user - **they can say what's missing**
6. Create parent issue and sub-issues in Linear via MCP tools
7. Return the issue URLs

## Step 1: Clarifying Questions

Ask only critical questions where the initial prompt is ambiguous:

- **Problem/Goal:** What problem does this solve?
- **Core Functionality:** What are the key actions?
- **User Type:** Who is this for?
- **Scope/Boundaries:** What should it NOT do?
- **Success Criteria:** How do we know it's done?

### Format Questions Like This:

```
1. What problem does this solve?
   A) Users can't find something they need
   B) Missing functionality they've requested
   C) Current behavior is confusing/broken
   D) Other: [please specify]

2. Who is the primary user?
   A) Event hosts
   B) Event attendees
   C) New users (onboarding)
   D) All users
```

This lets users respond with "1B, 2A, 3A" for quick iteration.

## Step 2: Generate Issue

### Parent Issue (Feature Design)

**Title:** [Feature title - action verb + specific description]

**Description:** Feature design only. NO acceptance criteria, NO open questions.

```markdown
## Summary
[1-2 sentence description of the feature and problem it solves]

## Out of Scope
- What this feature will NOT include
- Explicit boundaries to prevent scope creep

## Technical Considerations (optional)
- Affected components/screens
- Dependencies or integration points
```

### Sub-Issues (User Stories)

Each user story becomes its own sub-issue:

**Title:** US-001: [Story Title]

**Description:**
```markdown
As a [user], I want [feature] so that [benefit].

## Acceptance Criteria
- [ ] Specific verifiable criterion
- [ ] Another criterion
- [ ] [UI changes] Verify visual behavior in simulator
```

### User Story Guidelines

- Each story should be independently implementable
- Break complex features into logical pieces
- Number stories sequentially (US-001, US-002, etc.)
- Stories should be small enough to complete in one focused session

### Acceptance Criteria Standards

- Must be verifiable (not "works correctly")
- Include edge cases and error states
- For UI changes: "Verify [specific visual/behavior] in simulator"
- For data changes: "Confirm [state before/after]"

## Step 3: Review with User

After generating the draft, always ask:

> "Here's the draft. Did I miss anything? Let me know what to add or change before I create it in Linear."

## Step 4: Create in Linear

### MCP Tools

- `mcp__linear-server__create_issue` - Create issues (use `parentId` for sub-issues)
- `mcp__linear-server__update_issue` - Edit existing issues
- `mcp__linear-server__get_issue` - Fetch issue details
- `mcp__linear-server__list_teams` - Get team ID if needed
- `mcp__linear-server__list_issue_labels` - Get available labels

## Title Writing Standards

- Start with action verbs: Add, Enable, Fix, Implement, Allow
- Be specific about the affected area
- Keep under 80 characters

**Good Examples:**
- "Add visual indicator to distinguish host accounts on connections page"
- "Enable hosts to message event attendees"

**Bad Examples:**
- "Fix bug" (too vague)
- "Improve profile" (not specific)

## Checklist

Before creating/updating the issue:

- [ ] Asked clarifying questions with lettered options
- [ ] Incorporated user's answers
- [ ] Created parent issue with Summary, Out of Scope, Technical Considerations
- [ ] Created sub-issues for each user story (US-001, US-002, etc.)
- [ ] Each sub-issue is small enough to implement in one focused session
- [ ] Each sub-issue follows "As a [user], I want [X] so that [Y]" format
- [ ] Each sub-issue has specific, verifiable acceptance criteria
- [ ] Showed draft to user for feedback
- [ ] User confirmed or provided additions
