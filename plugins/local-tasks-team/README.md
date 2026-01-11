# local-tasks-team

Two-agent adversarial planning loop for comprehensive feature planning with web research. Saves tasks to local JSON files.

## Overview

This plugin implements a "team planning loop" that alternates between two AI agents:

1. **Planning Agent** - Creates and refines user stories from feature descriptions
2. **Research Agent** - Validates plans with web research, identifies gaps

The loop continues until the Research Agent is satisfied, then automatically saves tasks to local JSON files.

## Why Two Agents?

Single-pass planning often misses edge cases, best practices, and real-world considerations. By having a dedicated Research Agent that:

- Conducts web searches for industry standards
- Looks for edge cases and pitfalls
- Compares against similar implementations
- Checks for security and accessibility concerns

...you get plans that are more comprehensive and battle-tested.

## Installation

1. Clone this repository into your Claude Code plugins directory
2. Install `jq` for JSON parsing: `brew install jq` (macOS) or `apt install jq` (Linux)

## Usage

### Basic Usage

```bash
# From a feature description
/team-planning "hosts need to message event attendees"

# From a markdown file
/team-planning --file feature-spec.md
```

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `--max-iterations N` | 7 | Maximum planning/research cycles |
| `--file PATH` | - | Import from markdown file |
| `--tasks-dir DIR` | .tasks | Output directory for task files |
| `--verbose` | false | Show full agent outputs |

### Examples

```bash
# Quick planning with fewer iterations
/team-planning --max-iterations 3 "add dark mode toggle"

# Verbose mode to see agent outputs
/team-planning --verbose "implement user notifications"

# Custom output directory
/team-planning --tasks-dir ./my-tasks "add payment processing"
```

## How It Works

```
+-------------------------------------------------------------+
|                    ITERATION N                               |
+-------------------------------------------------------------+
|  1. PLANNING AGENT                                           |
|     Input: Feature description + Research feedback           |
|     Output: Structured user stories (JSON)                   |
|                                                              |
|  2. RESEARCH AGENT                                           |
|     Input: Current plan                                      |
|     Actions:                                                 |
|       - 3+ web searches (best practices, edge cases)         |
|       - Gap analysis                                         |
|     Output: DONE signal or FEEDBACK with issues              |
|                                                              |
|  Loop until DONE, then save to .tasks/ directory             |
+-------------------------------------------------------------+
```

### Research Agent Searches

The Research Agent conducts at least 3 web searches per iteration:

1. **Best Practices**: "[feature] best practices 2026"
2. **Edge Cases**: "[feature] edge cases pitfalls"
3. **Implementations**: "[feature] implementation examples"
4. **Security/A11y** (if relevant): "[feature] security considerations"

### Gap Types Identified

| Type | Description |
|------|-------------|
| `missing_story` | User story that should exist |
| `edge_case` | Scenario not covered |
| `best_practice` | Industry standard not followed |
| `security` | Security concern not addressed |
| `accessibility` | A11y requirement missing |
| `vague_criteria` | Acceptance criteria too vague |

## Output

### Directory Structure

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
  "technicalConsiderations": ["Rate limiting"],
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

### Local Files

After completion:
- `planning-result-YYYYMMDD_HHMMSS.json` - Final plan with all context

## Architecture

```
plugins/local-tasks-team/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── scripts/
│   └── team-loop.sh          # Main orchestration script
├── prompts/
│   ├── planning-agent.md     # Planning Agent prompt
│   └── research-agent.md     # Research Agent prompt
├── skills/
│   └── team-planning/
│       └── SKILL.md          # Skill definition
└── README.md
```

### State Management

The loop maintains state in JSON files:

- `.team-state.json` - Iteration count, status, timestamps
- `planning-context.json` - Current plan, research findings, feedback history

This allows the loop to run headless with fresh Claude instances per agent call.

## Requirements

- Claude Code CLI
- `jq` for JSON parsing

## Comparison with local-tasks

| Feature | local-tasks | local-tasks-team |
|---------|-------------|------------------|
| Purpose | Implement stories | Plan features |
| Agents | Single (implementation) | Two (planning + research) |
| Web Research | No | Yes (required) |
| Output | Code changes | Task JSON files |
| Interaction | Can prompt for blockers | Fully headless |

## Tips

- **Start small**: Use `--max-iterations 3` for simple features
- **Be specific**: More detailed input = better initial plan
- **Check verbose**: Use `--verbose` to understand agent reasoning
- **Review output**: Always review created task files before implementation

## Next Steps

After planning completes:

```bash
# Start implementation with the local-tasks plugin
/ralph FEAT-20240115_123456-abc1
```

## License

MIT
