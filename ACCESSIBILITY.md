# Accessibility Features

This maintenance page has been designed with comprehensive accessibility features to ensure it's usable by everyone, including users of assistive technologies.

## WCAG 2.1 Compliance

The page aims for WCAG 2.1 Level AA compliance with the following features:

### 1. Screen Reader Support

#### ARIA Labels and Roles
- **Skip Navigation**: Skip link at the top allows screen reader users to jump directly to main content
- **Semantic HTML**: Uses proper HTML5 semantic elements (`<main>`, `<section>`)
- **ARIA Labels**: All interactive elements have descriptive `aria-label` attributes
- **Role Attributes**: Canvas has `role="application"` to indicate it's an interactive game
- **Live Regions**: Score displays and game instructions use `aria-live="polite"` for dynamic updates

#### Screen Reader Announcements
The page announces important events to screen readers:
- Game loading and game type
- Score updates (via `aria-live` regions)
- Game over states with final scores
- Victory conditions
- Game restarts

#### Implementation
```javascript
window.announceToScreenReader(message)
```
This function creates temporary live regions to announce important game events without interrupting the user's flow.

### 2. Keyboard Navigation

#### Full Keyboard Support
- All interactive elements are keyboard accessible
- Tab key navigates through all controls
- Enter/Space activates buttons
- Canvas receives focus for game controls

#### Visual Focus Indicators
- **Buttons**: 3px white outline with 2px offset
- **Links**: 3px white outline with 2px offset
- **Canvas**: 3px white outline with 4px offset
- High contrast focus indicators ensure visibility

#### Game Controls
- Arrow keys for directional control (Snake, Breakout, Pong, Space Invaders)
- Spacebar for actions (Flappy Bird, Space Invaders shooting)
- Click/tap support maintained for all games

### 3. Color and Contrast

#### High Contrast
- **Text on Background**: White text (#ffffff) on purple gradient meets WCAG AA contrast ratio
- **Focus Indicators**: White outlines on purple background provide clear visual feedback
- **Game Elements**: Color is not the only means of conveying information

#### Color Scheme
- Primary: `#6364FF` (Mastodon purple)
- Secondary: `#563acc` (Darker purple)
- Text: `#ffffff` (White)
- Accents: `#ff006e` (Pink/red for important elements)

### 4. Text and Typography

#### Readable Fonts
- System font stack for optimal readability
- Minimum font size: 0.9rem (14.4px at default settings)
- Body text: 1.1rem (17.6px)
- Headings properly sized and hierarchical

#### Proper Heading Structure
- `<h1>`: Page title - "mstdn.ca is temporarily down"
- `<h2>`: Game title (dynamically updated)
- Logical heading hierarchy maintained

### 5. Mobile and Touch Accessibility

#### Responsive Design
- Viewport meta tag ensures proper scaling
- Touch targets are adequately sized (minimum 44x44px for buttons)
- Content reflows properly on mobile devices

#### Touch Support
- Click events work for touch devices
- Games playable with touch where appropriate (Memory Match, Flappy Bird)

### 6. Cognitive Accessibility

#### Clear Instructions
- Each game includes clear, concise instructions
- Controls are explicitly stated
- Goals are clearly communicated

#### Predictable Behavior
- Consistent button placement
- Clear action labels
- No unexpected changes of context

#### Error Prevention
- "Restart Game" vs "Try Another Game" clearly differentiated
- External links indicate they open in new tab

### 7. Additional Features

#### Meta Information
- Proper page title
- Meta description for search engines and assistive technologies
- Language attribute set to English (`lang="en"`)

#### Link Safety
- External links use `rel="noopener noreferrer"` for security
- Links indicate when they open in new tabs
- Descriptive link text (not "click here")

## Screen Reader Testing

### Recommended Screen Readers
- **Windows**: NVDA (free), JAWS
- **macOS**: VoiceOver (built-in)
- **Linux**: Orca
- **Mobile**: TalkBack (Android), VoiceOver (iOS)

### Testing Checklist
- [ ] All text content is read correctly
- [ ] Navigation order is logical
- [ ] Interactive elements are announced properly
- [ ] Game state changes are announced
- [ ] Live regions update appropriately
- [ ] Focus indicators are visible
- [ ] Skip link works correctly

## Keyboard Testing

### Test All Interactions
1. **Tab Navigation**
   - Tab through all interactive elements
   - Verify focus order is logical
   - Ensure all elements are reachable

2. **Keyboard Controls**
   - Test all game controls with keyboard
   - Verify buttons activate with Enter/Space
   - Ensure no keyboard traps

3. **Focus Visibility**
   - Confirm focus indicators are clearly visible
   - Check contrast of focus indicators
   - Verify focus never gets lost

## Browser Compatibility

Tested and optimized for:
- Chrome/Chromium (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Known Limitations

1. **Canvas Games**:
   - Games use canvas which has limited native accessibility
   - We've mitigated this with ARIA labels and screen reader announcements
   - Some screen readers may have varying levels of support for canvas interactions

2. **Animation**:
   - Games include animated content
   - Consider adding a "reduce motion" preference in future updates for users with vestibular disorders

3. **Audio**:
   - Currently no sound effects
   - If audio is added in the future, include visual alternatives and mute controls

## Future Improvements

Potential enhancements for even better accessibility:

1. **Preferences**
   - Add user preference for reduced motion
   - Allow users to adjust game speed
   - Color theme options for color blind users

2. **Alternative Formats**
   - Consider text-only version of games
   - Add audio cues for game events
   - Haptic feedback for mobile devices

3. **Enhanced Announcements**
   - More granular score announcements
   - Periodic position/status updates during gameplay
   - Customizable announcement verbosity

4. **Internationalization**
   - Multi-language support
   - Proper language attributes for translated content

## Reporting Accessibility Issues

If you encounter any accessibility barriers while using this page, please report them so we can improve. Include:
- Your assistive technology (name and version)
- Your browser (name and version)
- Description of the issue
- Steps to reproduce

## Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Keyboard Accessibility](https://webaim.org/techniques/keyboard/)

## Compliance Statement

This maintenance page strives to meet WCAG 2.1 Level AA standards. We are committed to making our content accessible to all users and welcome feedback for continuous improvement.

**Last Updated**: 2026-02-12
