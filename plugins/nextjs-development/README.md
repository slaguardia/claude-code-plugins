# Next.js Development Plugin

Development tools for Next.js App Router projects with pnpm, including comprehensive linting and documentation management.

## Features

### Commands

- **lint** - Run comprehensive linting suite (TypeScript, ESLint, Prettier, Depcheck)
- **update-docs** - Review and update all CLAUDE.md documentation files

## Installation

Add to your Claude Code plugins:

```bash
claude plugins add nextjs-development
```

## Usage

### Lint Command

```
/lint
```

Runs the full linting suite and automatically fixes issues:
- TypeScript type checking (`pnpm typecheck`)
- ESLint code quality checks (`pnpm lint`)
- Prettier formatting (`pnpm prettier`)
- Dependency checking (`pnpm depcheck`)

Automatically fixes what it can with `pnpm lint:all:fix` and manually addresses remaining issues.

### Update Docs Command

```
/update-docs
```

Comprehensive documentation review and update:
1. Analyzes current codebase structure
2. Updates root CLAUDE.md
3. Updates all nested CLAUDE.md files
4. Verifies cross-references
5. Reports all changes made

## Requirements

- pnpm as package manager
- Next.js App Router project structure
- TypeScript configuration
- ESLint and Prettier configured

## Available Scripts

| Script | Description |
|--------|-------------|
| `pnpm typecheck` | Run TypeScript type checking |
| `pnpm lint` | Run typecheck + ESLint checks |
| `pnpm lint:fix` | Run ESLint and auto-fix issues |
| `pnpm prettier` | Check formatting with Prettier |
| `pnpm prettier:fix` | Fix formatting with Prettier |
| `pnpm depcheck` | Check for unused/missing dependencies |
| `pnpm lint:all` | Run all checks |
| `pnpm lint:all:fix` | Fix all auto-fixable issues |

## Best Practices

1. Run `/lint` before committing changes
2. Run `/update-docs` after making structural changes
3. Keep CLAUDE.md files in sync with codebase
4. Use proper TypeScript types instead of `any`
