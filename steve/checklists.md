# Steve — Checklists

3 mandatory checklists for design quality validation. Use in Audit mode.

---

## A. Accessibility Checklist (12 items)

Can everyone use this interface?

- [ ] **Color contrast — normal text** — 4.5:1 minimum ratio for text smaller than 18px (or 14px bold) against its background
- [ ] **Color contrast — large text** — 3:1 minimum ratio for text 18px+ (or 14px+ bold) against its background
- [ ] **Keyboard navigation** — All interactive elements (buttons, links, inputs, dropdowns) reachable and operable via Tab, Enter, Space, and Arrow keys
- [ ] **Focus indicators visible** — Every focusable element shows a visible focus ring or outline with at least 3:1 contrast against adjacent colors
- [ ] **ARIA labels on icon buttons** — Buttons and links containing only icons have `aria-label`, `aria-labelledby`, or visually hidden text
- [ ] **Touch targets 48x48 minimum** — All interactive elements have at least 48x48px hit area (including padding), with adequate spacing between targets
- [ ] **Heading hierarchy** — Headings follow logical order (h1 → h2 → h3) without skipping levels; exactly one h1 per page
- [ ] **Alt text on images** — Informative images have descriptive `alt` text; decorative images have `alt=""` or `aria-hidden="true"`
- [ ] **Form labels associated** — Every form input has a visible `<label>` element linked via `for`/`id` or wrapping; no placeholder-only labels
- [ ] **Error messages linked to fields** — Validation errors use `aria-describedby` to associate error text with the input field, not just displayed nearby
- [ ] **Reduced motion respected** — Animations and transitions check `prefers-reduced-motion` and provide static alternatives
- [ ] **Skip navigation link** — A "Skip to main content" link is the first focusable element on the page, visible on focus

---

## B. Heuristics Checklist (10 items)

Nielsen's 10 usability heuristics — what to check and what commonly goes wrong.

- [ ] **H1: Visibility of system status** — Check: loading spinners, progress indicators, active nav states, save confirmations. Common violation: form submits with no feedback, user doesn't know if action worked.

- [ ] **H2: Match between system and real world** — Check: labels, terminology, icon metaphors, information order. Common violation: developer jargon in UI ("null", "undefined", "404"), unfamiliar icons.

- [ ] **H3: User control and freedom** — Check: undo, cancel buttons, back navigation, modal dismiss. Common violation: no way to undo delete, modal with no close button, multi-step form with no back.

- [ ] **H4: Consistency and standards** — Check: button placement, action naming, icon usage, interaction patterns. Common violation: "Save" button on left in one form, right in another; mixing "Delete" and "Remove" labels.

- [ ] **H5: Error prevention** — Check: confirmation dialogs, input constraints, disabled states, validation timing. Common violation: delete without confirmation, no input validation until submit, allowing invalid date ranges.

- [ ] **H6: Recognition rather than recall** — Check: visible labels, contextual help, recently used items, autocomplete. Common violation: dropdown with codes instead of names, requiring users to remember IDs.

- [ ] **H7: Flexibility and efficiency of use** — Check: keyboard shortcuts, bulk actions, saved preferences, search. Common violation: no keyboard shortcuts for frequent actions, no bulk select/delete.

- [ ] **H8: Aesthetic and minimalist design** — Check: information density, visual hierarchy, unused elements. Common violation: too many columns in a table, information overload on dashboard, competing CTAs.

- [ ] **H9: Help users recover from errors** — Check: error message clarity, recovery suggestions, inline vs toast errors. Common violation: "An error occurred" with no details, error toast that disappears too quickly.

- [ ] **H10: Help and documentation** — Check: tooltips, onboarding, help links, contextual guidance. Common violation: complex feature with no explanation, abbreviations without tooltips.

---

## C. Responsive Checklist (8 items)

Does the design work on every screen?

- [ ] **Mobile-first breakpoints** — Layout uses min-width breakpoints (mobile → tablet → desktop), not max-width; base styles target mobile
- [ ] **Touch targets adequate on mobile** — Buttons and interactive elements are at least 48x48px on mobile; no tiny links or icons that require precision tapping
- [ ] **Font scales appropriately** — Body text is minimum 16px on mobile (prevents iOS zoom); headings scale down proportionally; no text smaller than 14px
- [ ] **Images responsive** — Images use `srcset`, `<picture>`, or CSS `object-fit` to serve appropriate sizes; no fixed-width images that overflow on mobile
- [ ] **No horizontal scroll** — Content fits within viewport at all breakpoints; no elements cause horizontal overflow; tables convert to card layout or scroll within container
- [ ] **Safe areas respected** — Content avoids notch, Dynamic Island, home indicator, and status bar areas; uses `env(safe-area-inset-*)` where applicable
- [ ] **Tables converted on mobile** — Data tables either become stackable cards, use horizontal scroll containers, or hide non-essential columns on small screens
- [ ] **Navigation adapts** — Desktop navigation transforms to hamburger menu, bottom tabs, or slide-out drawer on mobile; all nav items accessible on all breakpoints

---

## D. DRY Style Patterns Checklist (5 items)

Are repeated UI patterns centralized for single-point-of-change?

- [ ] **Repeated Tailwind combos** — Same combination of 3+ Tailwind classes appearing in 3+ files should be extracted to a shared CSS class via `@apply` in a central stylesheet
- [ ] **Inconsistent border/divider colors** — Same semantic divider (row separator, section break) uses different color values across files (e.g., `border-slate-600` in one file, `border-slate-700/30` in another)
- [ ] **Duplicated table header styling** — Table headers (`<tr>` or `<div>` acting as headers) with identical text styling + border should use a shared class
- [ ] **Scattered status/type colors** — Same semantic colors (e.g., receiving=green, withdrawal=amber) hardcoded in multiple files instead of centralized in a composable or CSS variables
- [ ] **Repeated structural patterns** — Same HTML structure (e.g., label + required asterisk, dialog footer buttons) copied across 4+ files should be a shared component
