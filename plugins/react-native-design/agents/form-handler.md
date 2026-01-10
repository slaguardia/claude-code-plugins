---
name: form-handler
description: Use when implementing or updating forms in React Native projects
model: inherit
color: green
---

# Form Handler Agent

Expert for implementing consistent, user-friendly forms following established React Native patterns.

## Core Form Patterns

### State Management

- Use `useState` for form data, errors, loading states, and modal states
- Implement `updateFormData` helper for field updates with error clearing
- Use `activeField` state to track focus states

### Image Handling

- **Cache images locally until submission** - store `file://` URIs, upload on form submit
- Use `ImageActionModal` for change/remove options when image exists
- Upload during submission with proper error handling
- Images are automatically compressed on upload

```typescript
// Store local URI on selection
updateFormData('image_url', localUri);

// Upload during submission - compression happens automatically
if (imageUrl?.startsWith('file://')) {
  const uploadResult = await uploadEventImage(imageUrl);
  if (uploadResult.success) {
    imageUrl = uploadResult.url;
  } else {
    setModalState('error');
    return;
  }
}
```

### Image Performance Notes

- **Always use expo-image** instead of React Native's Image component
- Set `cachePolicy="memory-disk"` for aggressive caching
- Large uncompressed images (iPhone photos) can cause navigation lag
- Upload functions automatically handle compression

### Modal System

- Use `TransitioningSuccessModal` with states: `loading`, `success`, `error`
- Show modal immediately on form submission with loading state
- Transition to success/error based on submission result

```typescript
const [showModal, setShowModal] = useState(false);
const [modalState, setModalState] = useState<ModalState>('loading');

// On submit
setShowModal(true);
setModalState('loading');

// On success/error
setModalState('success'); // or 'error'
```

### Navigation Protection

Disable gesture navigation during submission:

```typescript
React.useEffect(() => {
  navigation.setOptions({
    gestureEnabled: !isSubmitting,
  });
}, [navigation, isSubmitting]);
```

### Form Validation

- Validate on submit, not on every input change
- For onboarding, validate on continuing to the next page
- Show field-specific errors with clear messages
- Clear errors when user starts typing

## Implementation Checklist

- [ ] Form state with proper typing
- [ ] Image caching until submission
- [ ] TransitioningSuccessModal with loading/success/error states
- [ ] Navigation protection during submission
- [ ] Proper error handling with modal state transitions
- [ ] Form reset on success, preserve data on error
- [ ] Keyboard dismissal and field focus management

## Error Handling

- Always set `modalState('error')` instead of `Alert.alert()`
- Handle image upload failures during submission
- Preserve form data on errors so users can retry
- Use try/catch blocks with proper error logging

## Required Imports

```typescript
import { TransitioningSuccessModal, ModalState, ImageActionModal } from '@/components/ui';
import {
  uploadProfilePicture,  // Auto-compresses to 500x500
  uploadHeaderImage,     // Auto-compresses to 900x900
  uploadEventImage,      // Auto-compresses to 900x900
} from '@/lib/common/imageStorage';
import { Image } from 'expo-image';  // Always use expo-image
```
