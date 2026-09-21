# Claude Code Skills

Agent skills for React Native and Expo, feature workflows, app compliance
auditing, and Next.js. Take the whole set, or take one skill.

Everything here is a skill. There are no slash commands as a separate kind of
file, because a skill can already be user-invoked. That is what makes every
entry installable on its own.

## Install

Two routes. Take the whole set, or take one skill.

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

Route 2 writes real files into your project, so edit them freely. To edit a
skill and keep pulling updates, clone the repo instead and see
[Working on these skills](#working-on-these-skills).

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
    ├── link-skills.sh     # symlink skills into ~/.claude/skills
    └── check-skills.rb    # what the official validator does not check
```

A skill is listed in `plugin.json` to ship. A skill on disk but absent from
that list does not ship, which is how work in progress stays out of the way.

## Working on these skills

This section is for editing the skills in this repo. It is not an install
route. If you only want to use them, use one of the two routes above.

`scripts/link-skills.sh` symlinks every skill into `~/.claude/skills`, so the
working tree is the one source of truth and an edit is live in your next
session. Neither install route does this: a plugin install is a read-only
managed copy, and `npx skills` copies files from a local path rather than
linking them.

```bash
git clone https://github.com/slaguardia/claude-code-plugins
cd claude-code-plugins
./scripts/link-skills.sh --dry-run   # preview
./scripts/link-skills.sh             # link
./scripts/link-skills.sh --unlink    # undo
```

It refuses to overwrite a real directory already in `~/.claude/skills`, and
reports it as a conflict instead. A conflict means that skill exists twice and
the two copies will drift.

## Validation

Two checks, and they do different jobs.

```bash
claude plugin validate .            # manifest schema; what /plugin install runs
ruby scripts/check-skills.rb        # frontmatter YAML, name collisions, unshipped skills
```

The official validator does not read `SKILL.md`. A skill with broken or missing
frontmatter passes it and is silently dead at runtime.

Claude Code's own frontmatter parser is lenient, which hides a sharper bug. A
description like `Does a thing. Keywords: a, b` loads fine in Claude Code but is
invalid YAML, because the second colon opens a nested mapping. `npx skills`
skips such a skill without failing, so it cannot be installed on its own and
nothing warns you. `check-skills.rb` parses with a real YAML parser to catch it.

CI runs both checks.

## Contributing

Add a skill under `skills/<category>/<name>/SKILL.md`, give it `name` and
`description` in frontmatter, and add its path to `skills` in
`.claude-plugin/plugin.json`. Set `disable-model-invocation: true` if only a
human should start it. Run both checks above before opening a PR.

## License

MIT
