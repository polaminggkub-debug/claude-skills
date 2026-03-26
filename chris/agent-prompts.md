# Chris — Agent Prompts for Audit Mode

Launch ALL 5 agents in ONE message (Phase 1). Never sequential.

**IMPORTANT: Phase 0 file manifest must be prepended to each agent's prompt.**

---

## Agent A: Validity — "Are tests testing real things?"

You are Agent A of a test quality audit. Your focus: **test validity**.

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
For each file, report: [PASS] filename — no issues | [FAIL] filename — issue description
Do NOT skip any file. Do NOT read files not on your list.
```

For each test, answer:
> "If I break the logic this test covers, will this test fail?"

### Check for:

1. **Circular tests** — Seed data X → query it back → assert X. This tests storage, not logic.
2. **Garbage assertions** — `toBeVisible()`, `rows.length > 0`, `toBeTruthy()` — prove existence, not correctness.
3. **Spec-derived values** — Expected values from business rules, not from running the system.
4. **Logic in tests** — No `if/else`, `for`, `try/catch` in test code.
5. **Weakened tests** — Tests modified to pass despite known bugs.
6. **Missing happy path** — Unit has no test for the basic expected flow.

### Output Format:
- **File:line** — exact location
- **Pattern** — which anti-pattern
- **Evidence** — the specific code
- **Severity** — CRITICAL / HIGH / MEDIUM

---

## Agent B: ROI & Trim — "Which tests are not worth their cost?"

You are Agent B of a test quality audit. Your focus: **identifying tests to REMOVE or DOWNGRADE**.

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
These are TEST files. For each test, evaluate its ROI.
```

**The goal is to SHRINK the test suite, not grow it.** Internal tools should have 20-30 E2E tests max.

### For each test file, classify every test as:

**KEEP** — This test:
- Tests a critical user flow that spans multiple pages
- Has caught (or would catch) a real bug
- Cannot be replaced by a DB guard or integration test
- Runs in < 10 seconds

**DOWNGRADE to integration** — This test:
- Tests business logic that doesn't need a browser
- Could be tested with direct DB queries (seed → run function → assert)
- Tests calculations, FIFO logic, stock math, status transitions

**REMOVE** — This test:
- Tests validation messages or toast text (changes frequently, low ROI)
- Tests that a button is disabled/enabled (UI state, not business logic)
- Tests CSS rendering or layout
- Duplicates another test's coverage
- Tests error paths that DB guards already prevent
- Tests framework behavior (Vue reactivity, PrimeVue components)
- Takes > 15 seconds for a trivial check

### Also identify:
- **Missing DB guards** — Where a CHECK constraint or trigger would replace 5+ E2E tests
- **Missing happy path tests** — Critical flows with no basic success test
- **Missing critical paths** — The ONE flow that has no test but would cause real damage

### Output Format:
For each test:
- **Test name** — the test title
- **Verdict** — KEEP / DOWNGRADE / REMOVE
- **Reason** — specific justification
- **Alternative** — if DOWNGRADE/REMOVE, what replaces it

---

## Agent C: Performance — "Are tests fast enough?"

You are Agent C of a test quality audit. Your focus: **test performance and reliability**.

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
For each file, report: [PASS] filename — no issues | [FAIL] filename — issue description
```

### Check for:

1. **waitForTimeout()** — Replace with condition-based waits.
2. **High timeouts** — `timeout > 5000` for routine operations = app bug, not test issue.
3. **Login reuse** — Use `storageState`, not UI login per test.
4. **Parallel readiness** — Can tests run with `fullyParallel: true`?
5. **Connection budget** — `workers × pool.max` vs DB limits.
6. **Heavy/Light split** — Long tests separated from fast tests?
7. **Total runtime** — Suite should complete in < 3 minutes. If not, what's the bottleneck?
8. **Seed data method** — Via API/DB (good) or via UI navigation (bad)?

Refer to `playwright-config.md` for expected configuration patterns.

### Output:
- **Issue** — what's slow
- **File:line** — location
- **Impact** — estimated time waste
- **Fix** — recommendation

---

## Agent D: Architecture & Testability — "Is the code designed in testable units?"

You are Agent D of a test quality audit. Your focus: **test architecture, maintainability, and testable design**.

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
For each file, report: [PASS] filename — no issues | [FAIL] filename — issue description
```

### Check for (Test Structure):

1. **Selectors** — `getByRole` > `getByLabel` > `getByText` > `getByTestId`. CSS selectors acceptable for framework components.
2. **File independence** — Each file runs in isolation without depending on other files.
3. **Reusable fixtures** — Common setup in shared helpers, not copy-pasted.
4. **AAA Pattern** — Arrange → Act → Assert with clear separation.
5. **Test naming** — Three-part format: `[unit] — [scenario] — [expected behavior]`

### Check for (Testable Architecture):

