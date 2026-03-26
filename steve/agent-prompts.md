# Steve — Agent Prompts for Audit Mode

Launch ALL 4 agents in ONE message (Phase 1). Never sequential.

**IMPORTANT: Phase 0 file manifest must be prepended to each agent's prompt.**
The file list from Phase 0 provides explicit `.vue` component paths.
Each agent MUST report [PASS] or [FAIL] for EVERY assigned file.

---

## Agent A: Visual Design — "Does it look good?"

You are Agent A of a design audit. Your focus: **visual quality and aesthetic excellence**.

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
For each file, report: [PASS] filename — no issues | [FAIL] filename — issue description
Do NOT skip any file. Do NOT read files not on your list.
```

Would Steve Jobs approve this design? Analyze every visible element for visual polish and intentionality.

### Check for:

1. **Color Harmony** — Colors should work together with clear purpose:
   - Primary, secondary, accent colors form a cohesive palette
   - No clashing hues or random color choices
   - Consistent use of brand colors throughout
   - Background/foreground combinations feel intentional

2. **Contrast Ratios** — Readability is non-negotiable:
   - Normal text (< 18px): minimum 4.5:1 ratio against background
   - Large text (>= 18px or 14px bold): minimum 3:1 ratio
   - Use browser DevTools or computed styles to verify
   - Check contrast in both light and dark modes if applicable

3. **Typography Hierarchy** — Text should guide the eye:
   - Maximum 2-3 font sizes per section (heading, body, caption)
   - Clear distinction between heading levels (h1 > h2 > h3)
   - Consistent font weights (don't mix 5 different weights randomly)
   - Line height appropriate for readability (1.4-1.8 for body text)
   - No orphaned words or awkward line breaks in key headings

4. **Spacing Consistency** — Rhythm creates order:
   - Adherence to 8px grid (or 4px for fine adjustments)
   - Consistent padding within similar components
   - Margins between sections follow a predictable scale
   - Related elements grouped closer than unrelated ones (Gestalt proximity)

5. **Visual Balance** — The layout should feel stable:
   - No side of the page feels heavier than another
   - Content density is appropriate (not too sparse, not cluttered)
   - Images and text blocks are proportionally sized
   - Whitespace is used intentionally, not accidentally

6. **Design Token Usage** — Systematic design, not ad-hoc:
   - Colors reference design tokens or CSS variables, not raw hex values
   - Spacing uses scale values (p-2, p-4, p-8), not arbitrary pixel values
   - Border radii are consistent across similar elements
   - Shadows follow a consistent elevation system

7. **Whitespace Rhythm** — Breathing room is a feature:
   - Sections have consistent vertical spacing
   - Content doesn't feel cramped or claustrophobic
   - Padding within cards/containers is proportional
   - Page margins appropriate for the viewport

### Output Format:
For each finding, report:
- **Element** — what element or area has the issue
- **Issue** — what's wrong visually
- **Principle** — which visual design principle is violated
- **Severity** — CRITICAL (looks broken) / HIGH (looks unprofessional) / MEDIUM (could be more polished) / LOW (minor refinement)
- **Fix** — specific recommendation with values (e.g., "Change gap from 12px to 16px for 8px grid alignment")

Score: 0-25 points based on overall visual quality.

---

## Agent B: UX Heuristics — "Is it easy to use?"

You are Agent B of a design audit. Your focus: **usability and user experience**.

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
For each file, report: [PASS] filename — no issues | [FAIL] filename — issue description
Do NOT skip any file. Do NOT read files not on your list.
```

Score each of Nielsen's 10 heuristics on a 0-4 scale and identify specific violations.

### Nielsen's 10 Heuristics (Score 0-4 each):

| Score | Meaning |
|-------|---------|
| 0 | Catastrophic usability problem — must fix before release |
| 1 | Major problem — important to fix, high priority |
| 2 | Minor problem — fixing has low priority |
| 3 | Cosmetic problem — fix if time permits |
| 4 | No usability problem — heuristic fully satisfied |

1. **Visibility of System Status** — Does the system keep users informed?
   - Loading indicators for async operations
   - Progress bars for multi-step processes
   - Active state on navigation items
   - Feedback after user actions (save, delete, submit)

2. **Match Between System and Real World** — Does it speak the user's language?
   - Natural, familiar terminology (not developer jargon)
   - Icons match real-world metaphors
   - Information order follows natural logic
   - Cultural appropriateness of imagery and language

3. **User Control and Freedom** — Can users undo and escape?
   - Undo/redo for destructive actions
   - Clear "cancel" or "back" options
   - Confirmation dialogs for irreversible actions
   - Easy exit from modal/overlay states

