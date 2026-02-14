# Chat Widget Typography Improvements

## Goal

Make the chat widget feel like a polished, real chat application—not a clone of any specific product.

## Current Issues

1. **Avatar/username misalignment** - Username text sits a few pixels lower than avatar, looks unpolished
2. **Square avatars** - Profile photos should be rounded circles
3. **Code blocks using raw CSS** - Should use highlight.js (hljs) for proper syntax highlighting
4. **Inconsistent font sizing** - Mix of sizes without clear hierarchy
5. **Line height issues** - Message text feels cramped in multi-line messages

## Proposed Fixes

### 1. Avatar & Username Alignment
- Use `items-start` on the message row flex container
- Add `mt-0.5` or similar micro-adjustment to align avatar top with text baseline
- Or use `items-center` on just the username/timestamp row
- Make avatars fully rounded: `rounded-full`

### 2. Username Treatment
- Keep `font-semibold` (600) — bold is too heavy
- Tighten letter-spacing slightly: `tracking-[-0.01em]`
- Color: `#1d1c1d` (near-black, high contrast)

### 3. Timestamp Styling
- Size: `text-[12px]`
- Color: `#616061` (muted gray)
- Ensure baseline alignment with username

### 4. Message Body Text
- Line-height: `leading-[1.46]` for comfortable reading
- Size: 15px
- Color: `#1d1c1d`

### 5. Code Block Improvements
- **Use highlight.js** for syntax highlighting instead of manual CSS classes
- Font: `font-mono text-[13px]`
- Background: `#f8f8f8` or similar light gray
- Line-height: `leading-[1.5]`
- Border-radius: `rounded-md`

### 6. Profile Photos
- Must be `rounded-full` (circular)
- Consistent size: `w-9 h-9` or `w-10 h-10`

## Implementation Priority

1. **High**: Avatar/name alignment fix, rounded avatars
2. **High**: Integrate highlight.js for code blocks
3. **Medium**: Typography refinements (line-height, letter-spacing)
4. **Low**: Color fine-tuning with hex values

## Color Palette (hex, not Tailwind)

- Primary text: `#1d1c1d`
- Secondary text (timestamps): `#616061`
- Muted text: `#868686`
- Code background: `#f8f8f8`
- Code border: `#e1e1e1`
- Link color: `#1264a3`
- Mention highlight: `#e8f5fa`