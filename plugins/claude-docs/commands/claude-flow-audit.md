---
description: Audit .claude/ configuration for token-overhead patterns (CLAUDE.md size, hooks, MCP schemas)
allowed-tools: Read, Glob, Grep, Bash
---

Audit this project's `.claude/` configuration for token-overhead patterns that compound across every Claude Code prompt.

Based on a public 90-day instrumented study (@Mnilax, May 2026) of 430 hours / 6M tokens / $1,340 spend, finding 73% of token spend was overhead from invisible compounding patterns. This audit covers the project-level subset — not user-global config (`~/.claude/`), which is per-developer.

## Why this matters

Every prompt pre-pays for: project `CLAUDE.md`, every active hook, every connected MCP's tool schema, conversation history. Productive tokens are the residual. Lean project config = more usage from the same plan for everyone on the team.

## Audit steps

Run each section below. Report findings against the targets, then summarize.

### Step 1: CLAUDE.md size

```bash
echo "=== Root CLAUDE.md ==="
wc -w CLAUDE.md 2>/dev/null

echo "=== .claude/CLAUDE.md (if exists) ==="
wc -w .claude/CLAUDE.md 2>/dev/null

echo "=== Nested CLAUDE.md files ==="
find . -name "CLAUDE.md" -not -path "./node_modules/*" -not -path "./.claude/worktrees/*" -exec wc -w {} +
```

**Targets:**

- Root `CLAUDE.md`: under 2,000 words. This loads on every prompt.
- `.claude/CLAUDE.md`: avoid duplicating root content. Keep under 500 words if it exists.
- Nested CLAUDE.md (e.g. `src/hooks/CLAUDE.md`): under 1,500 words each. These only load when files in that directory are read — good pattern, prefer this over root bloat.