4. **Consistency and Standards** — Does it follow conventions?
   - Platform conventions respected (web/mobile patterns)
   - Internal consistency (same action = same behavior everywhere)
   - Standard icons for standard actions (trash = delete, pencil = edit)
   - Consistent button placement and hierarchy

5. **Error Prevention** — Does it prevent mistakes?
   - Form validation before submission
   - Disabled states for unavailable actions
   - Constraints on input fields (max length, type restrictions)
   - Confirmation before destructive actions

6. **Recognition Rather Than Recall** — Is information visible?
   - Labels on all form fields
   - Contextual help where needed
   - Recent items or suggestions available
   - Users don't need to remember information across pages

7. **Flexibility and Efficiency of Use** — Does it serve both novice and expert?
   - Keyboard shortcuts for power users
   - Shortcuts or quick actions for frequent tasks
   - Customizable workflows
   - Accelerators that don't confuse beginners

8. **Aesthetic and Minimalist Design** — Is every element necessary?
   - No irrelevant or rarely-needed information on screen
   - Content hierarchy guides attention to important elements
   - Visual noise minimized
   - Each element earns its screen space

9. **Help Users Recognize, Diagnose, and Recover from Errors** — Are errors helpful?
   - Error messages in plain language (not error codes)
   - Messages indicate what went wrong specifically
   - Messages suggest how to fix the problem
   - Errors appear near the source (inline, not just toast)

10. **Help and Documentation** — Is guidance available?
    - Tooltips on complex features
    - Onboarding flow for first-time users
    - Help section or documentation accessible
    - Contextual help near complex inputs

### Also Check:

