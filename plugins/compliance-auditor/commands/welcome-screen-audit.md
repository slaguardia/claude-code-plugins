# Welcome Screen Audit

Audit welcome and authentication screens against modern (2024-2025) UX best practices.

## Evaluation Criteria

### 1. Welcome Screen / Primary Flow
- Logo placement: centered or slightly above vertical center
- Optional short, neutral tagline (2-5 words) allowed under logo
- Primary action (Continue with email) is prominent
- Email input NOT shown on welcome screen (identity-first principle)
- Secondary actions (OAuth, support links) are visually secondary
- Copy is neutral ("Continue with email" vs "Sign up")

### 2. Email-First Authentication Flow
- Entering email determines routing:
  - Existing user -> password entry screen
  - New user -> onboarding
- No "email + password" fields together on first screen
- No explicit "Sign in / Sign up" decision required
- Transitions feel like progression, not error
- Password screen shows "Forgot password?" link only

### 3. OAuth Buttons
- Buttons share same height, width, and shape
- Apple button follows Apple's guidelines (black/white, correct logo)
- Google button follows Google guidelines (white background, gray border)
- Pill/capsule shapes allowed with proper accessibility
- Press and loading states present
- Buttons are secondary to email but clearly tappable

### 4. Visual & UX Principles
- Proper spacing between elements; whitespace is generous
- Neutral copy; no long marketing paragraphs on auth surfaces
- Smooth transitions (fade/slide) for overlays, modals
- Keyboard behavior is intentional
- Overall screen feels calm, clean, and professional

### 5. Edge Cases & Security
- Email + OAuth collisions handled gracefully
- Users never see "account exists" language
- Flow prevents duplicate accounts and reduces errors

## Output Format

For each category, mark:
- ✅ Compliant
- ⚠ Needs improvement (with details)
- ❌ Not compliant (with details)

Include actionable recommendations for any issues.
