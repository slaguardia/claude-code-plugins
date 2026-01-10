# React Native Design Plugin

Complete React Native/Expo development toolkit with UI design standards, specialized agents, code quality tools, and best practices.

## Features

### Agents

- **design-agent** - UI development standards expert with glassmorphism focus
- **modal-agent** - Modal component creation, auditing, and fixing
- **form-handler** - Form state, validation, and image caching expert
- **cache-agent** - React Query cache management and optimistic mutations
- **merge-agent** - Pre-merge preparation and code quality checks

### Skills

- **ui-design** - React Native UI principles, component patterns, spacing, accessibility
- **useeffect-patterns** - React useEffect best practices and alternatives

### Commands

- **lint** - Comprehensive linting (TypeScript, ESLint, Prettier, Depcheck, Expo)
- **architecture-audit** - Project structure and patterns compliance
- **accessibility-audit** - iOS Dynamic Type and accessibility compliance

## Installation

```bash
claude plugins add react-native-design
```

## Usage

### Agents

```
@design-agent Help me create a new settings screen
@modal-agent Audit all modals for consistency
@cache-agent Optimize React Query mutations
```

### Commands

```
/lint                    # Run all linting checks
/architecture-audit      # Audit project architecture
/accessibility-audit     # Check accessibility compliance
```

## Design Standards

- Clean, non-cluttered interfaces
- Glassmorphism with blur effects
- Consistent spacing (8pt grid)
- iOS Dynamic Type support
- React Query for server state
- Optimistic UI updates
