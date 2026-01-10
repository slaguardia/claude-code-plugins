# Accessibility Audit Command

Audit React Native codebase for iOS Dynamic Type and pragmatic accessibility issues. Focus on real-world layout breakage risks, not strict WCAG compliance.

## Audit Areas

### A. Text Truncation (`numberOfLines`)

Review all uses of `numberOfLines`.

**Truncation is acceptable only for:**
- Tab labels
- Navigation titles
- Badges / chips

**Flag usage on:**
- Buttons with descriptive text
- List rows with important content
- Form fields or labels
- Descriptive paragraphs

### B. Absolute Positioning with Text

Review `position: 'absolute'` patterns near text components.

**Acceptable for:**
- Icons or decorative elements
- Overlay indicators
- Badges

**Flag when:**
- Text or text containers use fixed pixel offsets
- Username/display name positioned absolutely
- Text may overflow at larger font sizes

### C. Modal Usability

Review modal components for large text resilience.

**Flag if:**
- Content becomes unreachable (no scroll)
- Close affordance (X button) disappears or is pushed off-screen
- Fixed heights constrain text containers
- Buttons have no room to expand

## Scriptable Audit Checks

### 1. Fixed Heights on Text Containers
- `height:` styles on components rendering `<Text>`
- Recommend changing to `minHeight`

### 2. Font Scaling Disabled
- Any `allowFontScaling={false}` usage
- This should be zero

### 3. Non-Scrollable Screens
- Screen components with multiple `<Text>` nodes
- No `ScrollView`, `FlatList`, or `SectionList`

### 4. Pressables with Minimal Vertical Padding
- `Pressable`, `Touchable*`, or button components with:
  - Explicit `height < 44`
  - `paddingVertical < 8`

### 5. `numberOfLines` Usage
- All occurrences with value and location
- Categorize as acceptable (UI chrome) or needs review (content)

## Output Format

For each finding, report:

| Field | Description |
|-------|-------------|
| **Rule** | Rule name |
| **File** | Relative file path |
| **Line** | Line number |
| **Component** | Component name |
| **Risk** | Low / Medium / High |
| **Description** | What the issue is |
| **Remediation** | How to fix it |

## Summary Format

| Category | Count | Highest Risk |
|----------|-------|--------------|
| Font Scaling Disabled | X | - |
| Fixed Heights | X | Medium |
| Non-Scrollable Screens | X | Medium |
| Small Touch Targets | X | Low |
| numberOfLines (needs review) | X | Medium |
| Absolute Positioned Text | X | Medium |

End with **Top 3 Priority Fixes** with specific file:line references.
