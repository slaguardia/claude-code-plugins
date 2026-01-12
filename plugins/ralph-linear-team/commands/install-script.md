---
description: "Install team-loop.sh script to your project"
allowed-tools: ["Bash"]
---

# Install Team Loop Script

Copy the `team-loop.sh` script from the plugin to your current project directory.

## Instructions

Run this command to copy the script:

```bash
cp "${CLAUDE_PLUGIN_ROOT}/scripts/team-loop.sh" ./team-loop.sh && chmod +x ./team-loop.sh
```

Then confirm success:

```bash
ls -la ./team-loop.sh
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
