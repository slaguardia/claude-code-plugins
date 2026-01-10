---
name: useeffect-patterns
description: React useEffect best practices from official docs. Use when writing/reviewing useEffect, useState for derived values, or data fetching patterns.
---

# You Might Not Need an Effect

Effects are an **escape hatch** from React. They let you synchronize with external systems. If there is no external system involved, you shouldn't need an Effect.

## Quick Reference

| Situation                      | DON'T                          | DO                                    |
| ------------------------------ | ------------------------------ | ------------------------------------- |
| Derived state from props/state | `useState` + `useEffect`       | Calculate during render               |
| Expensive calculations         | `useEffect` to cache           | `useMemo`                             |
| Reset state on prop change     | `useEffect` with `setState`    | `key` prop                            |
| User event responses           | `useEffect` watching state     | Event handler directly                |
| Notify parent of changes       | `useEffect` calling `onChange` | Call in event handler                 |
| Fetch data                     | `useEffect` without cleanup    | `useEffect` with cleanup OR framework |

## When You DO Need Effects

- Synchronizing with **external systems** (non-React widgets, browser APIs)
- **Subscriptions** to external stores (use `useSyncExternalStore` when possible)
- **Analytics/logging** that runs because component displayed
- **Data fetching** with proper cleanup (or use framework's built-in mechanism)

## When You DON'T Need Effects

1. **Transforming data for rendering** - Calculate at top level, re-runs automatically
2. **Handling user events** - Use event handlers, you know exactly what happened
3. **Deriving state** - Just compute it: `const fullName = firstName + ' ' + lastName`
4. **Chaining state updates** - Calculate all next state in the event handler

## Decision Tree

```
Need to respond to something?
├── User interaction (click, submit, drag)?
│   └── Use EVENT HANDLER
├── Component appeared on screen?
│   └── Use EFFECT (external sync, analytics)
├── Props/state changed and need derived value?
│   └── CALCULATE DURING RENDER
│       └── Expensive? Use useMemo
└── Need to reset state when prop changes?
    └── Use KEY PROP on component
```

## Anti-Patterns

### Anti-Pattern 1: Redundant State

```typescript
// BAD
const [fullName, setFullName] = useState('');
useEffect(() => {
  setFullName(firstName + ' ' + lastName);
}, [firstName, lastName]);

// GOOD
const fullName = firstName + ' ' + lastName;
```

### Anti-Pattern 2: Resetting State on Prop Change

```typescript
// BAD
useEffect(() => {
  setComment('');
}, [userId]);

// GOOD - Use key prop
<Profile userId={userId} key={userId} />
```

### Anti-Pattern 3: Fetching Without Cleanup

```typescript
// BAD - Race condition
useEffect(() => {
  fetchResults(query).then(setResults);
}, [query]);

// GOOD
useEffect(() => {
  let ignore = false;
  fetchResults(query).then(json => {
    if (!ignore) setResults(json);
  });
  return () => { ignore = true; };
}, [query]);
```

### Anti-Pattern 4: Notifying Parent in Effect

```typescript
// BAD
useEffect(() => {
  onChange(data);
}, [data, onChange]);

// GOOD - Call in event handler
function handleClick() {
  const nextData = computeData();
  onChange(nextData);
}
```

## Better Alternatives

### useMemo for Expensive Calculations

```typescript
const sortedItems = useMemo(
  () => items.slice().sort((a, b) => a.name.localeCompare(b.name)),
  [items]
);
```

### key Prop for Resetting State

```typescript
// Reset Profile component when userId changes
<Profile userId={userId} key={userId} />
```

### useSyncExternalStore for External Data

```typescript
const snapshot = useSyncExternalStore(
  store.subscribe,
  store.getSnapshot
);
```

### Event Handlers for User Actions

```typescript
function handleSubmit() {
  const data = computeFormData();
  onSubmit(data);
  // State updates happen here, not in Effect
}
```
