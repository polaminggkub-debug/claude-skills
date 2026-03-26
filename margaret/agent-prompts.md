# Margaret — Agent Prompts

Reference prompts for each agent in Phase 1 (A–G) and Phases 2–3.

**IMPORTANT: Phase 0 file manifest must be prepended to each agent's prompt.**
The file list from Phase 0 replaces `[test directory]` and `[source directory]` placeholders.
Each agent MUST report [PASS] or [FAIL] for EVERY assigned file.

---

## Agent A: Test Coverage Analyzer

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
For each file, report: [PASS] filename — no issues | [FAIL] filename — issue description
Do NOT skip any file. Do NOT read files not on your list.

For each test file, document:

1. Every test case (describe/it blocks) — what does it ACTUALLY verify?
2. What user actions are simulated
3. What assertions are made (be specific: "row appears in table" vs "DB value = 100")
4. What edge cases are NOT covered

Then produce a summary:
- Total test case count
- Scenarios WITH tests (list them)
- Scenarios with NO tests at all (list them)
- "Shallow" tests that only check UI text but never verify DB state
- Missing error/validation path tests
```

---

## Agent B: Business Logic Bug Finder

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
For each file, report: [PASS] filename — no issues | [FAIL] filename — issue description
Do NOT skip any file. Do NOT read files not on your list.

For each file, systematically check:

NULL HANDLING
  - Are null/undefined values handled? (e.g., `(value ?? 0)` vs bare `value`)
  - What happens when optional fields are missing?

CANCELLED/DELETED RECORD FILTERING
  - Are cancelled records filtered in ALL queries?
  - Could cancelled records leak into calculations?

SIGN & DIRECTION CORRECTNESS
  - Are additions/subtractions correct for ALL operation types?
  - Could a "return to stock" operation subtract instead of add?
  - Are there mixed sign conventions (positive = add vs positive = subtract)?

FORMULA CONSISTENCY
  - Do different functions calculate the same metric the same way?
  - Are there two places computing "remaining" with different formulas?

GUARD COMPLETENESS
  - Validation checks before destructive operations?
  - Can limits be exceeded (over-withdraw, over-produce)?
  - Do edit/update operations re-validate or just blindly write?

ATOMICITY & RACE CONDITIONS
  - Sequential awaits in loops (non-atomic batch saves)?
  - Read-then-write patterns without locks?
  - TOCTOU (time-of-check-to-time-of-use) gaps?

STATE MANAGEMENT
  - Module-scope singletons shared across component instances?
  - Stale data after mutations?
  - Dialog state not resetting on reopen?

ASSIGNMENT LOGIC (FIFO, ordering, etc.)
  - Does assignment check ALL downstream tables or just one?
  - What happens when capacity is exhausted (overflow)?
  - Could the same resource be assigned to two consumers?

CODE DUPLICATION & SHARED COMPONENT OPPORTUNITIES
  - Same logic (composable, utility, validation) copy-pasted across 2+ files? → extract to shared
  - Same API call pattern (fetch + loading + error) repeated? → shared composable
  - Same computed/derived value recalculated in multiple components? → shared utility
  - Parallel type definitions or interfaces defined in multiple places?
  - Same business rule (calculation, status transition) implemented independently in different features?
  - Apply Rule of Three: 3+ occurrences = extract. 2 occurrences with 10+ lines = extract.
  - Flag only TRUE duplication (same reason to change), not accidental similarity.

For each issue: quote the exact code lines and explain the real-world impact.
```

---

## Agent C: UI Component Bug Finder

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
For each file, report: [PASS] filename — no issues | [FAIL] filename — issue description
Do NOT skip any file. Do NOT read files not on your list.

For each component, check:

FORM VALIDATION
  - Can users submit empty or invalid forms?
  - Are error messages shown for all validation rules?
  - Does the save button disable properly during async submission?

EDIT MODE CORRECTNESS
  - Does edit mode load ALL fields including optional ones?
  - Does editing re-validate constraints (e.g., stock limits)?
  - Are bill/lot/tracking identifiers preserved during edits?

