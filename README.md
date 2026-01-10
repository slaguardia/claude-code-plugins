# Claude Code Plugins

A curated collection of Claude Code plugins for React Native development, Next.js workflows, Linear automation, compliance auditing, and more.

## Quick Start

### Add the Marketplace

```
/plugin marketplace add slaguardia/claude-code-plugins
```

Or with full URL:

```
/plugin marketplace add https://github.com/slaguardia/claude-code-plugins
```

### Install a Plugin

```
/plugin install react-native-design@slaguardia/claude-code-plugins
```

Or browse available plugins:

```
/plugin > Discover
```

## Available Plugins

| Plugin | Description | Components |
|--------|-------------|------------|
| **react-native-design** | Complete React Native/Expo toolkit | 5 agents, 2 skills, 4 commands |
| **ralph-linear** | Linear workflow automation with Ralph Wiggum loop | 3 skills, 2 commands |
| **compliance-auditor** | App compliance auditing suite | 8 commands |
| **claude-docs** | Documentation management | 2 commands |
| **nextjs-development** | Next.js development tools | 2 commands |
| **database-migration** | Flyway migration tools | 1 command |

## Plugin Details

### react-native-design `v1.3.0`

Complete React Native/Expo development toolkit with UI design standards, specialized agents, and code quality tools.

**Agents:**
- `design-agent` - UI development standards with glassmorphism focus
- `modal-agent` - Modal component creation and auditing
- `form-handler` - Form state, validation, and transitions
- `cache-agent` - React Query cache management
- `merge-agent` - Pre-merge quality checks

**Skills:**
- `ui-design` - Design principles, spacing, accessibility
- `useeffect-patterns` - When NOT to use Effect

**Commands:**
- `/lint` - Comprehensive linting and type checking
- `/architecture-audit` - Project structure analysis
- `/accessibility-audit` - iOS Dynamic Type compliance
- `/cook` - Product refinement by taste

### ralph-linear `v1.1.0`

Complete Linear workflow automation: planning issues with user stories, async collaboration, and autonomous implementation.

**Skills:**
- `/ralph` - Execute one Ralph Wiggum loop iteration
- `/interactive-planning` - Create Linear issues through Q&A
- `/headless-planning` - Async planning via Linear descriptions

**Commands:**
- `/process-feedback` - Improve Linear Feedback issues
- `/update-changelog` - Generate changelog from commits

**Requires:** `linear-server` MCP

### compliance-auditor `v1.0.0`

Comprehensive compliance auditing for app policies, privacy, and App Store requirements.

**Commands:**
- `/apple-compliance` - App Store Review Guidelines
- `/privacy-audit` - GDPR, CCPA/CPRA compliance
- `/terms-audit` - Terms of service clarity
- `/dmca-audit` - DMCA/copyright policy
- `/guidelines-audit` - Community guidelines
- `/policy-cohesion` - Cross-document consistency
- `/welcome-screen-audit` - Auth screen UX
- `/modal-audit` - Modal component consistency

### claude-docs `v1.2.0`

Tools for managing CLAUDE.md documentation.

**Commands:**
- `/capture-learnings` - Save session insights to docs
- `/update-docs` - Sync docs with codebase structure

### nextjs-development `v1.0.0`

Next.js development tools for App Router projects with pnpm.

**Commands:**
- `/lint` - TypeScript, ESLint, Prettier, Depcheck
- `/update-docs` - Sync documentation files

### database-migration `v1.0.0`

Database migration tools for Flyway.

**Commands:**
- `/migrate` - Run Flyway migrations and resolve errors

## Directory Structure

```
claude-code-plugins/
├── .claude-plugin/
│   └── marketplace.json        # Marketplace metadata
├── plugins/
│   ├── react-native-design/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json     # Plugin metadata
│   │   ├── README.md
│   │   ├── agents/
│   │   ├── skills/
│   │   └── commands/
│   ├── ralph-linear/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── README.md
│   │   ├── skills/
│   │   └── commands/
│   ├── compliance-auditor/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── README.md
│   │   └── commands/
│   ├── claude-docs/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── README.md
│   │   └── commands/
│   ├── nextjs-development/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── README.md
│   │   └── commands/
│   └── database-migration/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── README.md
│       └── commands/
└── README.md
```

## Installation Commands

Copy-paste commands to install each plugin:

```bash
# React Native/Expo toolkit
/plugin install react-native-design@slaguardia/claude-code-plugins

# Linear automation
/plugin install ralph-linear@slaguardia/claude-code-plugins

# Compliance auditing
/plugin install compliance-auditor@slaguardia/claude-code-plugins

# Documentation management
/plugin install claude-docs@slaguardia/claude-code-plugins

# Next.js development
/plugin install nextjs-development@slaguardia/claude-code-plugins

# Database migrations
/plugin install database-migration@slaguardia/claude-code-plugins
```

## Plugin Structure

Each plugin follows the standard Claude Code plugin structure:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json      # Plugin metadata (required)
├── .mcp.json            # MCP server configuration (optional)
├── README.md            # Documentation
├── commands/            # Slash commands (optional)
│   └── command-name.md
├── agents/              # Agent definitions (optional)
│   └── agent-name.md
└── skills/              # Skill definitions (optional)
    └── skill-name/
        ├── SKILL.md
        └── resources/
```

## Contributing

Feel free to open issues or submit pull requests to add new plugins or improve existing ones.

## License

MIT
