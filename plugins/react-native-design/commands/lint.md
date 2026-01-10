# Lint Command

Run comprehensive linting and type checking for React Native/Expo projects.

## Instructions

1. **Run TypeScript Type Checking**

   ```bash
   npx tsc --noEmit
   ```

   Review any type errors and fix them. Common issues:
   - Missing type annotations
   - Incorrect prop types
   - Null/undefined handling

2. **Run ESLint**

   ```bash
   npx eslint . --ext .ts,.tsx --fix
   ```

   Auto-fix what's possible, then manually address:
   - Unused imports and variables
   - React Hooks dependency arrays
   - Accessibility issues (if eslint-plugin-react-native-a11y is configured)

3. **Run Prettier**

   ```bash
   npx prettier --write "**/*.{ts,tsx,js,jsx,json}"
   ```

   Ensures consistent code formatting across the project.

4. **Check for Unused Dependencies**

   ```bash
   npx depcheck
   ```

   Review unused dependencies and remove if not needed.

5. **React Native Specific Checks**

   Verify:
   - No inline styles that should be in StyleSheet
   - Images have proper dimensions or resizeMode
   - TouchableOpacity/Pressable have proper hitSlop for accessibility
   - Text components are wrapped properly for iOS/Android

6. **Expo Specific Checks**

   If using Expo:
   ```bash
   npx expo-doctor
   ```

   Address any compatibility issues with Expo SDK.

7. **Fix Remaining Issues**

   For each remaining error:
   - Read the file containing the error
   - Understand the context
   - Apply the appropriate fix
   - Verify the fix doesn't break other code

8. **Final Verification**

   Run all checks again to ensure everything passes:
   ```bash
   npx tsc --noEmit && npx eslint . --ext .ts,.tsx
   ```

## Common Fixes

| Issue | Fix |
|-------|-----|
| Missing return type | Add explicit return type annotation |
| Unused variable | Remove or prefix with underscore |
| Missing dependency in useEffect | Add to dependency array or use useCallback |
| any type | Replace with proper TypeScript type |
| Inline style | Move to StyleSheet.create() |

## Quality Standards

- Zero TypeScript errors
- Zero ESLint errors (warnings acceptable with justification)
- Consistent Prettier formatting
- No unused dependencies
