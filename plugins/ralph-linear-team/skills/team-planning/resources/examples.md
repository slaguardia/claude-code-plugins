# Team Planning Examples

## Example 1: Simple Feature

**Input:**
```bash
/team-planning "add dark mode toggle to settings"
```

**Iteration 1 - Planning Agent Output:**
```json
{
  "summary": "Allow users to toggle between light and dark themes in the app settings.",
  "outOfScope": [
    "System-level theme detection",
    "Per-screen theme customization"
  ],
  "technicalConsiderations": [
    "Need to persist preference across sessions",
    "Consider existing color system"
  ],
  "userStories": [
    {
      "id": "US-001",
      "title": "Add dark mode toggle in settings",
      "userStory": "As a user, I want to toggle dark mode in settings so that I can use the app comfortably in low-light environments.",
      "acceptanceCriteria": [
        "Toggle appears in Settings screen under 'Appearance'",
        "Toggle state persists across app restarts",
        "Theme changes immediately when toggled"
      ]
    },
    {
      "id": "US-002",
      "title": "Apply dark theme colors",
      "userStory": "As a user, I want all screens to use dark colors when dark mode is enabled so that the experience is consistent.",
      "acceptanceCriteria": [
        "All text is readable against dark backgrounds",
        "Images and icons adapt appropriately",
        "No flashing when navigating between screens"
      ]
    }
  ]
}
```

**Iteration 1 - Research Agent Feedback:**
```json
{
  "iteration": 1,
  "overallAssessment": "Good start but missing accessibility and transition considerations",
  "gaps": [
    {
      "type": "accessibility",
      "severity": "medium",
      "description": "No mention of contrast ratios for accessibility compliance",
      "suggestion": "Add AC: 'All text meets WCAG AA contrast ratio (4.5:1 for normal text)'",
      "source": "https://example.com/dark-mode-accessibility"
    },
    {
      "type": "edge_case",
      "severity": "low",
      "description": "No handling for theme transition animations",
      "suggestion": "Consider adding smooth transition when theme changes",
      "source": "internal review"
    }
  ],
  "researchFindings": [
    {
      "topic": "Dark mode best practices",
      "query": "dark mode implementation best practices 2025",
      "keyFindings": [
        "Use semantic colors rather than hardcoded values",
        "Test with actual users in low-light conditions",
        "Consider reduced motion preferences"
      ],
      "sources": ["https://example.com/dark-mode-guide"]
    }
  ],
  "positives": [
    "Clear user stories",
    "Good separation of toggle and application logic"
  ]
}
```

**Iteration 2 - Research Agent:** `DONE` (after Planning Agent incorporated feedback)

---

## Example 2: Complex Feature

**Input:**
```bash
/team-planning "hosts need to message event attendees"
```

**Final Plan (after 3 iterations):**
```json
{
  "summary": "Allow event hosts to send direct messages to individual attendees, enabling personalized communication before, during, and after events.",
  "outOfScope": [
    "Group messaging or broadcast to all attendees",
    "Rich media attachments (images, files)",
    "Message scheduling for future delivery",
    "Real-time chat/typing indicators"
  ],
  "technicalConsiderations": [
    "Integrate with existing notification system for delivery",
    "Messages persist in attendee's inbox",
    "Rate limiting needed to prevent spam (max 50 messages/hour)",
    "Consider GDPR: users can delete message history"
  ],
  "userStories": [
    {
      "id": "US-001",
      "title": "View attendee list for messaging",
      "userStory": "As an event host, I want to see a list of my event's attendees so that I can select who to message.",
      "acceptanceCriteria": [
        "Given I am viewing my event, when I tap 'Message Attendees', then I see a list of all registered attendees",
        "List shows attendee name, profile photo, and registration status",
        "I can search/filter the attendee list by name",
        "Empty state shown if no attendees registered yet",
        "List is keyboard-navigable for accessibility"
      ],
      "dependencies": []
    },
    {
      "id": "US-002",
      "title": "Compose and send message to attendee",
      "userStory": "As an event host, I want to compose and send a text message to a selected attendee so that I can communicate important information.",
      "acceptanceCriteria": [
        "Given I have selected an attendee, when I tap 'Send Message', then a compose modal opens",
        "I can enter a message up to 1000 characters",
        "Character count displayed, changes color at 900+ characters",
        "Send button disabled if message is empty",
        "When I tap Send, message is delivered and I see success confirmation",
        "Error: If send fails, show error with retry option",
        "Compose modal is fully accessible via keyboard and screen reader"
      ],
      "dependencies": ["US-001"]
    },
    {
      "id": "US-003",
      "title": "View sent messages history",
      "userStory": "As an event host, I want to see messages I've sent to attendees so that I can track my communications.",
      "acceptanceCriteria": [
        "I can access 'Sent Messages' from the event page",
        "Messages show recipient, timestamp, and preview",
        "Messages sorted by most recent first",
        "I can tap a message to see full content"
      ],
      "dependencies": ["US-002"]
    },
    {
      "id": "US-004",
      "title": "Receive message as attendee",
      "userStory": "As an event attendee, I want to receive messages from hosts so that I stay informed about the event.",
      "acceptanceCriteria": [
        "I receive push notification when host sends message",
        "Message appears in my inbox/notifications",
        "I can see sender (host) name and event name",
        "Tapping notification opens the full message"
      ],
      "dependencies": ["US-002"]
    },
    {
      "id": "US-005",
      "title": "Handle blocked users",
      "userStory": "As a system, I need to prevent messaging to/from blocked users so that user safety is maintained.",
      "acceptanceCriteria": [
        "If attendee has blocked host, message silently fails (host sees generic error)",
        "If host has blocked attendee, attendee not shown in list",
        "Block status not revealed to either party",
        "Existing messages remain visible but marked appropriately"
      ],
      "dependencies": ["US-001", "US-002"]
    }
  ]
}
```

**Research Summary:**
```markdown
## Research Summary

Validated through 3 iterations of adversarial planning.

### Best Practices Incorporated
- Character limit with visual feedback (industry standard)
- Blocked user handling without revealing block status
- Rate limiting to prevent spam abuse
- GDPR consideration for message deletion

### Sources Consulted
- [Messaging UX Patterns 2025](https://example.com/messaging-ux)
- [Privacy in Direct Messaging](https://example.com/dm-privacy)
- [Accessible Modal Design](https://example.com/a11y-modals)

### Edge Cases Addressed
- Empty attendee list
- Message send failures
- Blocked user interactions
- Accessibility requirements
```

---

## Example 3: From Existing Linear Issue

**Input:**
```bash
/team-planning --issue PD-123
```

The loop will:
1. Fetch PD-123 details from Linear
2. Use title/description as initial input
3. Run planning/research loop
4. Create sub-issues under PD-123 (or update if already has sub-issues)
