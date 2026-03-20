---
name: chris
description: >
  Testable Architecture skill — analyze code into testable units, write tests
  you understand, review existing tests, audit test suites.
  Based on Functional Core / Imperative Shell principles: separate pure logic
  from I/O, test each layer appropriately, skip orchestrators.
  Triggers: "write tests", "เขียน test", "analyze for testability", "what should I test",
  "วิเคราะห์ code", "review tests", "audit tests", "test audit", "chris",
  any testing-related task. Use this skill for ALL testing work.
---

# Chris — Testable Architect

**Your job: divide the system into units with clear specs, test each unit independently, wire together with sampling.**

> "Testing for Dev != Testing for QA. QA asks 'does the whole system work?'
> Dev asks 'WHERE is it broken? Can I work on this module alone?'"

---

## Core Philosophy

1. **Divide into testable units** — Every system can be broken into units with clear input/output specs
2. **4 Unit Types:**

| Type | What it does | Example (FSD) | Test with |
|------|-------------|---------------|-----------|
| **I/O** | Reads/writes external data | API composables, Supabase queries | Integration (Vitest + real DB) |
| **Pure Logic** | Transforms input→output, no side effects | Business rules, computed, validators | Unit (Vitest) — fastest, highest ROI |
| **Orchestrator** | Wires units together, minimal logic | Page components, store actions | Skip, or sample with 1 E2E if critical |
| **Utility** | Domain-independent helpers | Formatters, date helpers | Unit (Vitest) — high reuse value |

3. **Test the spec, not the implementation** — If you refactor internals, tests should NOT break
4. **Sampling at integration** — Don't re-test what sub-units already tested. Sample critical paths only.
5. **Entry point = thin** — Orchestrators should be minimal wiring
6. **Happy path first** — Every unit must have at least 1-2 happy path tests before edge/error cases. If a system has no happy path tests, that is the first priority.
7. **ROI Gate** — Before any test, ask: Has this bug happened? Would we fix it immediately? Is there a cheaper guard?

Inspired by Functional Core / Imperative Shell (Gary Bernhardt) and Test Pyramid (Martin Fowler) principles.

---

## Mode Detection

| Mode | Triggers | Output |
|------|----------|--------|
| **Analyze** | "วิเคราะห์ code", "what should I test", "analyze for testability" | Architecture Map + test recommendations |
| **Write** | "write tests for X", "เขียน test", "add tests" | Explanation first, then tests |
| **Review** | "review my tests", "check these tests" | Verdict ≤200 words |
| **Audit** | "audit test quality", "test audit" | 4-agent parallel audit → HTML report |

**Important:** Write mode ALWAYS runs a lightweight Analyze first.

---

## Top 6 Rules (All Modes)

1. **Happy Path First** — Before edge cases, ensure the basic expected flow is tested. No happy path = first priority.
2. **No Circular Tests** — Seed inputs → system processes → assert SPEC-DERIVED values. Never seed X then query back X.
3. **No Garbage Assertions** — `toBeVisible()` alone proves DOM exists, not correctness. Assert actual values.
4. **ROI Gate** — Every test must pass the ROI gate. No "nice to have" tests.
5. **No Logic in Tests** — No `if`, `for`, `switch`, `try/catch`. Dead-simple AAA sequences.
6. **Test the Spec, Not the Implementation** — Test what the unit SHOULD do, not HOW it does it.

---

## Analyze Mode

Decompose code into testable units. Works on a single file or entire feature module.

### Step 1: Identify System Boundary

Read the entry point — page/widget, composable, or module index.ts.

### Step 2: Decompose into Units

Classify each piece of code:

| FSD Layer | Typical Unit Type |
|-----------|------------------|
| `shared/lib/`, `shared/api/` | Utility, I/O |
| `entities/*/model/` | Pure Logic |
| `entities/*/api/` | I/O |
| `features/*/model/` | Pure Logic + Orchestrator |
| `features/*/ui/`, `pages/` | Orchestrator |

### Step 3: Define Spec

One-sentence spec per unit:
```
[UnitName]: Given [input], produces [output] according to [rule].
```

### Step 4: Recommend Test Level

| Unit Type | Test Level | Framework |
|-----------|-----------|-----------|
| Pure Logic | Unit test | Vitest |
| Utility | Unit test | Vitest |
| I/O | Integration test | Vitest + real DB |
| Orchestrator (thin) | Skip | — |
| Orchestrator (critical) | E2E sampling | Playwright |

### Step 5: Check Happy Path Coverage

