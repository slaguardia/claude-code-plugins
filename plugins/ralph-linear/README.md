# Ralph Linear Plugin

Autonomous AI agent loop for Claude Code. Implements user stories from Linear issues one at a time, with fresh context per iteration.

Based on [Geoffrey Huntley's Ralph methodology](https://github.com/snarktank/ralph).

---

## How It Works

```
+-------------------------------------------------------------+
|                      ralph.sh (loop)                         |
|  +-----------------------------------------------------+    |
|  |  Iteration 1: Fresh Claude instance                  |    |
|  |  -> Read Linear issues                               |    |
|  |  -> Pick next incomplete story                       |    |
|  |  -> Implement, test, commit                          |    |
|  |  -> Mark complete in Linear                          |    |
|  |  -> Append learnings to progress.txt                 |    |
|  |  -> Exit                                             |    |
|  +-----------------------------------------------------+    |
|                           |                                  |
|  +-----------------------------------------------------+    |
|  |  Iteration 2: Fresh Claude instance                  |    |
|  |  -> (same flow, picks next story)                    |    |
|  +-----------------------------------------------------+    |
|                           |                                  |
|                         ...                                  |
|                           |                                  |
|              <promise>COMPLETE</promise>                     |
|                      (all done)                              |
+-------------------------------------------------------------+
```

**Key principle:** Each iteration gets fresh context. Memory persists through:

- Linear issue state (source of truth)
- Git commits (implementation history)
- `progress.txt` (learnings and patterns)

---

## Quick Start

### 1. Install the Plugin

Add to your project's `.claude/settings.json`:

```json
{
  "plugins": {
    "marketplaces": {
      "your-marketplace": {
        "url": "https://github.com/your-username/plugins",
        "autoInstall": true
      }
    }
  }
}
```

### 2. Create Linear Issues

Structure your work as a parent issue with sub-issues (user stories):

- **Parent:** "Add feature X" (PD-123)
  - **Sub-issue:** US-001 - First story (PD-124)
  - **Sub-issue:** US-002 - Second story (PD-125)
  - **Sub-issue:** US-003 - Third story (PD-126)

### 3. Run Ralph

```bash
# Single iteration (in Claude Code chat)
/ralph PD-123

# Autonomous loop (runs until complete)
./ralph.sh PD-123
```

---

## Usage Modes

### Mode 1: Single Iteration

Run one story at a time with oversight:

```
/ralph PD-123
```

Review the implementation, then run again for the next story.

### Mode 2: Autonomous Loop

Let Ralph run unattended:

```bash
./scripts/ralph.sh PD-123 --max-iterations 20
```

Ralph will:

- Spawn fresh Claude Code instances
- Implement stories one by one
- Stop when all complete or max iterations reached

### Mode 3: Hybrid

Start autonomous, then take over:

```bash
# Run 5 iterations autonomously
./scripts/ralph.sh PD-123 --max-iterations 5

# Review progress, then continue manually
/ralph PD-123
```

---

## Linear Integration

Ralph reads from and writes to Linear:

| Action         | Linear Update              |
| -------------- | -------------------------- |
| Start story    | Sub-issue -> "In Progress" |
| Complete story | Sub-issue -> "Done"        |
| Hit blocker    | Comment added to sub-issue |

Parent issue stays open until all sub-issues are done.

---

## Requirements

- Claude Code CLI installed
- Linear MCP server configured (`mcp__linear-server`)
- Git repository
- `jq` (for JSON parsing in bash loop)

---

## Files

| File                      | Purpose                                      |
| ------------------------- | -------------------------------------------- |
| `plugin.json`             | Plugin manifest                              |
| `skills/ralph/SKILL.md`   | Execution skill invoked by `/ralph`          |
| `skills/ralph/prompt.md`  | Instructions for each iteration              |
| `scripts/ralph.sh`        | Bash loop that spawns fresh Claude instances |
| `README.md`               | This file                                    |
