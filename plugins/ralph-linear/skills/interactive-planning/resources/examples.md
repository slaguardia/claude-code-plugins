# Interactive Planning Examples

## Example 1: Feature Request

### User Input
"Add a way for hosts to message their event attendees"

### Clarifying Questions
```
1. What's the primary goal of messaging?
   A) Send event updates/announcements
   B) Enable two-way conversation
   C) Send reminders
   D) Other

2. Who should hosts be able to message?
   A) All RSVPs (confirmed + maybe)
   B) Only confirmed attendees
   C) Anyone who viewed the event
   D) Other
```

### Generated Parent Issue

**Title:** Allow hosts to message event attendees

**Description:**
```markdown
## Summary
Event hosts need a way to send announcements and updates to their event attendees.

## Out of Scope
- Two-way chat/replies (v2 consideration)
- Messaging users who only viewed the event
- Message scheduling
```

### Generated Sub-Issues

**US-001: Add announcement entry point**
```markdown
As a host, I want to access a messaging feature from my event so that I can send updates.

## Acceptance Criteria
- [ ] "Message Attendees" button visible on event detail screen for hosts
- [ ] Button only appears for events with at least 1 confirmed attendee
- [ ] Tapping button navigates to compose screen
```

**US-002: Compose and send announcement**
```markdown
As a host, I want to compose and send an announcement so that attendees receive my message.

## Acceptance Criteria
- [ ] Text input for message (500 char limit)
- [ ] Preview of attendee count before sending
- [ ] Confirmation modal before sending
- [ ] Success/error feedback after sending
```
