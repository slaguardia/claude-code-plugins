# Headless Planning Examples

## Example: Async Feature Planning

### Step 1: User Initiates Planning
```
User: /headless-planning hosts need to message their attendees
```

### Step 2: Claude Creates Planning Issue

Claude creates Linear issue PD-123 with embedded questions:
```markdown
## Summary
Event hosts need a way to communicate with their event attendees.

---

## Planning Questions

### 1. What's the primary goal of messaging?
**Your answer:** [ANSWER HERE]

### 2. Who should hosts be able to message?
**Your answer:** [ANSWER HERE]

---

**Status:** Waiting for answers. Once complete: `/headless-planning PD-123`
```

### Step 3: User Answers in Linear

User edits the issue description in Linear with their answers.

### Step 4: User Continues
```
User: /headless-planning PD-123
```

### Step 5: Claude Creates Sub-Issues

Claude reads answers and creates sub-issues linked to the parent.

## When to Use Headless vs Interactive

### Use Headless Planning When:
- Planning will span multiple days
- Multiple stakeholders need to review
- User prefers working directly in Linear
- Async collaboration is needed

### Use Interactive Planning When:
- Quick back-and-forth is preferred
- User is available for immediate discussion
- Simple features with few unknowns
