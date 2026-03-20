# Chris — Checklists

4 mandatory checklists for test quality validation. Use in all modes.

---

## A. Happy Path Checklist (3 items) — CHECK FIRST

Does the system have basic success tests?

- [ ] **Every identified unit has at least 1 happy path test** — the basic expected flow works
- [ ] **Critical user flows have a happy path E2E** — the main journey a user takes
- [ ] **Happy path tests come before edge/error cases** — in test file ordering and in priority

---

## B. ROI Checklist (5 items)

Does this test earn its maintenance cost?

- [ ] **Passes ROI gate** — Has this bug happened before? Would we fix it immediately? Is there a cheaper guard?
- [ ] **Right test level** — DB guard > unit test > integration > E2E. Default to the cheapest level that catches the bug.
- [ ] **No duplicate coverage** — No other test already catches this same bug
- [ ] **Budget-aware** — Adding this test keeps total E2E count ≤ 30 and suite runtime < 3 min
- [ ] **Low maintenance** — Uses stable selectors, no coupling to Thai tooltip text, CSS classes, or date formats

---

## C. Validity Checklist (8 items)

Does the test actually test what it claims?

- [ ] **No circular tests** — Inputs seeded, outputs computed by system (not read back from seed)
- [ ] **Expected values from spec** — Hand-calculated from business rules, not copied from output
- [ ] **Show the math** — Comments explain derivation (e.g., `// 50000/30 × 10 × 1.5 = 25000`)
- [ ] **Breaking the logic WOULD fail this test** — Mentally break the code and verify
- [ ] **No garbage assertions** — Every assertion checks a specific value, not just existence
- [ ] **No weakened assertions** — No relaxed checks to accommodate known bugs
- [ ] **No logic in tests** — No if/else, for loops, try/catch (except `test.each`)
- [ ] **AAA pattern** — Clear Arrange → Act → Assert sections

---

## D. Reliability Checklist (5 items)

Will the test produce the same result every time?

- [ ] **No waitForTimeout** — All waits are condition-based
- [ ] **State reset via API/DB** — No dependency on UI navigation for cleanup
- [ ] **Stable selectors** — `getByRole` > `getByLabel` > `getByText` > `getByTestId`. CSS selectors acceptable for framework components without semantic alternatives.
- [ ] **File independence** — Each file runs in isolation without depending on other files
- [ ] **Parallel safe** — No shared mutable state, worker-isolated data prefixes
