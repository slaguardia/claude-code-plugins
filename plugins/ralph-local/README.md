# Local Tasks Plugin

Complete local task workflow automation: planning with user stories, interactive/headless collaboration, and autonomous implementation via the Ralph Wiggum loop. All tasks stored in local JSON files.

## Features

### Skills

- **ralph** - Execute one Ralph Wiggum loop iteration. Implements user stories one at a time with fresh context per iteration.
- **interactive-planning** - Create local task files with user stories and acceptance criteria through interactive Q&A.
- **headless-planning** - Async planning via markdown files. Questions and answers happen in a planning document.

### Commands

- **import-tasks** - Import tasks from a markdown file into local JSON task format.

## Installation

Add to your Claude Code plugins:

```bash
claude plugins add local-tasks
```

## Requirements

- Claude Code CLI
- `jq` for JSON parsing (install: `brew install jq` or `apt install jq`)

## Usage

### Ralph (Autonomous Implementation)

```bash
/ralph FEAT-20240115_123456-abc1
```

Executes one iteration:
1. Reads feature.json and story files from `.tasks/` directory
2. Selects next incomplete user story (US-XXX)
3. Implements the story following acceptance criteria
4. Runs quality checks (TypeScript, lint, format)
5. Commits changes
6. Marks story as done in the JSON file
7. Logs progress and exits for fresh context

### Interactive Planning

```bash
/interactive-planning [feature description]
```

Creates structured local task files through Q&A:
1. Ask clarifying questions with lettered options
2. Generate feature.json with feature design
3. Create story files for each user story
4. Review with user before saving

### Headless Planning

```bash
/headless-planning [feature description]
/headless-planning planning-doc.md  # Continue existing
```

Async planning workflow:
1. Creates markdown planning document with embedded questions
2. User answers by editing the document
3. User runs command again to continue
4. Claude creates task files when ready

### Import Tasks

```bash
/import-tasks path/to/tasks.md
```

Imports tasks from various markdown formats into local JSON task files.

## Task File Structure

```
.tasks/
  FEAT-20240115_123456-abc1/
    feature.json      # Main feature definition
    index.json        # Quick reference index
    stories/
      US-001.json     # First user story
      US-002.json     # Second user story
      ...
```

### feature.json

```json
{
  "id": "FEAT-20240115_123456-abc1",
  "title": "Feature: Allow hosts to message attendees",
  "summary": "Enable personalized communication...",
  "status": "planning",
  "createdAt": "2024-01-15T12:34:56Z",
  "outOfScope": ["Group messaging", "Rich media"],
  "technicalConsiderations": ["Rate limiting"],
  "storiesCount": 4
}
```

### stories/US-001.json

```json
{
  "id": "US-001",
  "featureId": "FEAT-20240115_123456-abc1",
  "title": "View attendee list for messaging",
  "userStory": "As an event host, I want to see a list of my event's attendees so that I can select who to message.",
  "acceptanceCriteria": [
    "Given I am viewing my event, when I click 'Message Attendees', then I see a list of all registered attendees",
    "The list shows attendee name and registration status",
    "I can search/filter the attendee list by name"
  ],
  "dependencies": [],
  "status": "todo",
  "createdAt": "2024-01-15T12:34:56Z",
  "completedAt": null,
  "iteration": null
}
```

### index.json

```json
{
  "featureId": "FEAT-20240115_123456-abc1",
  "featureFile": "feature.json",
  "storiesDir": "stories/",
  "totalStories": 4,
  "completedStories": 0,
  "lastUpdated": "2024-01-15T12:34:56Z"
}
```

## Workflow Example

1. Plan feature: `/interactive-planning add host messaging`
2. Review generated task files in `.tasks/`
3. Start implementation: `/ralph FEAT-20240115_123456-abc1`
4. Repeat ralph for each user story
5. All stories complete? Feature is done!

## Reading Tasks from Bash

The JSON format is designed to be easily readable from bash scripts:

```bash
# List all features
ls .tasks/

# Get feature summary
jq '.summary' .tasks/FEAT-xxx/feature.json

# List all stories
ls .tasks/FEAT-xxx/stories/

# Get story status
jq '.status' .tasks/FEAT-xxx/stories/US-001.json

# Count incomplete stories
jq -r '.status' .tasks/FEAT-xxx/stories/*.json | grep -c "todo"

# Get all acceptance criteria for a story
jq '.acceptanceCriteria[]' .tasks/FEAT-xxx/stories/US-001.json
```

## Architecture

```
plugins/local-tasks/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── scripts/
│   └── ralph.sh                 # Main implementation loop
├── skills/
│   ├── ralph/
│   │   ├── SKILL.md             # Skill definition
│   │   └── prompt.md            # Iteration prompt
│   ├── interactive-planning/
│   │   └── SKILL.md             # Interactive planning skill
│   └── headless-planning/
│       └── SKILL.md             # Headless planning skill
├── commands/
│   └── import-tasks.md          # Import command
└── README.md
```

## Tips

- **One story per iteration**: Ralph implements exactly one story, then exits for fresh context
- **Check progress.txt**: Contains patterns and learnings from previous iterations
- **Review JSON files**: Easy to inspect and modify task status manually
- **Use jq**: Great for querying and modifying JSON from command line

## Related Plugin

For comprehensive planning with web research validation, see the **local-tasks-team** plugin which uses a two-agent adversarial planning loop.

## License

MIT