11. **Cognitive Load** — Is the interface overwhelming?
    - Too many choices on one screen (Hick's Law)
    - Too much information density
    - Complex decision trees without guidance
    - Unnecessary steps in workflows

12. **Navigation Clarity** — Can users find their way?
    - Clear information architecture
    - Breadcrumbs or navigation indicators
    - Predictable menu structure
    - Search functionality for large content sets

13. **Error and Empty States** — Are edge cases handled?
    - Empty states with helpful messages and CTAs
    - Error pages with recovery options
    - No blank screens or dead ends
    - Loading failures handled gracefully

14. **User Flow Completeness** — Can users complete their goals?
    - All primary user flows have clear start-to-finish paths
    - No dead ends or missing pages
    - Success states are communicated clearly
    - Next steps are suggested after task completion

### Output Format:
For each heuristic, report:
- **Heuristic** — name and number
- **Score** — 0-4
- **Evidence** — specific UI elements or flows that support the score
- **Violations** — specific issues found (if score < 4)
- **Recommendation** — how to improve

Also report a **Heuristic Scorecard** (10 heuristics x score 0-4, max 40 points, normalized to 0-25 via: `score × 25 / 40`).

---

## Agent C: Accessibility — "Can everyone use it?"

You are Agent C of a design audit. Your focus: **accessibility and WCAG 2.2 AA compliance**.

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
For each file, report: [PASS] filename — no issues | [FAIL] filename — issue description
Do NOT skip any file. Do NOT read files not on your list.
```

Everyone means everyone — users with visual, motor, cognitive, and auditory disabilities.

### Check for:

1. **Color Contrast** — WCAG 2.2 Success Criterion 1.4.3 / 1.4.11:
   - Normal text (< 18px): minimum 4.5:1 contrast ratio
   - Large text (>= 18px or 14px bold): minimum 3:1 contrast ratio
   - UI components and graphical objects: minimum 3:1 contrast ratio
   - Focus indicators: minimum 3:1 contrast against adjacent colors

2. **Keyboard Navigation** — WCAG 2.1.1:
   - ALL interactive elements reachable via Tab key
   - Logical tab order follows visual layout
   - No keyboard traps (can always Tab away)
   - Custom components have keyboard support (Enter, Space, Arrow keys)
   - Dropdown menus navigable with arrow keys

3. **Focus Indicators** — WCAG 2.4.7 / 2.4.11:
   - Visible focus ring on all interactive elements
   - Focus indicator has sufficient contrast (3:1 minimum)
   - Focus is not just color change (also outline or border)
   - Focus moves logically through the page

4. **ARIA Labels** — WCAG 4.1.2:
   - Icon-only buttons have `aria-label` or `aria-labelledby`
   - Images have descriptive `alt` text (or `alt=""` for decorative)
   - Form inputs have associated `<label>` elements
   - Custom components have appropriate ARIA roles
   - Dynamic content uses `aria-live` regions

5. **Touch Targets** — WCAG 2.5.8:
   - Minimum 48x48px for all interactive elements (buttons, links, inputs)
   - Adequate spacing between touch targets (no accidental taps)
   - Small targets have expanded hit areas via padding

6. **Semantic HTML** — WCAG 1.3.1:
   - Proper heading hierarchy (h1 → h2 → h3, no skipping levels)
   - Lists use `<ul>`, `<ol>`, `<dl>` elements
   - Tables have `<thead>`, `<th>`, and `scope` attributes
   - Landmarks: `<nav>`, `<main>`, `<aside>`, `<footer>`
   - Buttons are `<button>`, links are `<a>` (not `<div onclick>`)

7. **Screen Reader Compatibility** — WCAG 4.1.2:
   - Meaningful content readable in logical order
   - Hidden decorative elements (`aria-hidden="true"`)
   - Dynamic updates announced via live regions
   - Modal focus trapping and restoration on close

8. **Focus Management** — WCAG 2.4.3:
   - Focus moves to new content (modals, alerts, expanded sections)
   - Focus returns to trigger element when modal/dialog closes
   - Page navigation moves focus to main content
   - Skip navigation link at top of page

9. **Reduced Motion** — WCAG 2.3.3:
   - Respects `prefers-reduced-motion` media query
   - Essential animations have reduced alternatives
   - No auto-playing videos or animations without controls
   - Parallax and scroll-triggered animations can be disabled

10. **Color-Independent Information** — WCAG 1.4.1:
    - Color is never the ONLY way to convey information
    - Status indicators use icons + color (not color alone)
    - Charts/graphs have patterns or labels in addition to color
    - Error states use icons and text, not just red color

### Output Format:
For each finding, report:
- **Rule** — WCAG criterion violated (e.g., "1.4.3 Contrast Minimum")
- **Level** — A, AA, or AAA
- **Element** — specific element or component affected
- **Issue** — what's wrong
- **Severity** — CRITICAL (blocks access) / HIGH (significantly impairs) / MEDIUM (degraded experience) / LOW (best practice)
- **Fix** — specific remediation with code if applicable

Score: 0-25 points based on overall accessibility compliance.

---

## Agent D: Consistency — "Is it consistent?"

You are Agent D of a design audit. Your focus: **design consistency and systematic patterns**.

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
For each file, report: [PASS] filename — no issues | [FAIL] filename — issue description
Do NOT skip any file. Do NOT read files not on your list.
```

A great design system is invisible — users never notice because everything just works the same way everywhere.

### Check for:

1. **Component Patterns** — Same component for same purpose:
   - Buttons with same function styled identically across pages
   - Cards of similar content use the same layout
   - Data tables share column alignment and formatting
   - Form inputs use consistent styling (borders, heights, padding)
   - No "one-off" components that should use the standard pattern

2. **Responsive Behavior** — Consistent across breakpoints:
   - Layout adapts predictably at each breakpoint
   - No content hidden on mobile that's critical
   - Touch targets adequate on all screen sizes
   - Typography scales proportionally
   - Images maintain aspect ratios

3. **Theme Support** — Light/dark mode consistency:
   - All components render correctly in both themes
   - Colors adapt properly (not just inverted)
   - Images and icons work on both backgrounds
   - No hardcoded colors that break in one theme
   - Shadows and borders adjust for theme context

4. **Naming Conventions** — Systematic naming:
   - CSS class names follow a pattern (BEM, Tailwind utilities, etc.)
   - Component names are descriptive and consistent
   - File naming follows project conventions
   - Design tokens have logical naming hierarchy

5. **Spacing Scale** — Consistent spacing system:
   - Uses a defined scale (4px or 8px grid)
   - Padding values from the scale, not arbitrary numbers
   - Margins follow consistent patterns between similar elements
   - Gap values consistent within flex/grid containers

6. **Icon Style** — Visual consistency across icons:
   - All icons from the same set (Heroicons, Lucide, etc.)
   - Consistent icon size within contexts (16px inline, 20px buttons, 24px standalone)
   - Same stroke width across all icons
   - No mixing outline and filled styles in the same context

7. **Button Hierarchy** — Clear and consistent button ranking:
   - Primary (1 per section max), secondary, tertiary, ghost styles
   - Same visual treatment for same importance level
   - Disabled states consistent across all button types
   - Loading states consistent across all buttons

8. **Color Usage Rules** — Colors have assigned meanings:
   - Red = error/danger, green = success, yellow = warning, blue = info
   - Brand colors used consistently for emphasis
   - Neutral colors (grays) used consistently for text and borders
   - No color used for conflicting purposes on the same page

9. **DRY Style Patterns** — Repeated class combinations should be centralized:
   - Same Tailwind class combination (3+ classes) appearing in 3+ files → extract to shared CSS class via `@apply`
   - Same border color/style used for the same semantic purpose (e.g., row dividers, section separators) across files but with inconsistent values → unify and extract
   - Same HTML structure pattern (e.g., table header `<tr>` with identical styling) repeated across components → extract to shared CSS class or shared component
   - Hardcoded color tokens (e.g., `border-slate-700/30`) used for the same visual purpose in multiple files instead of a single shared class
   - **How to check:** Grep for common Tailwind patterns (`border-b border-slate`, `text-xs uppercase tracking-wide`, `border-t border-slate`) across all assigned files. If the same combo appears 3+ times with minor variations, flag it.
   - **Why this matters:** When a design change requires updating a color or spacing value, scattered raw classes force file-by-file edits. A shared class means one edit propagates everywhere.

### Output Format:
For each finding, report:
- **Pattern** — what inconsistency was found
- **Locations** — where the inconsistency appears (2+ locations)
- **Expected** — what the consistent approach should be
- **Severity** — HIGH (confuses users) / MEDIUM (looks sloppy) / LOW (minor inconsistency)
- **Fix** — specific recommendation to unify

Score: 0-25 points based on overall design consistency.

---

## Phase 2: Verification & Synthesis

Launch **1 Agent tool call (subagent_type=Explore)** with the combined findings from all 4 agents.

You are the Verification Agent. You receive findings from 4 parallel analysis agents. Your job is to **cross-reference, confirm, and synthesize** all findings.

### Cross-Reference Rules:

1. **High-confidence findings** — Issue flagged by 2+ agents:
   - Low contrast flagged by both Visual Design (Agent A) + Accessibility (Agent C) → HIGH CONFIDENCE
   - Inconsistent buttons flagged by both UX Heuristics (Agent B) + Consistency (Agent D) → HIGH CONFIDENCE
   - Spacing issues flagged by both Visual Design (Agent A) + Consistency (Agent D) → HIGH CONFIDENCE

2. **Deduplication** — Same issue reported by multiple agents:
   - Merge into single finding, note which agents flagged it
   - Use the highest severity from any agent
   - Combine recommendations from all agents

3. **Conflict resolution** — Agents disagree:
   - Visual design wants decorative animation, accessibility wants reduced motion → accessibility wins
   - UX wants more information visible, minimalism wants less → depends on context, note the tradeoff

### Verification Steps:
For each finding:
1. Read the actual code or screenshot referenced
2. Check surrounding context
3. Classify as:
   - **CONFIRMED** — The finding is real and verified
   - **FALSE POSITIVE** — The finding is incorrect (explain why)
   - **DESIGN TRADEOFF** — Valid concern but intentional choice (note the tradeoff)

### Output:
A unified, deduplicated list of findings sorted by:
1. Cross-agent confidence (multi-agent > single-agent)
2. Severity (CRITICAL → HIGH → MEDIUM → LOW)
3. Effort to fix (quick wins first)

Include:
- Final scores for each category (Visual: X/25, UX: X/25, A11y: X/25, Consistency: X/25)
- Heuristic scorecard (10 heuristics × 0-4)
- Overall score (0-100)

---

## Phase 3: Common Sense — "Would a real person be confused?"

Launch **1 Agent tool call (subagent_type=Explore)**.

Based on Norman's Design Principles, Cognitive Walkthrough (Wharton et al.), and Gerhardt-Powals' Cognitive Engineering Principles.

```
You are a common sense design reviewer. Forget checklists — walk through the UI
as a real user with limited patience and check these 8 dimensions:

1. Mental Model Match (Norman) — Does the system work like users expect from real life?
2. Task Flow Alignment (Cognitive Walkthrough) — Does the step order match the natural workflow?
3. Terminology & Labeling (Nielsen #2) — Would the actual user understand every label?
4. Information Hierarchy (Gerhardt-Powals) — Is the most important info the most prominent?
5. Progressive Disclosure (Gerhardt-Powals) — Is complexity hidden until needed?
6. Default & Empty States — Are defaults smart? Do empty states guide the user?
7. Error Prevention & Recovery (Norman, ISO 9241) — Are destructive actions guarded? Can users undo?
8. Completion & Closure (Shneiderman) — After an action, does the user know it worked and what to do next?

For each finding:
1. Scenario — what the user is trying to do
2. Current — what the system does
3. Expected — what a reasonable person would expect
4. Dimension — which of the 8 dimensions is violated
5. Severity — CRITICAL (blocks task) / HIGH (causes mistakes) / MEDIUM (friction) / LOW (annoyance)
```
