# Modal Audit

Audit all modal components for consistency in close buttons, cancel buttons, and styling.

## Audit Criteria

For each modal, identify:

1. **Close Button (X)**: Whether it has a close button in the top-right corner
2. **Bottom Buttons**: Whether it has bottom buttons (Cancel, Confirm, Save, etc.)
3. **Modal Type**: Alert/confirmation, informational, form/input, options/menu

## Report Requirements

### Modals Missing Top-Right 'X'
- These need an 'X' added for consistency
- Exception: Legal/compliance modals that require explicit action

### Alert/Confirmation Modals Without Cancel Button
- Destructive confirmations SHOULD have Cancel button
- Simple confirmations can use X button only

### Options/Menu Modals With Cancel Button
- These should use X button, not Cancel button
- Flag as unnecessary

### Button Styling Consistency
Check all buttons have:
- `size="modal"`
- `fullWidth={true}`
- Correct variant (solid, destructive, cancel, outline)
- No custom style props

## Output Format

| File Path | Component Name | Modal Type | Missing Elements | Suggested Action |
|-----------|----------------|------------|------------------|------------------|

## Modal Type Standards

### Simple Confirmation
- X button: Yes (default)
- Cancel button: No (use X)
- Primary button: Yes

### Destructive Confirmation
- X button: No (showCloseButton={false})
- Cancel button: Yes
- Destructive button: Yes

### Options/Menu
- X button: Yes
- Cancel button: No (use X)
- Action buttons: Yes

### Form Modal
- X button: Yes
- Cancel button: No (use X)
- Submit button: Yes

### Success/Info
- X button: Yes
- Cancel button: No
- Primary button: Yes (optional)