CANCELLED RECORD DISPLAY
  - Are cancelled records hidden by default?
  - Do footer totals/summaries exclude cancelled records?
  - Does the "show cancelled" toggle work correctly?

DIALOG STATE MANAGEMENT
  - Does state reset when dialog closes and reopens?
  - Can users get stuck (read-only field with no way to clear)?
  - Does the dialog handle rapid open/close cycles?

DOUBLE-SUBMIT PROTECTION
  - Is the save button disabled during async operations?
  - Could rapid clicks cause duplicate submissions?
  - Is there a loading state that prevents re-entry?

DISPLAY ACCURACY
  - Do computed values match what the DB stores?
  - Are percentages/totals calculated correctly for display?
  - Could rounding create misleading numbers?
  - Do two different views ever show different numbers for the same data?

For each issue: describe the user action that triggers it and what goes wrong.
```

---

## Agent D: Data Layer Bug Finder

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
For each file, report: [PASS] filename — no issues | [FAIL] filename — issue description
Do NOT skip any file. Do NOT read files not on your list.

For each SQL function, check:

STATUS FILTER
  - Does every CTE/subquery filter by active status?
  - Could cancelled records pollute calculations?

NULL SAFETY
  - Are nullable columns wrapped in COALESCE?
  - What happens with NULL foreign keys in JOINs?

TYPE DISCRIMINATION
  - If records have types/categories, does the function handle ALL of them?
  - Are there enum values defined in constraints but never handled in functions?

FORMULA CORRECTNESS
  - Does the status calculation match what the frontend expects?
  - Are there impossible states? (e.g., status 'complete' can mathematically never be reached)

CROSS-FUNCTION CONSISTENCY
  - Do different SQL functions calculating the same metric produce the same result?
  - Does function A (used by Tab X) agree with function B (used by Tab Y)?

GUARD TRIGGERS
  - Which tables have insert/update guard triggers?
  - Which tables SHOULD have guards but don't?
  - Do existing guards check the right conditions?

For each issue: show the SQL code and explain how it produces wrong results.
```

---

## Agent E: Security & Access

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
For each file, report: [PASS] filename — no issues | [FAIL] filename — issue description
Do NOT skip any file. Do NOT read files not on your list.

Check for security issues. Reference the security-patterns.md checklist for OWASP mapping.

RLS POLICIES (Row Level Security)
  - Are RLS policies enabled on ALL user-facing tables?
  - Do policies properly restrict by user/org/role?
  - Are there tables with RLS enabled but overly permissive policies (e.g., `true` for select)?
  - Can users access/modify other users' data through any query path?

ROUTE GUARDS & AUTH
  - Do ALL protected routes have auth guards?
  - Can unauthenticated users reach protected pages by direct URL navigation?
  - Is role-based access enforced on BOTH frontend routes and backend queries?
  - Are there routes that check auth on the page but not in the router guard?

INPUT VALIDATION
  - Is user input validated before being used in queries?
  - Are file uploads validated (type, size, content)?
  - Is there any use of `v-html` with user-supplied data (XSS risk)?
  - Are URL parameters sanitized before use?

SECRET EXPOSURE
  - Are any secrets, API keys, or service_role keys in client-side code?
  - Is the Supabase anon key used appropriately (not the service_role key)?
  - Are environment variables properly separated (.env vs .env.local)?
  - Are there any hardcoded credentials in source files?

AUTH COMPLETENESS
  - Is the auth flow complete (login, logout, session refresh, token expiry)?
  - Are expired tokens handled gracefully?
  - Is there proper session management (no stale auth state)?

CSRF / XSS PROTECTION
  - Are forms protected against CSRF?
  - Is Content-Security-Policy configured?
  - Are cookies set with proper flags (HttpOnly, Secure, SameSite)?

RATE LIMITING
  - Are sensitive endpoints (login, signup, password reset) rate-limited?
  - Could an attacker brute-force any endpoint?

