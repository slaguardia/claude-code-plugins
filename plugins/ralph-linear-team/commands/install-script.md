---
description: "Install team-loop.sh script to your project"
allowed-tools: ["Bash"]
---

# Install Team Loop Script

Copy the `team-loop.sh` script and its prompt files to your current project directory.

## Instructions

Run these commands to copy the files:

```bash
cp "${CLAUDE_PLUGIN_ROOT}/scripts/team-loop.sh" ./team-loop.sh && chmod +x ./team-loop.sh
cp "${CLAUDE_PLUGIN_ROOT}/scripts/planning-agent.md" ./planning-agent.md
cp "${CLAUDE_PLUGIN_ROOT}/scripts/research-agent.md" ./research-agent.md
```

Then confirm success:

```bash
ls -la ./team-loop.sh ./planning-agent.md ./research-agent.md
```

## After Installation

The script is now available in your project root. Run it with:

```bash
./team-loop.sh "Your feature description"
```

Or add it to your PATH for global access.

## Script Options

```bash
./team-loop.sh <FEATURE_DESCRIPTION> [options]

Options:
  --max-iterations N  Maximum planning iterations (default: 5)
  --help, -h          Show help message
```