**Flag patterns** (read the actual content, don't just rely on word count):

- Verbose explanations that could be 3-word imperatives ("when X, do Y")
- Content duplicated from `docs/` that could be a one-line reference instead
- Long lists of every domain pattern when a representative sample + link would do
- Sections last touched > 6 months ago that aren't actively guiding decisions (`git log -1 --format=%ar -- CLAUDE.md`)
- Multiple sections covering the same topic at different fidelity

**Do not flag:**

- Project-specific gotchas with concrete consequences (the "profiles.id NOT user_id" warning is exactly the right kind of content)
- Short imperative rules with a clear when/why

### Step 2: Project hooks

```bash
echo "=== .claude/settings.json hooks ==="
jq '.hooks // {}' .claude/settings.json 2>/dev/null

echo "=== .claude/settings.local.json hooks ==="
jq '.hooks // {}' .claude/settings.local.json 2>/dev/null
```

**Per hook type:**

- **`UserPromptSubmit`**: highest cost — fires on every prompt before Claude reads the question. Each one needs a specific, recurring justification. Kill ones that inject vague "context" or "memory."
- **`SessionStart`**: avoid "loaded successfully" notifications. Worth it only for: current branch, env vars affecting behavior, active-task summary.
- **`PreToolUse` / `PostToolUse`**: usually fine if they gate dangerous commands or do silent side effects. Flag any that inject prose into tool results (cost compounds with tool-call frequency).
- **`Stop`**: low cost (one fire per turn). Mostly fine.

For each hook found, report: trigger event, what it does, whether it's justified.

### Step 3: Project skills

```bash
echo "=== Project skill count ==="
ls .claude/skills/ 2>/dev/null

echo "=== SKILL.md sizes ==="
for f in .claude/skills/*/SKILL.md; do
  if [ -f "$f" ]; then
    words=$(wc -w < "$f")
    desc=$(awk '/^description:/{flag=1; sub(/^description: */, ""); print; flag=0}' "$f" | head -1)
    echo "$f: $words words"
    echo "  description: $(echo "$desc" | cut -c1-100)..."
  fi
done

echo "=== Last commit per skill (stale check) ==="
for d in .claude/skills/*/; do
  echo -n "$d: "
  git log -1 --format="%ar" -- "$d" 2>/dev/null
done
```

**Flag:**

- Skills with no commits in > 6 months — likely abandoned, may still load on routing matches
- SKILL.md descriptions > 200 words (descriptions are loaded for skill-routing decisions on every prompt)
- Two skills with overlapping triggers (causes ambiguous loads)
- Skills that are really just rules (belongs in CLAUDE.md, not a skill)

**Don't flag:**

- Active skills with focused, non-overlapping descriptions (this is what skills are for)
- Long SKILL.md _body_ with short description (body only loads on invocation, that's fine)

### Step 4: Project commands

```bash
echo "=== Project commands ==="
ls .claude/commands/ 2>/dev/null
wc -w .claude/commands/*.md 2>/dev/null
```

Lower priority — commands only load when invoked with `/name`. Flag only:

- Commands that duplicate npm scripts or `make` targets without adding judgment
- Commands not run in 6+ months (`git log -1 --format=%ar -- .claude/commands/<name>.md`)

### Step 5: MCP servers in project config

```bash
echo "=== Project-configured MCPs ==="
jq '.mcpServers // {} | keys' .claude/settings.json 2>/dev/null
jq '.mcpServers // {} | keys' .claude/settings.local.json 2>/dev/null
```

Each MCP ships its tool schema with every request that has tools enabled. Flag any MCP not used in > 80% of project work.

(Note: most MCPs are user-global, not project-level. If `mcpServers` is empty here, that's fine — out of scope.)

## Output format

### Inventory

| Surface                            | Current          | Target         | Status       |
| ---------------------------------- | ---------------- | -------------- | ------------ |
| Root CLAUDE.md (words)             | <count>          | < 2,000        | ✅ / ⚠️ / ❌ |
| .claude/CLAUDE.md (words)          | <count or "n/a"> | < 500          | ✅ / ⚠️ / ❌ |
| Nested CLAUDE.md (count, max size) | <count>, <max>   | well-scoped    | ✅ / ⚠️ / ❌ |
| UserPromptSubmit hooks             | <count>          | each justified | ✅ / ⚠️ / ❌ |
| SessionStart hooks                 | <count>          | no-noise only  | ✅ / ⚠️ / ❌ |
| Project skills                     | <count>          | actively used  | ✅ / ⚠️ / ❌ |
| Project commands                   | <count>          | actively used  | ✅ / ⚠️ / ❌ |
| Project MCPs                       | <count>          | 80%+ usage     | ✅ / ⚠️ / ❌ |

### Top findings (ranked by impact)

For each finding: file path, what's wrong, concrete suggested change.

1. [Highest-impact bloat with file:line and excerpt of what to cut]
2. [Second priority]
3. [Third priority]

### What's done well

Patterns this project gets right (document so they don't regress on future PRs).

### Out of scope (mention, do not change)

These need per-developer action — project audit cannot fix:

- User-global `~/.claude/CLAUDE.md`
- User-global skills, plugins, MCP servers
- Conversation length discipline (cap chats, edit-don't-stack follow-ups, prefer `/compact` over `/clear`)
- Default extended thinking (toggle per-message, not globally)
- Cache miss on resume (1-hour prompt cache upgrade if you take frequent breaks)
- Wrong-direction generation (Cmd+. to interrupt early)

## What this audit cannot detect

These need runtime instrumentation (HTTP proxy or transcript scan), not config inspection:

- Actual cache hit rate per session
- Conversation history token cost growth
- Extended thinking token spend by task type
- Real productive-vs-overhead token split

The static audit catches the _risk_. Confirming actual cost requires logging.

## Reference

- Original study: @Mnilax (May 2026), 430 hours / 6M tokens of instrumented Claude Code usage
- Patterns audited here: CLAUDE.md bloat, hook injection, skill over-installation, MCP schema bloat, SessionStart noise
- Patterns out of scope (behavioral): conversation re-reads, cache miss, extended thinking, wrong-direction generation
