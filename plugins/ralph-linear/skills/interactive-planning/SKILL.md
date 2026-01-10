---
name: interactive-planning
description: 'Create or update Linear issues with user stories and acceptance criteria. Triggers on: create linear issue, draft issue for, plan issue for, linear ticket for, /interactive-planning.'
---

# Interactive Planning

Create detailed Linear issues that are clear, actionable, and suitable for implementation.

**End goal:** One parent issue (feature design) with sub-issues (user stories with acceptance criteria).

- **Parent issue:** Feature design only - Summary, Out of Scope, Technical Considerations. NO acceptance criteria, NO open questions (all questions resolved during planning).
- **Sub-issues:** User stories with acceptance criteria. Each is independently implementable.

---

## The Job

1. Receive a feature description from the user (or existing issue ID to edit)
2. **If existing issue ID provided:** Fetch issue AND sub-issues first, review what's already planned
3. Ask 3-5 essential clarifying questions (with lettered options) - **skip questions already answered by existing sub-issues**
4. Generate a structured issue with multiple user stories
5. Show draft to user - **they can say what's missing**
6. Create parent issue and sub-issues in Linear via MCP tools
7. Return the issue URLs

**Important:** Review existing work before asking questions. Don't ask about things already defined in sub-issues. Let the user iterate before creating.

**Sub-issue structure:** Each user story becomes a sub-issue under the parent feature issue. This allows tracking progress on individual stories while keeping them organized under one feature.

---

## Step 1: Clarifying Questions

Ask only critical questions where the initial prompt is ambiguous. Focus on:

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

3. What's the scope?
   A) Minimal viable version
   B) Full-featured implementation
   C) Backend/API only
   D) UI only
```

This lets users respond with "1B, 2A, 3A" for quick iteration.

---

## Step 2: Generate Issue

Generate the issue with these sections. **Create as many user stories as needed** - each story should be small enough to implement in one focused session.

### Issue Structure

The feature becomes a **parent issue** with each user story as a **sub-issue**.

#### Parent Issue (Feature Design)

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

**Important:** The parent issue describes WHAT we're building and WHY. It does NOT include acceptance criteria or open questions - all questions should be resolved during planning, and acceptance criteria belong in sub-issues.

#### Sub-Issues (User Stories)

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

Create as many sub-issues as the feature requires (US-001, US-002, US-003, etc.).

### User Story Guidelines

- Each story should be independently implementable
- Break complex features into logical pieces (data layer, UI, edge cases)
- Number stories sequentially (US-001, US-002, etc.)
- Each story has its own acceptance criteria
- Stories should be small enough to complete in one focused session

### Acceptance Criteria Standards

- Must be verifiable (not "works correctly")
- Include edge cases and error states
- For UI changes: "Verify [specific visual/behavior] in simulator"
- For data changes: "Confirm [state before/after]"

**Bad:** "Works correctly"
**Good:** "Button shows confirmation dialog before deleting"

---

## Step 3: Review with User

After generating the draft, always ask:

> "Here's the draft. Did I miss anything? Let me know what to add or change before I create it in Linear."

Wait for user confirmation or feedback before proceeding.

---

## Step 4: Create in Linear

After user approves (or iterates):

### Creating New Issues

1. **Create parent issue** with Summary and Out of Scope in the description
   - Use `mcp__linear-server__create_issue`
   - Title is the feature title
   - Description contains Summary, Out of Scope, Technical Considerations

2. **Create sub-issues for each user story**
   - Use `mcp__linear-server__create_issue` with `parentId` set to the parent issue ID
   - Title: "US-001: [Story Title]"
   - Description: User story description + acceptance criteria

### MCP Tools

- `mcp__linear-server__create_issue` - Create issues (use `parentId` for sub-issues)
- `mcp__linear-server__update_issue` - Edit existing issues
- `mcp__linear-server__get_issue` - Fetch issue details
- `mcp__linear-server__list_teams` - Get team ID if needed
- `mcp__linear-server__list_issue_labels` - Get available labels

Return the parent issue URL and list of sub-issue URLs for confirmation.

---

## Title Writing Standards

- Start with action verbs: Add, Enable, Fix, Implement, Allow
- Be specific about the affected area
- Keep under 80 characters
- Include the user type or feature area when helpful

**Good Examples:**

- "Add visual indicator to distinguish host accounts on connections page"
- "Enable hosts to message event attendees"
- "Fix: Profile image not loading on first visit"

**Bad Examples:**

- "Fix bug" (too vague)
- "Improve profile" (not specific)
- "Update the thing" (meaningless)

---

## Editing Existing Issues

When the user provides an issue ID (e.g., `/interactive-planning PD-45`):

### Step 1: Fetch Issue AND Sub-Issues

1. Fetch the parent issue using `mcp__linear-server__get_issue`
2. **Fetch sub-issues** using `mcp__linear-server__list_issues` with `parentId` filter
3. Review both parent description AND all sub-issue content

### Step 2: Review What's Already Planned

Before asking any questions, analyze existing sub-issues:

- What user stories already exist?
- What acceptance criteria are defined?
- What scope is implied by existing work?
- What gaps or ambiguities remain?

### Step 3: Ask Only Relevant Questions

Skip questions that are already answered by:

- The parent issue description
- Existing sub-issue user stories
- Defined acceptance criteria

Only ask about:

- Gaps in coverage
- Ambiguous requirements
- New scope the user mentioned

### Step 4: Update or Add

- Show current state summary including existing sub-issues
- Make requested changes using `mcp__linear-server__update_issue`
- Add new sub-issues with `parentId` set to the existing issue ID
- Follow the US-XXX naming convention, continuing from the last number

---

## Checklist

Before creating/updating the issue:

- [ ] **If editing:** Fetched existing sub-issues with `list_issues` + `parentId` filter
- [ ] **If editing:** Reviewed existing user stories and acceptance criteria
- [ ] Asked clarifying questions with lettered options - **skipped questions already answered by sub-issues**
- [ ] Incorporated user's answers
- [ ] Created parent issue with Summary, Out of Scope, Technical Considerations
- [ ] Created sub-issues for each user story (US-001, US-002, etc.)
- [ ] Each sub-issue is small enough to implement in one focused session
- [ ] Each sub-issue follows "As a [user], I want [X] so that [Y]" format
- [ ] Each sub-issue has specific, verifiable acceptance criteria
- [ ] Out of scope section defines clear boundaries
- [ ] Showed draft to user for feedback
- [ ] User confirmed or provided additions

---

## Related Resources

- **[Example Issues](./resources/examples.md)** - Example issues showing good patterns for user stories, acceptance criteria, and titles
