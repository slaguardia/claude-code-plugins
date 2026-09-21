# Better Alternatives to useEffect

## useMemo - Expensive Calculations

When you need to cache a computation:

```typescript
// Instead of useEffect + useState
const visibleTodos = useMemo(
  () => filterTodos(todos, filter),
  [todos, filter]
);
```

## key Prop - Reset Component State

When you need to reset all state when a prop changes:

```typescript
// Instead of useEffect watching props
<EditProfile key={userId} userId={userId} />
```

The component unmounts and remounts fresh.

## Lifting State Up

When parent needs the data anyway:

```typescript
// Instead of syncing via Effect
function Parent() {
  const [selection, setSelection] = useState(null);
  return (
    <>
      <List items={items} onSelect={setSelection} />
      <Detail item={selection} />
    </>
  );
}
```

## useSyncExternalStore

For subscribing to external stores:

```typescript
import { useSyncExternalStore } from 'react';

const snapshot = useSyncExternalStore(
  store.subscribe,     // Function to subscribe
  store.getSnapshot,   // Get current value
  store.getServerSnapshot // Optional SSR
);
```

## Event Handlers

For user-triggered actions:

```typescript
// Instead of useEffect watching state
function handleClick() {
  const nextValue = compute(currentValue);
  setValue(nextValue);
  onChange(nextValue); // Notify parent here
}
```

## Initializer Functions

For expensive initial state:

```typescript
// Instead of useEffect to initialize
const [data] = useState(() => expensiveComputation());
```

## useCallback with Event Handler

For stable callbacks passed to children:

```typescript
const handleChange = useCallback((value) => {
  setItems(items => [...items, value]);
}, []);
```
