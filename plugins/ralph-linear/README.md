# Ralph Linear Plugin

Complete Linear workflow automation: planning issues with user stories, async collaboration, and autonomous implementation via the Ralph Wiggum loop.

## Features

### Skills

- **ralph** - Execute one Ralph Wiggum loop iteration. Implements user stories one at a time with fresh context per iteration.
- **interactive-planning** - Create Linear issues with user stories and acceptance criteria through interactive Q&A.
- **headless-planning** - Async planning via Linear issue descriptions. Questions and answers happen directly in the issue.

### Commands

- **process-feedback** - Review and improve Linear Feedback project issues with better titles and descriptions.
- **update-changelog** - Generate changelog entries for the current app version from recent commits.

## Installation

Add to your Claude Code plugins:

```bash
claude plugins add ralph-linear
```

## Dependencies

Requires the Linear MCP server to be configured:
- `mcp: linear-server`

## Usage

### Ralph (Autonomous Implementation)

```
/ralph PD-123
```

Executes one iteration:
1. Fetches parent issue and sub-issues from Linear
2. Selects next incomplete user story (US-XXX)
3. Implements the story following acceptance criteria
4. Runs quality checks (TypeScript, lint, format)
5. Commits changes
6. Marks sub-issue as Done in Linear
7. Logs progress and exits for fresh context

### Interactive Planning

```
/interactive-planning [feature description]
```

Creates structured Linear issues through Q&A:
1. Ask clarifying questions with lettered options
2. Generate parent issue with feature design
3. Create sub-issues for each user story
4. Review with user before creating in Linear

### Headless Planning

```
/headless-planning [feature description]
/headless-planning PD-123  # Continue existing issue
```

Async planning workflow:
1. Creates Linear issue with embedded questions
2. User answers by editing issue description
3. User runs command again to continue
4. Claude creates sub-issues when ready

### Process Feedback

```
/process-feedback
```

Reviews unprocessed feedback issues and improves titles/descriptions.

### Update Changelog

```
/update-changelog
```

Generates changelog from recent commits for current version.

## Workflow Example

1. Plan feature: `/interactive-planning add host messaging`
2. Review generated issues in Linear
3. Start implementation: `/ralph PD-123`
4. Repeat ralph for each user story
5. Prepare for merge: `/update-changelog`
