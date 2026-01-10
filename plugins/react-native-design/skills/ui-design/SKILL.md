---
name: ui-design
description: React Native UI design principles, component patterns, and consistency standards. Triggers on designing new UI components, screens, or patterns.
---

# React Native UI Design Skill

Use this skill when designing new UI components, screens, or patterns in React Native/Expo codebases.

## Core Design Principles

### 1. Consistency Over Customization

- Use existing component variants instead of custom styling props
- Follow established patterns from similar components in the codebase
- When adding new components, match existing visual language

### 2. User Control & Dismissibility

- All overlays (modals, sheets, popups) must have clear dismiss affordances
- Users should never feel "trapped" in a UI state
- Provide escape hatches: X buttons, backdrop tap, swipe gestures

### 3. Progressive Disclosure

- Start with essential information only
- Reveal complexity through user interaction
- Use multi-step flows for complex operations

### 4. Visual Hierarchy

- Primary actions should be visually prominent
- Destructive actions use warning colors (typically red)
- Secondary/cancel actions are visually subdued

## Button Standards

### Sizing Guide

| Size       | Use Case                                      |
| ---------- | --------------------------------------------- |
| **Modal**  | All buttons inside modals/dialogs             |
| **Medium** | Standard forms, settings screens              |
| **Large**  | Onboarding, hero CTAs, primary screen actions |
| **Small**  | Inline actions, compact UI, secondary actions |

### Variant Guide

| Variant          | Visual            | Use Case                                      |
| ---------------- | ----------------- | --------------------------------------------- |
| **Solid**        | Filled, prominent | Main positive actions (Save, Confirm, Submit) |
| **Destructive**  | Red/warning color | Dangerous actions (Delete, Block, Remove)     |
| **Cancel**       | Subdued, outline  | Cancel in destructive confirmations           |
| **Outline**      | Border only       | Alternative actions (View Terms, Learn More)  |
| **Text/Ghost**   | Text only         | Tertiary actions, links                       |

### Best Practices

```typescript
// Modal buttons should always be full-width
<Button
  title="Confirm"
  variant="primary"
  size="modal"
  fullWidth={true}
/>

// Never use custom colors - use variants
// Bad:
<Button backgroundColor="#ff0000" />

// Good:
<Button variant="destructive" />
```

## Spacing Standards

### Button Containers

```typescript
<View style={{ width: '100%', gap: 16 }}>
  <Button title="Primary Action" variant="primary" />
  <Button title="Cancel" variant="cancel" />
</View>
```

### Standard Message Text

```typescript
{
  fontSize: 16,
  color: '#666',
  textAlign: 'center',
  lineHeight: 22,
  marginBottom: 24,
}
```

## Animation Standards

### Button Press Feedback

| Property | Press Value | Duration | Easing   |
| -------- | ----------- | -------- | -------- |
| Scale    | 0.97        | 150ms    | ease-out |
| Opacity  | 0.8         | 150ms    | ease-out |

### Modal Transitions

| Animation | Duration | Effect                  |
| --------- | -------- | ----------------------- |
| Open      | 250ms    | Fade in + scale 0.85->1 |
| Close     | 180ms    | Fade out + scale 1->0.85|

## Image Best Practices

### Use Optimized Image Components

- `expo-image` (Expo projects)
- `react-native-fast-image` (bare RN)

```typescript
<Image
  source={{ uri: url }}
  cachePolicy="memory-disk"
  contentFit="cover"
/>
```

### Image Fallback Pattern

```typescript
<View style={{ height, overflow: 'hidden' }}>
  <View style={{ position: 'absolute', inset: 0 }}>
    <PlaceholderContent />
  </View>
  {!imageError && (
    <Image
      source={{ uri: imageUrl }}
      onError={() => setImageError(true)}
    />
  )}
</View>
```

## Component Architecture

### When to Create Shared Components

**Create as shared/reusable** when:
- Used by 2+ screens
- Generic UI pattern (buttons, cards, modals)
- Likely to be reused in future features

**Keep screen-specific** when:
- Only used by one screen
- Contains business logic specific to that screen
- Tightly coupled to screen's data structure

## Accessibility Checklist

- [ ] Touch targets minimum 44x44 points
- [ ] Sufficient color contrast (4.5:1 minimum)
- [ ] Screen reader labels on interactive elements
- [ ] Focus management in modals
- [ ] Loading states announced to screen readers

## Pre-Implementation Checklist

- [ ] Check if similar component exists in codebase
- [ ] Review design system/existing patterns
- [ ] Use existing variants instead of custom styles
- [ ] Follow spacing standards
- [ ] Ensure proper dismiss affordances for overlays
- [ ] Use correct button sizes and variants
- [ ] Consider loading and error states
- [ ] Test on multiple screen sizes
