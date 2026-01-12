---
description: "Install ralph.sh script to your project"
allowed-tools: ["Bash"]
---

# Install Ralph Script

Copy the `ralph.sh` script from the plugin to your current project directory.

## Instructions

Run this command to copy the script:

```bash
cp "${CLAUDE_PLUGIN_ROOT}/scripts/ralph.sh" ./ralph.sh && chmod +x ./ralph.sh
```

Then confirm success:

```bash
ls -la ./ralph.sh
```

## After Installation

The script is now available in your project root. Run it with:

```bash
./ralph.sh LINEAR_ISSUE_ID
```

Or add it to your PATH for global access.

## Script Options

```bash
./ralph.sh <LINEAR_ISSUE_ID> [options]

Options:
  --max-iterations N  Maximum iterations before stopping (default: 10)
  --sleep N           Seconds to wait between iterations (default: 2)
  --help, -h          Show help message
```
