# ralph-linear-team

Two-agent adversarial planning loop for comprehensive feature planning with web research.

## Overview

This plugin implements a "ralph loop" that alternates between two AI agents:

1. **Planning Agent** - Creates and refines user stories from feature descriptions
2. **Research Agent** - Validates plans with web research, identifies gaps

The loop continues until the Research Agent is satisfied, then automatically creates Linear issues.

## Why Two Agents?

Single-pass planning often misses edge cases, best practices, and real-world considerations. By having a dedicated Research Agent that:

- Conducts web searches for industry standards
- Looks for edge cases and pitfalls
- Compares against similar implementations
- Checks for security and accessibility concerns

...you get plans that are more comprehensive and battle-tested.

## Installation

1. Clone this repository into your Claude Code plugins directory
2. Ensure Linear MCP server is configured
3. Install `jq` for JSON parsing: `brew install jq` (macOS) or `apt install jq` (Linux)

## Usage

### Basic Usage

```bash
# From a feature description
/team-planning "hosts need to message event attendees"

# From an existing Linear issue
/team-planning --issue PD-123
```

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `--max-iterations N` | 7 | Maximum planning/research cycles |
| `--issue ID` | - | Use existing Linear issue as input |
| `--team NAME` | auto | Linear team for issue creation |
| `--verbose` | false | Show full agent outputs |

### Examples

```bash
# Quick planning with fewer iterations
/team-planning --max-iterations 3 "add dark mode toggle"

# Verbose mode to see agent outputs
/team-planning --verbose "implement user notifications"

# Specify team explicitly
/team-planning --team "Product" "add payment processing"
```

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│                    ITERATION N                          │
├─────────────────────────────────────────────────────────┤
│  1. PLANNING AGENT                                      │
│     Input: Feature description + Research feedback      │
│     Output: Structured user stories (JSON)              │
│                                                         │
│  2. RESEARCH AGENT                                      │
│     Input: Current plan                                 │
│     Actions:                                            │
│       - 3+ web searches (best practices, edge cases)    │
│       - Gap analysis                                    │
│     Output: DONE signal or FEEDBACK with issues         │
│                                                         │
│  Loop until DONE, then create Linear issues             │
└─────────────────────────────────────────────────────────┘
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

### Linear Issues Created

**Parent Issue:**
- Summary of the feature
- Out of Scope items
- Technical Considerations
- Research Summary (findings, sources)

**Sub-Issues (User Stories):**
- Title: `US-001: [Story Title]`
- User story in "As a... I want... so that..." format
- Acceptance criteria (Given/When/Then format)

### Local Files

After completion:
- `planning-result-YYYYMMDD_HHMMSS.json` - Final plan with all context

## Architecture

```
plugins/ralph-linear-team/
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
- Linear MCP server configured
- `jq` for JSON parsing

## Comparison with ralph-linear

| Feature | ralph-linear | ralph-linear-team |
|---------|--------------|-------------------|
| Purpose | Implement stories | Plan features |
| Agents | Single (implementation) | Two (planning + research) |
| Web Research | No | Yes (required) |
| Output | Code changes | Linear issues |
| Interaction | Can prompt for blockers | Fully headless |

## Tips

- **Start small**: Use `--max-iterations 3` for simple features
- **Be specific**: More detailed input = better initial plan
- **Check verbose**: Use `--verbose` to understand agent reasoning
- **Review output**: Always review created issues before implementation

## License

MIT