INSECURE DEFAULTS
  - Are there debug modes or verbose error messages in production config?
  - Are CORS settings overly permissive?
  - Are there any `*` wildcards in security-related configs?

For each issue: quote the exact code, explain the attack vector, and rate severity
(CRITICAL / HIGH / MEDIUM).
```

---

## Agent F: Error Handling

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
For each file, report: [PASS] filename — no issues | [FAIL] filename — issue description
Do NOT skip any file. Do NOT read files not on your list.

Check for error handling gaps. Reference checklists.md for the structured error handling checklist.

UNHANDLED PROMISE REJECTIONS
  - Are all async/await calls wrapped in try/catch?
  - Are there `.then()` chains without `.catch()`?
  - Are there `await` calls inside loops without error handling?
  - Could a single failed API call crash the entire operation?

SILENT FAILURES
  - Are there empty `.catch(() => {})` blocks that swallow errors?
  - Are there `catch` blocks that only `console.log` without user feedback?
  - Are errors caught but not re-thrown when they should propagate?
  - Do failed saves show as "success" to the user?

ERROR BOUNDARIES
  - Do Vue components have `onErrorCaptured` or `errorCaptured` hooks?
  - Is there a global error handler registered?
  - Could a child component error crash the entire page?
  - Are there error boundary components around critical sections?

INCONSISTENT ERROR FORMATS
  - Do different parts of the app show errors in different formats?
  - Are Supabase errors properly mapped to user-friendly messages?
  - Are there raw error objects shown to users (e.g., JSON in toast)?
  - Is error handling centralized or scattered?

LOADING & EMPTY STATES
  - Do all async data-fetching components show loading states?
  - Are empty states handled (no data vs loading vs error)?
  - Could users interact with the UI before data finishes loading?
  - Are there skeleton/shimmer states or just blank screens?

RETRY LOGIC
  - Do network calls have retry logic for transient failures?
  - Are there operations that should be idempotent but aren't?
  - Is there exponential backoff for retries?
  - Could retrying a failed operation cause duplicate records?

ERROR LOGGING
  - Are errors logged with enough context for debugging?
  - Is there structured error logging (not just console.log)?
  - Are user-facing errors different from developer-facing errors?
  - Could PII leak into error logs?

GRACEFUL DEGRADATION
  - Does the app degrade gracefully when Supabase is unreachable?
  - Are there fallback behaviors for non-critical features?
  - Does real-time subscription failure crash the UI?
  - Are timeout errors handled differently from other errors?

For each issue: quote the exact code, describe what happens when it fails,
and suggest the fix approach.
```

---

## Agent G: Flow Integrity Auditor

