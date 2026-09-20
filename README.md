# Claude Code Plugins

Skills, agents, and commands for React Native, Next.js, feature workflows, and
app compliance auditing. Take the whole plugin, or take a single skill.

## Install

Pick one of the three routes. Do not mix routes one and three: you would end up
with each skill twice.

### 1. A whole plugin (Claude Code)

```
/plugin marketplace add slaguardia/claude-code-plugins
/plugin install workflow@slaguardia
```

On Claude Code v2.1.275 or later, one command does both:

```
/plugin install workflow --marketplace slaguardia/claude-code-plugins
```

Third-party marketplaces do not auto-update by default. To get updates, open
`/plugin`, go to **Marketplaces**, select `slaguardia`, and choose **Enable
auto-update**. Otherwise run `/plugin marketplace update slaguardia` yourself.

### 2. A single skill (any agent)

Use this to take one skill without the rest. It works with Claude Code, Codex,
Cursor, Copilot, Zed, and others.

```bash
npx skills add slaguardia/claude-code-plugins --skill execute
```

List what is available first:

```bash
npx skills add slaguardia/claude-code-plugins --list
```

These are file copies you own and edit, not a managed bundle.

### 3. Clone and symlink (to edit the skills yourself)

A plugin install is read-only, so edits to it are lost on the next update.
Symlink instead, and the working tree stays the source of truth.

```bash
git clone https://github.com/slaguardia/claude-code-plugins
cd claude-code-plugins
./scripts/link-skills.sh
```

Run `./scripts/link-skills.sh --dry-run` first to see what it would change, and
`--unlink` to undo. The script refuses to overwrite a real directory that is
already in `~/.claude/skills`.

## Skills

Every skill is self-contained, so route 2 works for any row here.

| Skill | Plugin | What it does |
|-------|--------|--------------|
| `interactive-planning` | workflow | Turn an idea into task files with user stories |
| `acceptance-criteria` | workflow | Generate testable acceptance criteria |
| `execute` | workflow | Implement a feature, one sub-task at a time |
| `ship` | workflow | Run stories in parallel subagents |
| `goal-prompt` | workflow | Emit a short hand-off prompt for another agent |
| `react-native-expert` | react-native-design | Cross-platform mobile specialist |
| `ui-design` | react-native-design | Design principles, spacing, accessibility |
| `useeffect-patterns` | react-native-design | When NOT to use Effect |

## Available Plugins


| Plugin | Description | Components |
|--------|-------------|------------|
| **workflow** | Planning, execution, and documentation hygiene | 5 skills, 3 commands |
| **react-native-design** | Complete React Native/Expo toolkit | 5 agents, 3 skills, 4 commands |
| **compliance-auditor** | App compliance auditing suite | 8 commands |
| **nextjs-development** | Next.js development tools | 2 commands |
| **database-migration** | Flyway migration tools | 1 command |

## Plugin Details

### workflow `v1.2.0`

End-to-end feature workflow: planning into user stories, acceptance criteria, autonomous execution, and documentation hygiene. Works with Linear issues or local `.tasks/` JSON files.

**Skills:**
- `interactive-planning` - Create task files with user stories through Q&A
- `acceptance-criteria` - Generate testable acceptance criteria
- `execute` - Autonomously implement a feature, one sub-task at a time
- `goal-prompt` - Emit a short hand-off prompt for another agent
- `ship` - Parallel execution across sub-tasks

**Commands:**
- `/update-docs` - Sync docs with codebase structure
- `/capture-learnings` - Save session insights to docs
- `/claude-flow-audit` - Audit CLAUDE.md and agent config health

### react-native-design `v1.4.0`

Complete React Native/Expo development toolkit with UI design standards, specialized agents, and code quality tools.

**Agents:**
- `design-agent` - UI development standards with glassmorphism focus
- `modal-agent` - Modal component creation and auditing
- `form-handler` - Form state, validation, and transitions
- `cache-agent` - React Query cache management
- `merge-agent` - Pre-merge quality checks

**Skills:**
- `react-native-expert` - Cross-platform mobile specialist
- `ui-design` - Design principles, spacing, accessibility
- `useeffect-patterns` - When NOT to use Effect

**Commands:**
- `/lint` - Comprehensive linting and type checking
- `/architecture-audit` - Project structure analysis
- `/accessibility-audit` - iOS Dynamic Type compliance
- `/cook` - Product refinement by taste

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
│   ├── workflow/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json     # Plugin metadata
│   │   ├── skills/
│   │   └── commands/
│   ├── react-native-design/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── README.md
│   │   ├── agents/
│   │   ├── skills/
│   │   └── commands/
│   ├── compliance-auditor/
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
├── scripts/
│   ├── validate-plugins.sh     # CI validation
│   └── link-skills.sh          # symlink skills into ~/.claude/skills
└── README.md
```

## Installation Commands

One line per plugin, after adding the marketplace once (see [Install](#install)).

```bash
/plugin install workflow@slaguardia              # planning, execution, docs
/plugin install react-native-design@slaguardia   # React Native/Expo toolkit
/plugin install compliance-auditor@slaguardia    # compliance auditing
/plugin install nextjs-development@slaguardia    # Next.js development
/plugin install database-migration@slaguardia    # Flyway migrations
```

The name after `@` is the marketplace name from `.claude-plugin/marketplace.json`,
not the GitHub repo path.

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