6. **Unit decomposition** — Is the source code divided into testable units with clear specs? Or is everything mixed in one big function/component?
7. **Thin orchestrators** — Are page components and store actions thin wiring, or do they contain business logic that should be extracted?
8. **Pure logic separation** — Is business logic (calculations, validations, transformations) separated from I/O (API calls, DB queries)?
9. **Spec clarity** — Can you write a one-sentence spec for each unit? If not, the unit is doing too much.
10. **Happy path coverage** — Does each identified unit have at least one happy path test?
11. **Test-level appropriateness** — Are E2E tests being used for things that could be unit/integration tests?
12. **Test code duplication** — Same mock setup, assertion sequences, or test data literals copy-pasted across 3+ files? → extract to shared test helpers/factories. Same render+interact+assert pattern repeated? → Page Object or shared test utility.

### Output:
- **Pattern** — which issue
- **File:line** — location
- **Recommendation** — specific fix

---

## Agent E: Coverage Gap — "What features exist but have NO test?"

You are Agent E of a test quality audit. Your focus: **finding features and user actions in source code that have ZERO test coverage**.

Unlike Agents A–D who analyze existing tests, you analyze **source code** to find what's MISSING from the test suite.

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
These are SOURCE files (components, composables, dialogs), NOT test files.
For each file, report: [PASS] filename — all actions tested | [GAP] filename — untested actions listed
Do NOT skip any file. Do NOT read files not on your list.
```

### Methodology:

**Step 1: Inventory every user action in source code**

For each Vue component / dialog / page, list ALL user-facing actions:
- Buttons (add, save, edit, cancel, delete, expand, collapse)
- Form fields (inputs, selects, dropdowns, date pickers)
- Validation rules (what blocks save? what shows errors?)
- Dialog flows (open → fill → save)
- Computed displays (percentages, totals, status badges)
- Conditional UI (fields that appear/disappear based on state)

For each composable / model, list ALL exported functions:
- CRUD operations (create, update, cancel, fetch)
- Validation functions
- Computed/derived values

**Step 2: Cross-reference with existing tests**

For each action found in Step 1, search the test files to determine:
- Is this action exercised in ANY E2E test? (button clicked, field filled, value asserted)
- Is the underlying logic covered by ANY unit test?
- Is the action tested via DB seeding only (not through UI)?

**Step 3: Classify each gap**

For untested actions, classify by risk:

| Risk | Criteria | Example |
|------|----------|---------|
| **CRITICAL** | Daily-use feature, data-writing action, no test at all | NG defect type entry, adjustment via UI |
| **HIGH** | Regular-use feature, tested via DB seed but NOT through UI | Adjustment completion (AC tests seed DB) |
| **MEDIUM** | Used weekly, has partial coverage | Edit record (only 1 of 6 tabs has edit test) |
| **LOW** | Rarely used, read-only, or cosmetic | Packaging summary display |

### Special attention:

1. **"Tested but not really" pattern** — A test MENTIONS a feature (opens the dialog) but never exercises the key action (never fills the critical field, never checks the critical value). This is worse than no test because it creates false confidence.

2. **Validation rules with no test** — If `canSave` checks 4 conditions but the test only triggers 2 of them, the other 2 can break silently.

3. **Conditional UI with no test** — Expandable sections, conditional fields, toggle-dependent layouts — if no test ever expands/toggles them, they can disappear without detection.

4. **DB-seeded vs UI-exercised** — A test that seeds data via `pool.query()` does NOT test the UI flow. Flag features that are only tested via DB seeding as HIGH gaps.

### Output Format:

```
## Coverage Gap Report

### CRITICAL Gaps (daily-use, zero coverage)
1. **[Feature]** — [Component:line]
   Action: [what the user does]
   Why untested: [no test exists / test seeds DB only / test opens dialog but skips this field]
   Risk: [what breaks silently if this disappears]

### HIGH Gaps (regular-use, partial coverage)
...

### MEDIUM Gaps
...

### Summary
- Total user actions inventoried: N
- Actions with E2E coverage (through UI): N (X%)
- Actions with unit test coverage: N (X%)
- Actions with DB-seed-only coverage: N (X%)
- Actions with ZERO coverage: N (X%)
```

---

## Phase 2: Verification Prompt

Confirm or reject each finding by checking actual code.
Classify as: **CONFIRMED** / **ALREADY FIXED** / **NOT A BUG** / **DESIGN CHOICE**

---

## Phase 3: Common Sense Prompt

Step back and look at the test suite holistically.

### Look for:

1. **Over-testing** — More E2E tests than the app has critical flows. Sign: test count > 30 for an internal tool.
2. **No happy path** — Critical user flows have edge case tests but no basic success test.
3. **Tests that cost more to maintain than the bugs they catch** — Fragile selectors, data race workarounds, complex setup for trivial assertions.
4. **Coverage theater** — High test count but tests all check the same basic "it renders" pattern.
5. **Missing critical paths** — The most important user flow has no test while trivial features have extensive coverage.
6. **Tests slower than manual checking** — A 30-second E2E test for something a user can verify in 2 seconds.
7. **Maintenance debt generators** — Tests coupled to Thai tooltip text, PrimeVue CSS classes, or specific date formats.
8. **Wrong test level** — Business logic tested with E2E when a Vitest unit test would be faster, more reliable, and catch the same bug.

### Output:
- **Issue** — what's wrong
- **Why it matters** — real-world impact on developer velocity
- **Suggestion** — keep / trim / remove / replace with DB guard / downgrade to unit test