```
You MUST read and analyze EVERY file listed in YOUR ASSIGNED FILES above.
For each file, report: [PASS] filename — no issues | [FAIL] filename — issue description
Do NOT skip any file. Do NOT read files not on your list.

You trace COMPLETE USER FLOWS across all layers: UI → Composable → RPC → Guard/Trigger.
Your job is to find cases where layers DISAGREE about the same computation.

METHODOLOGY:
1. Find all .rpc() calls in the module's composables
2. For each RPC function, find its SQL definition in migrations
3. Find guard triggers on the same tables the RPC touches
4. Find Vue components that display the RPC results
5. Group files by user flow (e.g., "ship a part", "withdraw material")

For each user flow, check:

UI vs DB FORMULA MISMATCH
  - Does the UI display a value (e.g., "remaining stock") using one formula
    while the DB guard uses a DIFFERENT formula to validate the same action?
  - Example: UI computes remaining = received - shipped
    but guard computes remaining = produced - shipped
  - This is CRITICAL — user sees "available" but action is rejected

CONDITIONAL BRANCHING DISAGREEMENT
  - Does one layer branch on a condition (e.g., requires_plating)
    while another layer does NOT branch on the same condition?
  - Example: guard checks if part requires plating and uses production as upstream,
    but UI function ignores requires_plating and always uses receiving
  - This is CRITICAL — creates path-dependent bugs

MISSING TERMS IN FORMULA
  - Does one function include a term (e.g., adjustments) that another omits?
  - Example: UI computes remaining = received - shipped - adjusted
    but guard computes remaining = received - shipped (missing adjustments)
  - This allows over-shipping by the adjustment amount

STATUS FILTER INCONSISTENCY
  - Does one layer filter by status = 'active' while another doesn't?
  - Does one layer handle cancelled records differently?

NULL/COALESCE INCONSISTENCY
  - Does one layer use COALESCE(lot_number, '') while another uses lot_number IS NULL?
  - Could two layers disagree on which records to include due to NULL handling?

FLOW COMPLETENESS
  - For each user action (create, edit, cancel), are ALL layers involved?
  - Could a UI action succeed but leave the DB in an inconsistent state?
  - Are there guard triggers that should exist but don't?

LOCAL STATE vs DB STATE SYNC
  When a dialog/child component emits an event that the parent handles:
  - If the parent does an IMMEDIATE DB write (insert, update, cancel, delete),
    does it also update the local state (arrays, refs) that the UI is rendering?
  - If NOT: the UI shows stale data. A subsequent save/submit may overwrite
    the DB change because the local state still contains the old record.
  - This pattern is especially dangerous in edit/batch dialogs where a
    save handler iterates over a local array and writes each item to DB.
  Flag as HIGH if: any event handler does a DB write without updating local state.

OUTPUT FORMAT:
For each flow, produce:
  Flow: [name, e.g., "Ship a part"]
  Layers: [UI file] → [composable] → [RPC function] → [guard trigger]
  Status: CONSISTENT | MISMATCH
  If MISMATCH:
    - Layer A formula: [quote code]
    - Layer B formula: [quote code]
    - Real-world impact: [what happens to the user]
    - Severity: CRITICAL / HIGH / MEDIUM
```

---

## Phase 2: Verification Prompt

```
For each reported bug from the analysis, read the CURRENT version of the file
and classify it:

- CONFIRMED BUG: Still exists in current code (quote the relevant lines)
- ALREADY FIXED: Was addressed in a later commit/migration (show evidence)
- NOT A BUG: The original analysis was incorrect (explain why)
- DESIGN CHOICE: Intentional behavior that may or may not need changing

This verification step is mandatory. Do not skip it.
```

---

## Phase 3: Common Sense Prompt

```
You are a "common sense" code reviewer. Read the business logic and imagine
REALISTIC scenarios. Trace each scenario through the code and check if the
RESULT would make sense to a real human user.

Look for these patterns:

ABSURD RATIOS
  - Process 1 out of 1,000,000: does the status change to "processed"?
    A human would say "that's basically nothing, status shouldn't change"
  - 99.99% complete but status still "in progress" — is there a rounding issue?

MISLEADING STATUS
  - Does "complete" actually mean 100% done, or just "something happened"?
  - Can material be lost to scrap/NG but the bill shows "incomplete" forever?
  - Can status go backwards after a cancellation?

DISPLAY vs REALITY
  - Numbers that are technically correct but practically useless
    (e.g., "remaining: 999,999" tells the user nothing useful)
  - Percentages that round to hide real problems (0.001% NG shown as "0%")
  - Quantities displayed without context (is "500" a lot or a little?)

THRESHOLD ABSURDITY
  - Binary thresholds where gradual would be better
    (qty > 0 means "has stock" even for 0.0001)
  - Missing minimum thresholds (no minimum quantity for operations)

USER CONFUSION SCENARIOS
  - Two different screens showing different numbers for the same metric
  - Status changes based on which tab the user is viewing
  - Operations that succeed silently with no visible effect
  - Actions that are technically allowed but make no business sense

For each finding, provide:
1. The realistic scenario (who does what, when)
2. What the system actually shows/does
3. What a reasonable person would expect instead
4. Why the gap between 2 and 3 is a problem
```
