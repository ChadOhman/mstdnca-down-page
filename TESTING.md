# Testing Checklist for Maintenance Page

## Pre-Deployment Testing

### Visual Testing
- [ ] Open index.html in a web browser
- [ ] Verify the page loads without errors
- [ ] Check that the Mastodon purple theme is visible
- [ ] Verify the mastodon emoji (🦣) displays correctly
- [ ] Check that the heading "mstdn.ca is temporarily down" is visible
- [ ] Verify the "Check Status Updates" link is present and clickable
- [ ] Confirm the link points to https://status.mstdn.ca

### Game Testing

#### Test 1: Snake
- [ ] Refresh page until Snake game loads
- [ ] Verify game canvas renders
- [ ] Press arrow keys to move the snake
- [ ] Verify snake moves in the correct direction
- [ ] Check that food appears on the board
- [ ] Eat food and verify score increases
- [ ] Hit a wall or self and verify "Game Over" appears
- [ ] Click "Restart Game" and verify it restarts

#### Test 2: Pong
- [ ] Refresh page until Pong loads
- [ ] Verify two paddles and ball are visible
- [ ] Press W/S keys to move left paddle
- [ ] Press Up/Down arrows to move right paddle
- [ ] Verify ball bounces off paddles
- [ ] Verify ball bounces off top/bottom walls
- [ ] Check that score updates when ball passes paddles
- [ ] Click "Restart Game" and verify it restarts

#### Test 3: Breakout
- [ ] Refresh page until Breakout loads
- [ ] Verify paddle and bricks are visible
- [ ] Use left/right arrows to move paddle
- [ ] Verify ball bounces off paddle
- [ ] Hit a brick and verify it disappears
- [ ] Check that score increases when bricks are destroyed
- [ ] Let ball fall and verify "Game Over" appears
- [ ] Click "Restart Game" and verify it restarts

#### Test 4: Flappy Bird
- [ ] Refresh page until Flappy Bird loads
- [ ] Verify bird and pipes are visible
- [ ] Press spacebar or click to make bird jump
- [ ] Verify gravity pulls bird down
- [ ] Verify pipes scroll from right to left
- [ ] Hit a pipe and verify "Game Over" appears
- [ ] Check that score increases as you pass pipes
- [ ] Click "Restart Game" and verify it restarts

#### Test 5: Space Invaders
- [ ] Refresh page until Space Invaders loads
- [ ] Verify player ship and alien enemies are visible
- [ ] Use left/right arrows to move ship
- [ ] Press spacebar to shoot
- [ ] Verify bullets hit and destroy aliens
- [ ] Verify aliens shoot back
- [ ] Check that aliens move side to side and down
- [ ] Destroy all aliens or get hit and verify game ends
- [ ] Click "Restart Game" and verify it restarts

#### Test 6: Memory Match
- [ ] Refresh page until Memory Match loads
- [ ] Verify all 16 cards are visible
- [ ] Click a card and verify it flips
- [ ] Click another card and verify it flips
- [ ] Match two cards and verify they stay flipped
- [ ] Try two non-matching cards and verify they flip back
- [ ] Check that moves counter increases
- [ ] Match all 8 pairs and verify "You Win" appears
- [ ] Click "Restart Game" and verify it restarts

### Cross-Browser Testing
- [ ] Test in Chrome/Chromium
- [ ] Test in Firefox
- [ ] Test in Safari (if available)
- [ ] Test in Edge

### Mobile Testing
- [ ] Open page on mobile device
- [ ] Verify layout is responsive
- [ ] Test touch controls (for games that support clicking)
- [ ] Verify all games are playable on mobile

### Button Testing
- [ ] Click "Restart Game" button for each game
- [ ] Click "Try Another Game" button and verify page refreshes
- [ ] Verify random game selection works (get different games)

### Link Testing
- [ ] Click the "Check Status Updates →" link
- [ ] Verify it opens https://status.mstdn.ca in a new tab

## Nginx Deployment Testing

### Local Testing
- [ ] Place index.html in /var/www/maintenance/
- [ ] Configure nginx with provided config
- [ ] Run `sudo nginx -t` to test configuration
- [ ] Access http://localhost and verify page loads
- [ ] Check HTTP status code is 503

### Production Testing
- [ ] Access https://mstdn.ca
- [ ] Verify maintenance page displays
- [ ] Check HTTP status code: `curl -I https://mstdn.ca`
- [ ] Verify "503 Service Unavailable" status
- [ ] Check for "Retry-After" header
- [ ] Verify SSL/HTTPS works correctly
- [ ] Test from different devices and networks

### Header Testing
```bash
# Run this command to verify headers
curl -I https://mstdn.ca

# Expected headers:
# HTTP/1.1 503 Service Unavailable
# Retry-After: 3600
# Cache-Control: no-cache, no-store, must-revalidate
```

## Performance Testing
- [ ] Check page load time (should be very fast)
- [ ] Verify no external dependencies are loaded
- [ ] Check that games run smoothly (60fps for most games)
- [ ] Test with browser dev tools open (check for errors)

## Accessibility Testing
- [ ] Check keyboard navigation works
- [ ] Verify color contrast is sufficient
- [ ] Test with screen reader (optional)

## Issues Found

Document any issues found during testing:

| Issue | Game/Section | Severity | Status |
|-------|-------------|----------|--------|
| | | | |

## Sign-Off

- [ ] All critical tests passed
- [ ] No JavaScript errors in console
- [ ] Nginx configuration validated
- [ ] Ready for production deployment

**Tested by:** _________________
**Date:** _________________
**Browser/OS:** _________________
