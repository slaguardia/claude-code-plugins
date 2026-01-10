---
name: headless-planning
description: 'Async iterative planning via Linear issue descriptions. Creates issues with embedded questions, user answers inline in Linear, Claude continues until ready to create sub-issues. Triggers on: /headless-planning, async planning, headless issue.'
---

# Headless Iterative Planning

Asynchronous planning workflow that uses Linear issue descriptions as the communication medium. Questions and answers happen directly in the issue, not in chat.

**End goal:** One parent issue (feature design) with sub-issues (user stories with acceptance criteria).

## The Job

1. User provides a feature idea (or existing issue ID to continue)
2. **If existing issue ID provided:** Fetch issue AND sub-issues first, review what's already planned
3. Claude creates/updates a Linear issue with embedded questions
4. User answers questions by editing the issue description in Linear
5. User returns and asks Claude to continue (`/headless-planning PD-XX`)
6. Claude reads answers AND existing sub-issues, asks follow-up questions OR creates sub-issues
7. Repeat until planning is complete

**Key difference from interactive-planning:** All Q&A happens in the Linear issue description, not in chat.

## Workflow States

### State 1: Questions Pending

```markdown
## Summary
[Initial understanding of the feature]

---

## Planning Questions

Please answer these questions inline (replace the placeholders):

### 1. What problem does this solve?
**Your answer:** [ANSWER HERE]

### 2. Who is the primary user?
**Your answer:** [ANSWER HERE]

### 3. What's the scope?
**Your answer:** [ANSWER HERE]

---

**Status:** Waiting for answers. Once complete, ask Claude to continue: `/headless-planning PD-XX`
```

### State 2: Ready for Sub-Issues

```markdown
## Summary
[Refined summary based on answers]

## Out of Scope
- [Item 1]
- [Item 2]

## Technical Considerations
- [Item 1]

---

**Status:** Planning complete. Sub-issues created below.
```

## Step 1: Initial Issue Creation

When user provides a feature idea:

1. Create parent issue with `mcp__linear-server__create_issue`
2. Title: Feature title (action verb + specific description)
3. Description contains:
   - Initial summary
   - 3-5 clarifying questions with answer placeholders
   - Instructions for user
   - Status indicator

### Question Format

```markdown
### 1. [Question]
**Your answer:** [ANSWER HERE]
```

## Step 2: Continue Planning

When user provides an issue ID:

1. Fetch parent issue with `mcp__linear-server__get_issue`
2. Fetch sub-issues with `mcp__linear-server__list_issues` using `parentId` filter
3. Parse answers from description
4. Create sub-issues if ready, or ask follow-up questions

## Step 3: Create Sub-Issues

When all questions are answered:

1. Update parent issue with final feature design
2. Remove questions section
3. Create sub-issues with `parentId`

### Sub-Issue Format

**Title:** US-001: [Story Title]

**Description:**
```markdown
As a [user], I want [feature] so that [benefit].

## Acceptance Criteria
- [ ] Specific verifiable criterion
- [ ] Another criterion
```

## MCP Tools

- `mcp__linear-server__create_issue` - Create parent and sub-issues
- `mcp__linear-server__update_issue` - Update issue description
- `mcp__linear-server__get_issue` - Read current issue state
- `mcp__linear-server__list_issues` - Fetch sub-issues with parentId filter
- `mcp__linear-server__list_teams` - Get team ID if needed

**Important:** Only work with issue descriptions. Never use comment tools.

## Checklist

Before creating sub-issues:

- [ ] Fetched existing sub-issues with `list_issues` + `parentId` filter
- [ ] Reviewed existing user stories before asking questions
- [ ] All questions have been answered
- [ ] Skipped questions already answered by existing sub-issues
- [ ] Parent issue updated with final Summary, Out of Scope
- [ ] Sub-issues created with `parentId` linking to parent
- [ ] Each sub-issue has acceptance criteria
- [ ] Status updated to "Planning complete"
