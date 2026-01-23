---
description: Audit app for Apple App Store Review Guidelines compliance
---

# Apple App Store Compliance Audit

Thoroughly audit app for compliance with Apple's App Store Review Guidelines.

Reference: https://developer.apple.com/app-store/review/guidelines/

## Audit Areas

### 1. Safety (1.1 - 1.5)
- User-generated content: Ensure moderation, reporting, blocking features exist
- Offensive or harmful content: Check for prevention mechanisms
- Interactions: Ensure safe social interactions and no harassment

### 2. Performance (2.1 - 2.6)
- Stability: App should not crash; check synchronous code on main thread
- Metadata accuracy: App name, description, screenshots match functionality
- Versioning: App version is consistent; no placeholders remain

### 3. Business (3.1 - 3.3)
- In-app purchases: Correctly implemented; external payment links prohibited
- Subscription flows: Free trial, upgrade, cancellation compliant
- Advertising: Ads follow 3.1.1 rules and do not mislead users

### 4. Design (4.1 - 4.5)
- Human Interface Guidelines: Check spacing, typography, system components
- Dark mode & dynamic type: Properly supported
- Deceptive UI: No dark patterns, misleading buttons, or prompts

### 5. Legal & Privacy (5.1 - 5.6)
- Data collection: Permissions requested only when necessary
- Privacy labels: Match actual data collection and usage
- Account deletion: Users can delete accounts and associated data fully
- COPPA / GDPR / local regulations: If applicable, confirm compliance

### 6. Additional Checks
- Permissions: Camera, microphone, location, photo library, notifications
- External links: Ensure no forbidden redirections or payment flows
- Third-party integrations: Check they do not violate rules
- Accessibility: VoiceOver, Dynamic Type, sufficient contrast

## Output Format

| Guideline | Assessment | Explanation | Recommendation |
|-----------|------------|-------------|----------------|
| 5.1.1 Privacy | Pass/Needs Fix/Risky | Why | How to fix |

### Risk Levels
- Critical: Likely to trigger rejection
- Medium: May trigger rejection
- Low: Minor issue
- N/A: Not applicable

## Audit Process

1. Audit all code, assets, and config files (Info.plist, app.json, etc.)
2. Provide structured output with guideline reference
3. Highlight high-risk items likely to trigger rejection
4. Suggest concrete, actionable fixes with code snippets
5. Prioritize critical violations first
