# Architecture Audit Command

Audit React Native codebase against industry-standard mobile app architecture patterns from Twitter, TikTok, Instagram, and other major social apps.

## Industry Reference Patterns

### 1. Navigation Performance (TikTok/Twitter Pattern)

- **Deferred Heavy Work**: Non-critical operations should wait until after navigation animation completes
- **Native Stack Awareness**: `InteractionManager` doesn't work for `@react-navigation/native-stack` (animations are fully native)
- **Correct Pattern**: Use `navigation.addListener('transitionEnd', ...)` instead

### 2. Lazy Component Mounting (Facebook/Instagram Pattern)

- **Modals**: Should only mount when visible (`{showX && <Modal />}`)
- **Bottom Sheets**: Should defer mounting until after navigation (`{isNavigationComplete && <Sheet />}`)
- **Rationale**: Each `@gorhom/bottom-sheet` creates gesture handlers, portals, ~10 Reanimated values

### 3. Cache Normalization (Twitter/Apollo Pattern)

- **Single Source of Truth**: Each entity should have one canonical cache location
- **Subscription Model**: Components subscribe to cache changes via `useSyncExternalStore`
- **Optimistic Updates**: UI updates instantly before server confirmation

### 4. Data Prefetching (TikTok/TanStack Pattern)

- **Prefetch on Intent**: Start fetching on `onPressIn` (~200ms before navigation)
- **Viewport Prediction**: Preload 1-2 items ahead of current scroll position
- **Image Preloading**: Preload images in data fetching hooks

### 5. Skeleton/Shimmer (Twitter Pattern)

- **Preserve Layout**: Skeletons match actual content dimensions
- **Subtle Animation**: 1.5-2 second cycle, wave effect preferred over pulse
- **Progressive Reveal**: Load navigation first, then content with placeholders

## Audit Steps

### Step 1: Check Detail Screen Patterns

Review critical files for pattern adherence:
- transitionEnd listener usage
- Single isNavigationComplete state
- Deferred queries accepting null
- Lazy-mounted modals
- Deferred bottom sheet mounting

### Step 2: Check Feed Card Patterns

Review card components for:
- Lazy-mounted modals
- Image error caching
- Optimistic UI updates
- onPressIn prefetch

### Step 3: Check Data Hook Patterns

Review hooks for:
- Conditional enabling with null
- Image preloading
- Proper enabled flags
- Appropriate staleTime/gcTime

### Step 4: Check Cache Architecture

Review for:
- Normalized cache structure
- useSyncExternalStore usage
- Optimistic update functions
- Cross-component consistency

## Output Format

### Pattern Compliance Table

| Pattern | Status | Location | Notes |
|---------|--------|----------|-------|
| transitionEnd for deferred work | Pass/Warn/Fail | file:line | |
| Lazy modal mounting | Pass/Warn/Fail | file:line | |
| Cache normalization | Pass/Warn/Fail | file:line | |

### Anti-Pattern Detection

Flag these issues:
- InteractionManager with native stack (High risk)
- Always-mounted modals (Medium risk)
- Always-mounted bottom sheets (High risk)
- Fetch-on-render in detail screens (Medium risk)

### Industry Benchmarks

- **Navigation Frame Rate**: Target 55-60fps
- **Time to Interactive**: Excellent <300ms, Good 300-500ms
- **Cache Hit Rate**: Target 100% for preloaded images, >90% for revisited screens
