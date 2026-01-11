---
name: team-planning
description: 'Two-agent adversarial planning loop. Planning Agent creates user stories, Research Agent validates with web research. Loop until comprehensive, then save to local JSON task files. Triggers on: /team-planning, adversarial planning, research planning.'
---

# Team Planning - Adversarial Planning Loop (Local Tasks)

Two-agent system where Planning Agent and Research Agent alternate until a comprehensive, research-validated plan is ready.

**End goal:** Local JSON task files containing a feature definition and user stories with acceptance criteria, validated by web research.

## How It Works

```
+-------------------------------------------------------------+
|                    ITERATION N                               |
+-------------------------------------------------------------+
|  1. PLANNING AGENT                                           |
|     - Takes input + feedback                                 |
|     - Creates/refines user stories                           |
|     - Outputs structured plan                                |
|                                                              |
|  2. RESEARCH AGENT                                           |
|     - Reviews plan critically                                |
|     - Conducts 3+ web searches                               |
|     - Identifies gaps and best practices                     |
|     - Issues DONE or FEEDBACK                                |
|                                                              |
|  Loop until DONE, then save to .tasks/ directory             |
+-------------------------------------------------------------+
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

### From Markdown File

```bash
/team-planning --file feature-spec.md
```

### With Options

```bash
/team-planning --max-iterations 5 "add dark mode toggle"
/team-planning --file spec.md --tasks-dir ./my-tasks --verbose
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--max-iterations` | 7 | Maximum planning/research cycles |
| `--file PATH` | - | Import from markdown file |
| `--tasks-dir DIR` | .tasks | Output directory for task files |
| `--verbose` | false | Show full agent outputs |

## Output Structure

### Directory Layout

```
.tasks/
  FEAT-20240115_123456-abc1/
    feature.json      # Main feature definition
    index.json        # Quick reference index
    stories/
      US-001.json     # First user story
      US-002.json     # Second user story
      ...
```

### feature.json

```json
{
  "id": "FEAT-20240115_123456-abc1",
  "title": "Feature: Allow hosts to message attendees",
  "summary": "Enable personalized communication...",
  "status": "planning",
  "createdAt": "2024-01-15T12:34:56Z",
  "outOfScope": ["Group messaging", "Rich media"],
  "technicalConsiderations": ["Rate limiting", "Notifications"],
  "researchSummary": "Validated through 3 iterations...",
  "storiesCount": 4
}
```

### stories/US-001.json

```json
{
  "id": "US-001",
  "featureId": "FEAT-20240115_123456-abc1",
  "title": "View attendee list for messaging",
  "userStory": "As an event host, I want to see...",
  "acceptanceCriteria": [
    "Given I am viewing my event...",
    "The list shows attendee name..."
  ],
  "dependencies": [],
  "status": "todo",
  "createdAt": "2024-01-15T12:34:56Z",
  "completedAt": null,
  "iteration": null
}
```

## Execution Flow

This skill runs the `scripts/team-loop.sh` bash script which:

1. Initializes state files (`.team-state.json`, `planning-context.json`)
2. Alternates between Planning Agent and Research Agent
3. Each agent runs in a fresh Claude instance
4. State is preserved in JSON files between iterations
5. When Research Agent outputs `DONE`, saves tasks to `.tasks/` directory
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

## Example Session

```
$ /team-planning "hosts need to message event attendees"

=======================================================
  Team Planning Loop (Local Tasks)
  Max iterations: 7
  Input: "hosts need to message event attendees"
  Output: .tasks/
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

Saving tasks to local JSON files...
  Created: stories/US-001.json
  Created: stories/US-002.json
  Created: stories/US-003.json

Tasks saved to: .tasks/FEAT-20240115_123456-abc1
  feature.json - Main feature definition
  stories/     - Individual user story files
  index.json   - Quick reference index

To start implementation:
  /ralph FEAT-20240115_123456-abc1
```

## Checklist

Before running:
- [ ] Have a clear feature description or markdown file
- [ ] `jq` installed for JSON parsing

After completion:
- [ ] Review created task files in `.tasks/` directory
- [ ] Check research summary in feature.json
- [ ] Adjust priorities as needed
- [ ] Start implementation with `/ralph FEATURE_ID`
