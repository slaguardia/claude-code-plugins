# Headless Planning Examples

Examples showing the issue description format at each stage of async planning.

**Remember:**

- **Parent issue** = Feature design (Summary, Out of Scope, Technical Considerations). NO acceptance criteria, NO open questions.
- **Sub-issues** = User stories with acceptance criteria.

---

## Stage 1: Initial Questions

**Title:** Allow hosts to message event attendees

**Description:**

```markdown
## Summary

Event hosts need a way to communicate with their event attendees for updates, changes, or reminders.

---

## Planning Questions

Please answer these questions inline (replace the placeholders):

### 1. What's the primary goal of messaging?

- A) Send event updates/announcements (one-way)
- B) Enable two-way conversation
- C) Send automated reminders
- D) Other

**Your answer:** [ANSWER HERE]

### 2. Who should hosts be able to message?

- A) All RSVPs (confirmed + maybe)
- B) Only confirmed attendees
- C) Anyone who viewed the event
- D) Other

**Your answer:** [ANSWER HERE]

### 3. What's the scope for v1?

- A) Basic one-way messaging
- B) Full chat with replies
- C) Just push notifications (no in-app)
- D) Other

**Your answer:** [ANSWER HERE]

### 4. Any specific constraints or requirements?

**Your answer:** [ANSWER HERE]

---

**Status:** Waiting for answers. Once complete, ask Claude to continue: `/headless-planning PD-123`
```

---

## Stage 2: User Has Answered

**Description after user edits:**

```markdown
## Summary

Event hosts need a way to communicate with their event attendees for updates, changes, or reminders.

---

## Planning Questions

Please answer these questions inline (replace the placeholders):

### 1. What's the primary goal of messaging?

- A) Send event updates/announcements (one-way)
- B) Enable two-way conversation
- C) Send automated reminders
- D) Other

**Your answer:** A - just announcements for venue changes, time updates, etc.

### 2. Who should hosts be able to message?

- A) All RSVPs (confirmed + maybe)
- B) Only confirmed attendees
- C) Anyone who viewed the event
- D) Other

**Your answer:** B - only people who confirmed they're coming

### 3. What's the scope for v1?

- A) Basic one-way messaging
- B) Full chat with replies
- C) Just push notifications (no in-app)
- D) Other

**Your answer:** A - keep it simple for now, we can add replies later

### 4. Any specific constraints or requirements?

**Your answer:** Should have a character limit, maybe 500 chars. Also need error handling if push fails.

---

**Status:** Waiting for answers. Once complete, ask Claude to continue: `/headless-planning PD-123`
```

---

## Stage 3: Follow-Up Questions (if needed)

**Description updated by Claude:**

```markdown
## Summary

Event hosts need a way to send one-way announcements to confirmed attendees for updates like venue changes or schedule modifications.

---

## Follow-Up Questions

Thanks for your answers! A few clarifications:

### 1. Where should the "Send Announcement" button appear?

- A) Event detail screen (host view)
- B) Event edit screen
- C) Separate messaging tab
- D) Other

**Your answer:** [ANSWER HERE]

### 2. Should hosts see delivery status?

- A) Just success/failure confirmation
- B) Detailed delivery stats (X of Y delivered)
- C) Individual read receipts
- D) No status needed

**Your answer:** [ANSWER HERE]

---

## Confirmed So Far

- One-way announcements only
- Confirmed attendees only
- 500 character limit
- Push notifications
- Error handling needed

---

**Status:** Waiting for follow-up answers. Once complete: `/headless-planning PD-123`
```

---

## Stage 4: Planning Complete (Feature Design Only)

**Final parent issue description** - NO acceptance criteria here:

```markdown
## Summary

Event hosts can send one-way announcements to confirmed attendees for updates like venue changes, schedule modifications, or important reminders. Announcements are delivered via push notification with a 500 character limit.

## Out of Scope

- Two-way messaging/replies
- Messaging unconfirmed attendees
- Email notifications
- Message history/archive
- Rich text formatting
- Read receipts

## Technical Considerations

- Push notification integration required
- Error handling for failed deliveries
- Character limit enforcement (500 chars)

---

**Status:** Planning complete. Sub-issues created below.
```

**Note:** This is feature design only. Acceptance criteria are in the sub-issues below.

---

## Sub-Issue Examples

### Sub-Issue 1

**Title:** US-001: Add announcement entry point

**Description:**

```markdown
As an event host, I want to access an announcement feature from my event so that I can communicate with attendees.

## Acceptance Criteria

- [ ] "Send Announcement" button visible on event detail screen (host view only)
- [ ] Button opens announcement composer modal
- [ ] Button hidden for non-hosts
- [ ] Verify button placement in simulator
```

### Sub-Issue 2

**Title:** US-002: Compose and send announcement

**Description:**

```markdown
As an event host, I want to write and send an announcement so that my attendees receive updates.

## Acceptance Criteria

- [ ] Text input field with 500 character limit
- [ ] Character count indicator showing remaining characters
- [ ] Send button disabled if message empty
- [ ] Loading state while sending
- [ ] Success/failure confirmation after send
- [ ] Modal closes on successful send
```

### Sub-Issue 3

**Title:** US-003: Deliver announcement to attendees

**Description:**

```markdown
As an attendee, I want to receive announcements so that I stay informed about event updates.

## Acceptance Criteria

- [ ] Push notification sent to confirmed RSVPs only
- [ ] Notification includes event name and message preview
- [ ] Tapping notification opens event detail screen
- [ ] Error state shown to host if delivery fails
```

---

## Question Writing Tips

### Good Questions

- Specific to the feature context
- Offer concrete options (A, B, C, D)
- Allow "Other" for unexpected answers
- Focus on decisions that affect implementation

### Bad Questions

- Too generic ("What do you want?")
- Yes/no when more nuance is needed
- Technical jargon the user may not understand
- Questions you can answer from context

---

## Answer Parsing Tips

When reading user answers:

- Look for content after "**Your answer:**"
- Accept partial answers (A, B, etc.) or full explanations
- If answer is still "[ANSWER HERE]", question wasn't answered
- If answer is ambiguous, ask a follow-up question
