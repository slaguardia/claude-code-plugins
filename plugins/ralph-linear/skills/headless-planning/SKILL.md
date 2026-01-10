---
name: headless-planning
description: 'Async iterative planning via Linear issue descriptions. Creates issues with embedded questions, user answers inline in Linear, Claude continues until ready to create sub-issues. Triggers on: /headless-planning, async planning, headless issue.'
---

# Headless Iterative Planning

Asynchronous planning workflow that uses Linear issue descriptions as the communication medium. Questions and answers happen directly in the issue, not in chat.

**End goal:** One parent issue (feature design) with sub-issues (user stories with acceptance criteria).

- **Parent issue:** Feature design only - Summary, Out of Scope, Technical Considerations. NO acceptance criteria, NO open questions (all questions resolved during planning).
- **Sub-issues:** User stories with acceptance criteria. Each is independently implementable.

---

## The Job

1. User provides a feature idea (or existing issue ID to continue)
2. **If existing issue ID provided:** Fetch issue AND sub-issues first, review what's already planned
3. Claude creates/updates a Linear issue with embedded questions - **skip questions already answered by existing sub-issues**
4. User answers questions by editing the issue description in Linear
5. User returns and asks Claude to continue (`/headless-planning PD-XX`)
6. Claude reads answers AND existing sub-issues, asks follow-up questions OR creates sub-issues
7. Repeat until planning is complete

**Key difference from interactive-planning:** All Q&A happens in the Linear issue description, not in chat. This enables async collaboration.

**Important:** Always review existing sub-issues before asking questions. Don't ask about things already defined in sub-issues.

---

## Workflow States

The issue description indicates the current state:

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

### State 2: Processing / More Questions

After reading answers, Claude may ask follow-up questions in the same format.

### State 3: Ready for Sub-Issues (Feature Design Complete)

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

**Note:** Parent issue contains feature design only - NO acceptance criteria, NO open questions. All questions resolved during planning. Acceptance criteria belong in sub-issues.

---

## Step 1: Initial Issue Creation

When user provides a feature idea:

1. Create parent issue with `mcp__linear-server__create_issue`
2. Title: Feature title (action verb + specific description)
3. Description contains:
   - Initial summary based on user's description
   - 3-5 clarifying questions with answer placeholders
   - Instructions for user to answer inline
   - Status indicator

### Question Format

Questions should be specific and contextual to the feature:

```markdown
### 1. [Question]

**Your answer:** [ANSWER HERE]
```

Focus questions on:

- **Problem/Goal:** What problem does this solve?
- **Core Functionality:** What are the key actions?
- **User Type:** Who is this for?
- **Scope/Boundaries:** What should it NOT do?
- **Success Criteria:** How will we know it's working?

---

## Step 2: Continue Planning

When user provides an issue ID:

### Fetch Issue AND Sub-Issues

1. Fetch parent issue with `mcp__linear-server__get_issue`
2. **Fetch existing sub-issues** with `mcp__linear-server__list_issues` using `parentId` filter
3. Review both parent description AND all sub-issue content

### Review What's Already Planned

Before asking any questions, analyze existing sub-issues:

- What user stories already exist?
- What acceptance criteria are defined?
- What scope is implied by existing work?
- What gaps or ambiguities remain?

### Parse Answers from Description

Look for content after "**Your answer:**" in each question section. If still "[ANSWER HERE]" or empty, that question wasn't answered.

### Determine Next Action

Consider BOTH description answers AND existing sub-issues:

1. If sub-issues already cover the scope well -> summarize what exists, ask if additions needed
2. If answers are incomplete AND no sub-issues exist -> update with follow-up questions
3. If answers are complete OR sub-issues provide enough context -> proceed to create/update sub-issues

### Skip Redundant Questions

Don't ask about things already defined in:

- Existing sub-issue user stories
- Defined acceptance criteria
- The parent issue description

Only ask about gaps, ambiguities, or new scope the user mentioned.

---

## Step 3: Create Sub-Issues

When all questions are answered and requirements are clear:

1. Update parent issue description with final feature design:
   - Summary
   - Out of Scope
   - Technical Considerations
   - **NO acceptance criteria** (those go in sub-issues)
   - **NO open questions** (all resolved during planning)
2. Remove the questions section
3. Add status: "Planning complete"
4. Create sub-issues for each user story using `parentId`

### Sub-Issue Format

**Title:** US-001: [Story Title]

**Description:**

```markdown
As a [user], I want [feature] so that [benefit].

## Acceptance Criteria

- [ ] Specific verifiable criterion
- [ ] Another criterion
```

---

## MCP Tools

- `mcp__linear-server__create_issue` - Create parent and sub-issues (use `parentId` for sub-issues)
- `mcp__linear-server__update_issue` - Update issue description with questions/answers
- `mcp__linear-server__get_issue` - Read current issue state
- `mcp__linear-server__list_teams` - Get team ID if needed

**Important:** Only work with issue descriptions. Never use comment tools.

---

## Example Flow

### User starts planning:

```
User: /headless-planning hosts need to message their attendees
```

### Claude creates issue:

```
Created: PD-123 - "Allow hosts to message event attendees"

I've created a planning issue with questions. Please answer them directly in Linear, then come back and run:

/headless-planning PD-123
```

### Issue description (in Linear):

```markdown
## Summary

Event hosts need a way to communicate with their event attendees.

---

## Planning Questions

Please answer these questions inline (replace the placeholders):

### 1. What's the primary goal of messaging?

A) Send event updates/announcements
B) Enable two-way conversation
C) Send reminders
D) Other

**Your answer:** [ANSWER HERE]

### 2. Who should hosts be able to message?

A) All RSVPs (confirmed + maybe)
B) Only confirmed attendees
C) Anyone who viewed the event
D) Other

**Your answer:** [ANSWER HERE]

### 3. What's the scope for v1?

A) Basic one-way messaging
B) Full chat with replies
C) Just push notifications
D) Other

**Your answer:** [ANSWER HERE]

---

**Status:** Waiting for answers. Once complete, ask Claude to continue: `/headless-planning PD-123`
```

### User answers in Linear:

```markdown
### 1. What's the primary goal of messaging?

...
**Your answer:** A - just announcements for now

### 2. Who should hosts be able to message?

...
**Your answer:** B - only confirmed attendees

### 3. What's the scope for v1?

...
**Your answer:** A - keep it simple, one-way only
```

### User continues:

```
User: /headless-planning PD-123
```

### Claude reads answers and creates sub-issues:

```
I've read your answers. Creating user story sub-issues now...

Created:
- PD-124: US-001: Add announcement entry point
- PD-125: US-002: Compose and send announcement
- PD-126: US-003: Deliver announcement to attendees

Parent issue PD-123 updated with final summary.
```

---

## Checklist

Before creating sub-issues:

- [ ] **Fetched existing sub-issues** with `list_issues` + `parentId` filter
- [ ] **Reviewed existing user stories** and acceptance criteria before asking questions
- [ ] All questions have been answered (no "[ANSWER HERE]" remaining) - OR sub-issues already provide context
- [ ] Skipped questions already answered by existing sub-issues
- [ ] Answers are clear enough to define user stories
- [ ] Asked follow-up questions if answers were ambiguous
- [ ] Parent issue updated with final Summary, Out of Scope
- [ ] Sub-issues created with `parentId` linking to parent
- [ ] Each sub-issue has acceptance criteria
- [ ] Status updated to "Planning complete"

---

## Related Resources

- **[Example Issues](./resources/examples.md)** - Example issue descriptions showing the Q&A format
