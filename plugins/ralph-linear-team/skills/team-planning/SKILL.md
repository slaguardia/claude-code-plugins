---
name: team-planning
description: 'Two-agent adversarial planning loop. Planning Agent creates user stories, Research Agent validates with web research. Loop until comprehensive, then create Linear issues. Triggers on: /team-planning, adversarial planning, research planning.'
---

# Team Planning - Adversarial Planning Loop

Two-agent system where Planning Agent and Research Agent alternate until a comprehensive, research-validated plan is ready.

**End goal:** One parent issue (feature design) with sub-issues (user stories with acceptance criteria), validated by web research.

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│                    ITERATION N                          │
├─────────────────────────────────────────────────────────┤
│  1. PLANNING AGENT                                      │
│     - Takes input + feedback                            │
│     - Creates/refines user stories                      │
│     - Outputs structured plan                           │
│                                                         │
│  2. RESEARCH AGENT                                      │
│     - Reviews plan critically                           │
│     - Conducts 3+ web searches                          │
│     - Identifies gaps and best practices                │
│     - Issues DONE or FEEDBACK                           │
│                                                         │
│  Loop until DONE, then create Linear issues             │
└─────────────────────────────────────────────────────────┘
```

## The Agents

### Planning Agent
- Creates structured user stories from feature descriptions
- Incorporates feedback from Research Agent
- Outputs plan in JSON format with stories and acceptance criteria

### Research Agent
- Reviews plan for completeness and quality
- Conducts web searches for best practices, edge cases, similar implementations
- Identifies gaps: missing stories, edge cases, security/accessibility concerns
- Issues `DONE` when satisfied or `FEEDBACK` with specific issues

## Usage

### From Feature Description

```bash
/team-planning "hosts need to message event attendees"
```

### From Existing Linear Issue

```bash
/team-planning --issue PD-123
```

### With Options

```bash
/team-planning --max-iterations 5 "add dark mode toggle"
/team-planning --issue PD-123 --team "Product" --verbose
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--max-iterations` | 7 | Maximum planning/research cycles |
| `--issue ID` | - | Use existing Linear issue as input |
| `--team NAME` | auto | Linear team for issue creation |
| `--verbose` | false | Show full agent outputs |

## What Gets Created

### Parent Issue

```markdown
## Summary
[Feature summary from plan]

## Out of Scope
- [What this won't include]

## Technical Considerations
- [Dependencies and notes]

## Research Summary
Validated through N iterations of adversarial planning.

### Best Practices Incorporated
- [Practice 1]
- [Practice 2]

### Sources Consulted
- [Source 1](URL)
- [Source 2](URL)
```

### Sub-Issues (User Stories)

**Title:** US-001: [Story Title]

```markdown
As a [user], I want [feature] so that [benefit].

## Acceptance Criteria
- [ ] Given [context], when [action], then [result]
- [ ] The system should [behavior]
- [ ] Error: When [condition], show [message]
```

## Execution Flow

This skill runs the `scripts/team-loop.sh` bash script which:

1. Initializes state files (`.team-state.json`, `planning-context.json`)
2. Alternates between Planning Agent and Research Agent
3. Each agent runs in a fresh Claude instance
4. State is preserved in JSON files between iterations
5. When Research Agent outputs `DONE`, creates Linear issues
6. Cleans up and saves final plan to `planning-result-*.json`

## Signals

| Signal | Agent | Meaning |
|--------|-------|---------|
| `<plan>JSON</plan>` | Planning | Structured plan output |
| `<signal>DONE</signal>` | Research | Plan approved |
| `<feedback>JSON</feedback>` | Research | Gaps found, loop continues |

## State Files

### `.team-state.json`
Orchestration metadata: iteration count, status, timestamps

### `planning-context.json`
Accumulated state: original input, current plan, research findings, feedback history

## MCP Tools Used

- `mcp__linear-server__get_issue` - Fetch input issue (if --issue provided)
- `mcp__linear-server__list_teams` - Find team for issue creation
- `mcp__linear-server__create_issue` - Create parent and sub-issues
- `WebSearch` - Research Agent web searches

## Example Session

```
$ /team-planning "hosts need to message event attendees"

=======================================================
  Team Planning Loop
  Max iterations: 7
  Input: "hosts need to message event attendees"
=======================================================

-------------------------------------------------------
  Iteration 1 / 7
-------------------------------------------------------

  [Planning Agent] Creating/refining user stories...
  [Planning Agent] Plan updated successfully

  [Research Agent] Researching and validating plan...
  [Research Agent] Found 3 gap(s) - sending back to Planning Agent

Waiting 2s before next iteration...

-------------------------------------------------------
  Iteration 2 / 7
-------------------------------------------------------

  [Planning Agent] Creating/refining user stories...
  [Planning Agent] Plan updated successfully

  [Research Agent] Researching and validating plan...
  [Research Agent] Plan approved! No gaps found.

=======================================================
  PLAN APPROVED!
  Completed in 2 iteration(s)
=======================================================

Creating Linear issues from final plan...
Created: PD-456 (parent)
Created: PD-457 (US-001: View attendee list)
Created: PD-458 (US-002: Compose and send message)
Created: PD-459 (US-003: Message delivery status)
```

## Checklist

Before running:
- [ ] Have a clear feature description or Linear issue ID
- [ ] Linear MCP server connected
- [ ] `jq` installed for JSON parsing

After completion:
- [ ] Review created Linear issues
- [ ] Check research summary in parent issue
- [ ] Adjust priorities/labels as needed
