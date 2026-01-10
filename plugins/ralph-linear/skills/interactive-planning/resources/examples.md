# Linear Issue Examples

Reference examples showing good patterns for parent issues (feature design) and sub-issues (user stories).

**Remember:**

- **Parent issue** = Feature design (Summary, Out of Scope, Technical Considerations). NO acceptance criteria, NO open questions.
- **Sub-issues** = User stories with acceptance criteria.

---

## Example 1: Feature with Multiple Sub-Issues

### Parent Issue

**Title:** Allow hosts to send announcements to event attendees

**Description:**

```markdown
## Summary

Event hosts need a way to send announcements to confirmed attendees for updates like venue changes, schedule modifications, or important reminders.

## Out of Scope

- Two-way messaging/replies
- Messaging unconfirmed attendees
- Email notifications (push only for now)
- Message history/archive
- Rich text formatting
- Read receipts (future consideration)
```

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
- [ ] Success confirmation after send
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

## Example 2: UI Enhancement Feature

### Parent Issue

**Title:** Add visual indicator to distinguish host accounts on connections page

**Description:**

```markdown
## Summary

Users cannot easily identify which connections are event hosts. Adding a visual badge helps users discover hosts they might want to follow for event updates.

## Out of Scope

- Host verification/certification system
- Different badge levels based on event count
- Host-specific profile sections

## Technical Considerations

- May need to add `is_host` or `event_count` to connection query
- Reuse existing badge component with new variant
```

### Sub-Issue 1

**Title:** US-001: Display host badge on connection cards

**Description:**

```markdown
As a user browsing connections, I want to see who is an event host so that I can follow people who create events I'm interested in.

## Acceptance Criteria

- [ ] Host badge appears on connection card if user has hosted 1+ events
- [ ] Badge positioned consistently (e.g., near profile image)
- [ ] Badge uses existing design system colors
- [ ] Verify appearance in simulator on multiple screen sizes
```

### Sub-Issue 2

**Title:** US-002: Filter connections by host status

**Description:**

```markdown
As a user, I want to filter the connections list to show only hosts so that I can quickly find event creators.

## Acceptance Criteria

- [ ] "Hosts only" toggle in filter options
- [ ] Filter persists during session
- [ ] Empty state when no hosts match current filters
- [ ] Filter state reflected in URL params (if applicable)
```

---

## Example 3: Bug Fix with Sub-Issues

### Parent Issue

**Title:** Fix: Profile image not loading on first visit to connection profile

**Description:**

```markdown
## Summary

When visiting a connection's profile for the first time, the profile image shows a blue placeholder instead of loading the actual image. Subsequent visits work correctly.

## Out of Scope

- Image compression/optimization
- Offline image caching
- Image upload changes

## Technical Considerations

- Check if ImageCache.preloadImages is being called before navigation
- Verify expo-image cachePolicy is set to "memory-disk"
- May need to preload images in useConnectionProfile hook
```

### Sub-Issue 1

**Title:** US-001: Ensure profile image loads on first visit

**Description:**

```markdown
As a user, I want to see a connection's profile image immediately so that I can recognize them.

## Acceptance Criteria

- [ ] Profile image loads on first navigation to profile
- [ ] No blue placeholder flash visible
- [ ] Image loads within 200ms (cached behavior)
- [ ] Works for both profile picture and header image
```

### Sub-Issue 2

**Title:** US-002: Add fallback for failed image loads

**Description:**

```markdown
As a user, I want to see a graceful fallback if an image fails to load so that the UI doesn't appear broken.

## Acceptance Criteria

- [ ] Default avatar shown if profile image fails to load
- [ ] Gradient placeholder shown if header image fails
- [ ] No error states visible to user
- [ ] Retry on next visit
```

---

## Example 4: Simple Single Sub-Issue

### Parent Issue

**Title:** Add character count to event description field

**Description:**

```markdown
## Summary

Event hosts have no visibility into the character limit when writing event descriptions, leading to truncated content.

## Out of Scope

- Changing the character limit
- Rich text/markdown support
- Auto-save drafts
```

### Sub-Issue 1

**Title:** US-001: Show character count on event description

**Description:**

```markdown
As an event host, I want to see how many characters I've used so that I can write descriptions that fit the limit.

## Acceptance Criteria

- [ ] Character count displays below description field
- [ ] Format: "X / 2000 characters"
- [ ] Count updates as user types
- [ ] Warning color when within 100 characters of limit
- [ ] Verify in simulator
```

---

## Title Writing Reference

### Good Titles

| Title                                               | Why It's Good                             |
| --------------------------------------------------- | ----------------------------------------- |
| "Add visual indicator to distinguish host accounts" | Specific action, clear what's being added |
| "Enable hosts to message event attendees"           | Action verb, specifies who and what       |
| "Fix: Profile image not loading on first visit"     | Clear it's a bug, describes the symptom   |
| "Allow filtering saved events by date"              | Action verb, specific feature             |

### Bad Titles

| Title              | Problem                |
| ------------------ | ---------------------- |
| "Fix bug"          | Too vague - which bug? |
| "Improve profile"  | What improvement?      |
| "Update messaging" | Update how?            |
| "User feedback"    | Not actionable         |

---

## Acceptance Criteria Reference

### Good Criteria

- "Button shows confirmation dialog before deleting"
- "Loading spinner appears within 100ms of tap"
- "Error toast displays for 3 seconds"
- "Empty state shows when list has 0 items"

### Bad Criteria

- "Works correctly" (not verifiable)
- "Looks good" (subjective)
- "Fast" (not measurable)
- "User-friendly" (vague)
