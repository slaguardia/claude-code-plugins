# Team Planning Examples

## Example 1: Simple Feature

**Input:**
```bash
/team-planning "add dark mode toggle to settings"
```

**Output after 2 iterations:**

`.tasks/FEAT-20240115_143022-x7k2/feature.json`:
```json
{
  "id": "FEAT-20240115_143022-x7k2",
  "title": "Feature: Add dark mode toggle to settings",
  "summary": "Allow users to switch between light and dark themes for improved accessibility and user preference.",
  "status": "planning",
  "createdAt": "2024-01-15T14:30:22Z",
  "outOfScope": [
    "Auto-detection based on system preferences",
    "Custom color themes beyond light/dark",
    "Per-page theme settings"
  ],
  "technicalConsiderations": [
    "Store preference in localStorage for persistence",
    "Use CSS custom properties for theme switching",
    "Ensure all components support both themes"
  ],
  "researchSummary": "## Research Summary\n\nConducted 4 web searches...",
  "storiesCount": 3
}
```

`.tasks/FEAT-20240115_143022-x7k2/stories/US-001.json`:
```json
{
  "id": "US-001",
  "featureId": "FEAT-20240115_143022-x7k2",
  "title": "Add theme toggle UI",
  "userStory": "As a user, I want to see a toggle switch in settings so that I can switch between light and dark mode.",
  "acceptanceCriteria": [
    "Given I am on the settings page, when I look at the Appearance section, then I see a toggle labeled 'Dark Mode'",
    "The toggle visually indicates the current theme state",
    "The toggle is accessible via keyboard (Space/Enter to toggle)",
    "Screen readers announce 'Dark mode on/off' when toggled"
  ],
  "dependencies": [],
  "status": "todo",
  "createdAt": "2024-01-15T14:30:22Z",
  "completedAt": null,
  "iteration": null
}
```

---

## Example 2: From Markdown File

**Input file `messaging-feature.md`:**
```markdown
# Host Messaging Feature

We need hosts to be able to message their event attendees directly.

## Requirements
- Hosts can see their attendees
- Hosts can send text messages
- Messages appear in attendee's inbox

## Constraints
- No group messaging initially
- Text only, no attachments
```

**Command:**
```bash
/team-planning --file messaging-feature.md
```

**Output after 3 iterations:**

`.tasks/FEAT-20240115_150045-m3p9/feature.json`:
```json
{
  "id": "FEAT-20240115_150045-m3p9",
  "title": "Feature: Enable hosts to message event attendees",
  "summary": "Allow event hosts to send direct text messages to individual attendees for personalized communication.",
  "status": "planning",
  "createdAt": "2024-01-15T15:00:45Z",
  "outOfScope": [
    "Group messaging or broadcast to all",
    "Rich media attachments (images, files)",
    "Message scheduling",
    "Read receipts"
  ],
  "technicalConsiderations": [
    "Integrate with existing notification system",
    "Messages stored in attendee inbox",
    "Consider rate limiting for spam prevention"
  ],
  "researchSummary": "## Research Summary\n\nBased on 5 web searches covering messaging UX patterns, privacy considerations, and accessibility requirements...",
  "storiesCount": 4
}
```

**Stories created:**
- `US-001.json` - View attendee list for messaging
- `US-002.json` - Compose and send message
- `US-003.json` - View sent messages history
- `US-004.json` - Handle messaging errors gracefully

---

## Example 3: Complex Feature with Many Iterations

**Input:**
```bash
/team-planning --max-iterations 10 "implement user authentication with social login"
```

**Iteration flow:**

| Iteration | Planning Agent | Research Agent |
|-----------|----------------|----------------|
| 1 | Created 5 initial stories | Found 4 gaps: missing OAuth flows, no MFA story |
| 2 | Added OAuth stories, MFA story | Found 2 gaps: session management, password requirements |
| 3 | Added session handling, refined password criteria | Found 1 gap: account recovery |
| 4 | Added account recovery story | DONE - Plan approved |

**Final output: 9 user stories covering:**
- Basic email/password registration
- Social login (Google, GitHub)
- Session management
- Password requirements and validation
- MFA setup and verification
- Account recovery
- Error handling and security measures