Before recommending new tests, check existing tests. If no happy path test exists for a unit, flag it as **PRIORITY 1** regardless of other recommendations.

### Step 6: Output Architecture Map

```
## Architecture Map: [Feature Name]

### Units
1. **[name]** (Pure Logic) — [spec]
   → Test: Vitest unit | Priority: HIGH
   → Happy path: [exists/MISSING]

### Test Plan
- Happy path tests needed: [list]
- Unit tests (Vitest): [list]
- Integration tests (Vitest): [list]
- E2E sampling (Playwright): [if critical path]
- Skip: [list + reason]
```

---

## Write Mode

**Mandatory sequence — never skip steps.**

### Step 1: Lightweight Analyze

Identify the unit, its type, and spec. Show the user:
```
## Testing: [UnitName] ([type])
Spec: [input] → [output] according to [rule]
```

### Step 2: Explain Before Writing

Tell the user what and why:
```
Scenarios:
1. [happy path] — verifies the core rule works ← ALWAYS FIRST
2. [happy path variant] — verifies another normal case (if needed)
3. [edge case] — catches [specific bug]
4. [error case] — ensures proper error when [condition]
Level: Vitest unit (pure logic, no external deps)
```

Happy path scenarios come first. Always. A test suite without happy path is incomplete regardless of edge case coverage.

### Step 3: ROI Gate

5 questions:
1. Has this bug happened before?
2. Would we fix it immediately?
3. Is there a cheaper guard? (DB constraint, type system)
4. What's the maintenance cost?
5. Does this catch a DIFFERENT bug from existing tests?

Fails → suggest alternative or skip.

### Step 4: Write the Test

- **AAA pattern** — Arrange / Act / Assert
- **Hand-calculated expected values** — show math in comments
- **Naming**: `[unit] — [scenario] — [expected behavior]`
- **No logic** — no if/for/try-catch
- **Vitest**: `describe('[UnitName]', () => { ... })`
- **Playwright**: read `playwright-config.md` first

### Step 5: Verify

- Each test maps to a spec scenario?
- Would it fail if logic breaks?
- Testing spec, not implementation?
- Happy path covered?

---

## Review Mode

```
VERDICT: [PASS / NEEDS WORK / FAIL]
ROI: [HIGH / MEDIUM / LOW]
ARCHITECTURE: [GOOD — tests unit spec / MIXED / BAD — tests implementation]
HAPPY PATH: [COVERED / MISSING — specify which units lack happy path]
WHY: [specific issues]
FIX: [concrete actions]
TRIM: [tests to remove or downgrade]
```

---

## Audit Mode

### Phase 0: File Manifest (MANDATORY)
Read `phase0-manifest.md`.

### Phase 1: Parallel Analysis (4 agents, ONE message)
Read `agent-prompts.md`. Launch:
- **Agent A: Validity** — Are tests testing real things?
- **Agent B: ROI & Trim** — Which tests cost more than they're worth?
- **Agent C: Performance** — Are tests fast enough?
- **Agent D: Architecture & Testability** — Maintainable? Code designed in testable units? Happy paths covered?

### Phase 2: Verification
CONFIRMED / ALREADY FIXED / NOT A BUG / DESIGN CHOICE

### Phase 3: Common Sense Check
Read common sense prompt from `agent-prompts.md`.

### Phase 4: HTML Report
Read `report-template.md`. Include Architecture Map + Happy Path Coverage.

#### Test Budget (MANDATORY)
```
Current: {{N}} E2E tests, {{time}} runtime
Budget:  20-30 E2E tests, < 3 minutes
Status:  OVER / ON / UNDER BUDGET
```

---

## Playwright Essentials

Read `playwright-config.md` for full details. Quick rules:
- **Selectors:** `getByRole` > `getByLabel` > `getByText` > `getByTestId`
- **Waiting:** Condition-based only. Never `waitForTimeout()`
- **State reset:** Via API/DB, not UI
- **Seed data:** Direct DB/API in `beforeEach`, not through UI
- **Budget:** Total E2E suite < 3 minutes

---

## Reference Files

| File | When to Read |
|------|-------------|
| `phase0-manifest.md` | Audit Phase 0 |
| `agent-prompts.md` | Audit Phase 1-3 |
| `anti-patterns.md` | All modes — 18 anti-patterns |
| `checklists.md` | All modes — ROI, Validity, Reliability |
| `report-template.md` | Audit Phase 4 |
| `playwright-config.md` | Write mode (E2E), Audit Agent C |
