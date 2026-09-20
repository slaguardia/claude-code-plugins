# Claude Code Skills

Agent skills for React Native and Expo, feature workflows, app compliance
auditing, and Next.js. Take the whole set, or take one skill.

Everything here is a skill. There are no slash commands as a separate kind of
file, because a skill can already be user-invoked. That is what makes every
entry installable on its own.

## Install

Pick one route. Do not mix routes 1 and 3: you would get every skill twice.

### 1. The whole set (Claude Code)

```
/plugin marketplace add slaguardia/claude-code-plugins
/plugin install slaguardia-skills@slaguardia
```

On Claude Code v2.1.275 or later, one command does both:

```
/plugin install slaguardia-skills --marketplace slaguardia/claude-code-plugins
```

Third-party marketplaces do not auto-update by default. To get updates, open
`/plugin`, go to **Marketplaces**, select `slaguardia`, and choose **Enable
auto-update**. Otherwise run `/plugin marketplace update slaguardia` yourself.

### 2. One skill (any agent)

Works with Claude Code, Codex, Cursor, Copilot, Zed, and others.

```bash
npx skills add slaguardia/claude-code-plugins --skill privacy-audit
```

List everything available first:

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

Use `--dry-run` to preview and `--unlink` to undo. The script refuses to
overwrite a real directory that is already in `~/.claude/skills`.

## Invocation

Two kinds of skill, split by who can reach them.

- **Model-invoked**: Claude reaches for it on its own when the work matches.
  The description carries trigger phrases.
- **User-invoked**: only you can start it, by typing its name. The frontmatter
  sets `disable-model-invocation: true`. These were slash commands before.

## Skills

### workflow

| Skill | Invocation | What it does |
|-------|-----------|--------------|
| `interactive-planning` | model | Turn an idea into task files with user stories |
| `acceptance-criteria` | model | Generate testable acceptance criteria |
| `execute` | model | Implement a feature, one sub-task at a time |
| `ship` | model | Run stories in parallel subagents |
| `goal-prompt` | model | Emit a short hand-off prompt for another agent |
| `update-docs` | user | Clean up stale docs, document new patterns |
| `capture-learnings` | user | Save session insights into project docs |
| `claude-flow-audit` | user | Find token-overhead patterns in `.claude/` |

### react-native

| Skill | Invocation | What it does |
|-------|-----------|--------------|
| `react-native-expert` | model | Cross-platform mobile specialist |
| `ui-design` | model | Design principles, spacing, accessibility |
| `useeffect-patterns` | model | When NOT to use Effect |
| `lint-react-native` | user | Linting and type checking for RN/Expo |
| `architecture-audit` | user | Check against mobile architecture patterns |
| `accessibility-audit` | user | iOS Dynamic Type and layout breakage |
| `cook` | user | Refine the codebase against the product spec |

### compliance

| Skill | Invocation | What it does |
|-------|-----------|--------------|
| `apple-compliance` | user | App Store Review Guidelines |
| `privacy-audit` | user | GDPR, CCPA/CPRA, BIPA |
| `terms-audit` | user | Terms of service clarity |
| `dmca-audit` | user | DMCA policy, 17 U.S.C. § 512 |
| `guidelines-audit` | user | Community guidelines |
| `policy-cohesion` | user | Consistency across policy documents |
| `welcome-screen-audit` | user | Auth and welcome screen UX |
| `modal-audit` | user | Modal component consistency |

### web

| Skill | Invocation | What it does |
|-------|-----------|--------------|
| `lint-nextjs` | user | TypeScript, ESLint, Prettier, Depcheck |
| `update-docs-nextjs` | user | Sync CLAUDE.md with the codebase |

### database

| Skill | Invocation | What it does |
|-------|-----------|--------------|
| `migrate` | user | Run Flyway migrations and resolve errors |

## Agents

Five React Native agents ship with the plugin: `design-agent`, `modal-agent`,
`form-handler`, `cache-agent`, and `merge-agent`. Agents are not individually
installable; they come with the whole set.

## Layout

```
claude-code-plugins/
├── .claude-plugin/
│   ├── plugin.json         # one plugin, explicit skill paths
│   └── marketplace.json    # so the repo is its own marketplace
├── skills/
│   ├── workflow/<name>/SKILL.md
│   ├── react-native/<name>/SKILL.md
│   ├── compliance/<name>/SKILL.md
│   ├── web/<name>/SKILL.md
│   └── database/<name>/SKILL.md
├── agents/<name>.md
└── scripts/
    ├── link-skills.sh          # symlink skills into ~/.claude/skills
    └── validate-frontmatter.sh # what the official validator does not check
```

A skill is listed in `plugin.json` to ship. A skill on disk but absent from
that list does not ship, which is how work in progress stays out of the way.

## Validation

Two checks, and they do different jobs.

```bash
claude plugin validate .            # manifest schema; what /plugin install runs
./scripts/validate-frontmatter.sh   # skill and agent frontmatter, name collisions
```

The official validator does not read `SKILL.md` frontmatter. A skill with no
frontmatter passes it and is silently dead at runtime. That gap is why the
second script exists. CI runs both.

## Contributing

Add a skill under `skills/<category>/<name>/SKILL.md`, give it `name` and
`description` in frontmatter, and add its path to `skills` in
`.claude-plugin/plugin.json`. Set `disable-model-invocation: true` if only a
human should start it. Run both checks above before opening a PR.

## License

MIT
