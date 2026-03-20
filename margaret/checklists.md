# Margaret — Structured Checklists

Use these checklists during audit analysis. Each agent should reference
the relevant checklist to ensure systematic coverage.

---

## A. Security Checklist

Use with Agent E. Check every item; mark as PASS / FAIL / N/A.

### Access Control
- [ ] RLS enabled on ALL tables with user-facing data
- [ ] RLS policies scoped to user/org (not `USING (true)`)
- [ ] Service role key NOT used in client-side code
- [ ] Anon key used only for public operations
- [ ] Route guards on ALL protected pages (router-level, not page-level)
- [ ] Role-based access enforced in RLS, not just frontend

### Authentication
- [ ] Auth flow complete: login, logout, session refresh, token expiry
- [ ] Expired/revoked tokens handled gracefully
- [ ] No user enumeration via error messages
- [ ] Password policy enforced (minimum length/complexity)
- [ ] Password reset tokens single-use and time-limited
- [ ] Session timeout configured

### Input Validation
- [ ] User input validated before queries (type, length, format)
- [ ] File uploads validated (type, size, content-type verification)
- [ ] No `v-html` with unsanitized user data
- [ ] URL parameters sanitized before use
- [ ] No raw SQL string interpolation with user input

### Secrets & Configuration
- [ ] No hardcoded credentials in source files
- [ ] Environment variables properly separated (.env / .env.local / .env.production)
- [ ] .env files in .gitignore
- [ ] No secrets in client-side bundles (check build output)
- [ ] Debug mode disabled in production config

### Network & Transport
- [ ] CORS configured with specific origins (not `*` in production)
- [ ] Content-Security-Policy header configured
- [ ] Cookies use HttpOnly, Secure, SameSite flags
- [ ] HTTPS enforced (no mixed content)

### Rate Limiting & Abuse Prevention
- [ ] Login/signup endpoints rate-limited
- [ ] Password reset rate-limited
- [ ] API endpoints have reasonable rate limits
- [ ] No unlimited resource creation (free tier abuse)

---

## B. Error Handling Checklist

Use with Agent F. Check every item; mark as PASS / FAIL / N/A.

### Async Error Handling
- [ ] All `await` calls wrapped in try/catch or have `.catch()` handlers
- [ ] No empty `.catch(() => {})` blocks (silent failures)
- [ ] Errors in loops don't crash the entire batch operation
- [ ] Promise.all failures handled (partial success scenarios)
- [ ] Supabase errors checked: `if (error) { ... }` after every call

### Error Boundaries & Recovery
- [ ] Global error handler registered (`app.config.errorHandler` in Vue)
- [ ] Critical sections wrapped in error boundary components
- [ ] Router navigation failures handled (`router.onError`)
- [ ] Real-time subscription failures don't crash the UI
- [ ] WebSocket reconnection logic implemented

### User Feedback
- [ ] Failed operations show error toast/message to user
- [ ] Error messages are user-friendly (not raw JSON/stack traces)
- [ ] Loading states shown during async operations
- [ ] Empty states distinguished from error states
- [ ] Form validation errors shown inline next to fields

### Retry & Resilience
- [ ] Network calls have retry logic for transient failures (5xx, timeouts)
- [ ] Retries use exponential backoff
- [ ] Retried operations are idempotent (won't create duplicates)
- [ ] Timeout configured for all external calls
- [ ] Graceful degradation when non-critical services fail

### Error Logging
- [ ] Errors logged with context (user, action, input data)
- [ ] No PII in error logs (emails, passwords, personal data)
- [ ] Structured logging format (not just `console.log`)
- [ ] Different log levels used appropriately (error vs warn vs info)
- [ ] Client-side errors reported to monitoring service

---

## C. Data Integrity Checklist

Use with Agents B and D. Check every item; mark as PASS / FAIL / N/A.

### Null & Undefined Safety
- [ ] Nullable database columns handled with `COALESCE` in SQL
- [ ] Nullable values handled with `?? 0` or `?? ''` in TypeScript
- [ ] Optional chaining used for nested property access (`a?.b?.c`)
- [ ] Default values provided for all optional function parameters
- [ ] NULL foreign keys handled in JOINs (LEFT JOIN awareness)

### Sign & Calculation Correctness
- [ ] Addition/subtraction correct for all operation types
- [ ] "Return to stock" adds (not subtracts)
- [ ] Consistent sign convention across all functions
- [ ] Percentages calculated correctly (numerator/denominator not swapped)
- [ ] Rounding applied consistently (and only for display, not storage)
- [ ] `.toFixed()` NOT used when storing values (display only)

### Atomicity & Consistency
- [ ] Multi-step operations use database transactions
- [ ] No read-then-write patterns without locks
- [ ] Batch operations don't fail silently mid-batch
- [ ] Sequential `await` in loops replaced with `Promise.all` where appropriate
- [ ] Optimistic updates reverted on failure

### Type Safety
- [ ] Database dates treated as `string` (not `Date` objects)
- [ ] Numeric strings converted before arithmetic (`Number()` or `parseFloat()`)
- [ ] Enum values validated against allowed set
- [ ] API response types validated (not blindly trusted)
- [ ] No `any` types hiding potential mismatches

### Status & State Consistency
- [ ] Status values consistent between DB functions and frontend
- [ ] Cancelled/deleted records filtered from ALL calculations
- [ ] Status transitions are valid (no impossible state changes)
- [ ] Two views of same data show same numbers
- [ ] "Complete" status mathematically reachable

### Constraints & Guards
- [ ] Database constraints enforce valid data (CHECK, NOT NULL, UNIQUE)
- [ ] Guard triggers on critical tables (prevent over-withdraw, etc.)
- [ ] Frontend validation matches backend constraints
- [ ] Edit operations re-validate (don't bypass guards)
- [ ] Cascading deletes/updates handled correctly

---

## D. Flow Integrity Checklist

Use with Agent G. Check every item; mark as PASS / FAIL / N/A.

### Formula Consistency Across Layers
- [ ] UI "remaining" formula matches DB guard "remaining" formula
- [ ] All terms present in UI calculation also present in guard (e.g., adjustments)
- [ ] No conditional branching in one layer that's absent in another
- [ ] Sign conventions identical across layers (positive = add, negative = subtract)

### RPC ↔ Guard Agreement
- [ ] Every RPC function that computes "available"/"remaining" has a matching guard trigger
- [ ] Guard trigger uses the SAME upstream source as the RPC function
- [ ] Guard trigger filters by the SAME status values as the RPC function
- [ ] NULL handling (COALESCE patterns) identical between RPC and guard

### UI ↔ Composable ↔ DB Data Flow
- [ ] Values displayed in UI come from the same RPC function the guard validates against
- [ ] No stale cached values displayed while guard checks live data
- [ ] Edit operations re-fetch before submitting (no TOCTOU between display and action)
- [ ] Error messages from guard triggers are properly surfaced in UI

### Cross-Table Consistency
- [ ] Tables that should have guard triggers DO have them
- [ ] Guard triggers cover both INSERT and UPDATE (not just INSERT)
- [ ] Cancelled record handling consistent across all functions touching the same tables
- [ ] Lot number / bill number matching logic identical across all layers

### End-to-End Flow Completeness
- [ ] Every user action that changes data has a corresponding guard
- [ ] Cancel/undo operations properly reverse all effects
- [ ] Batch operations validate each item (not just the first/last)
- [ ] Concurrent operations on the same resource are handled (optimistic locking or serialization)

---

---

## How to Use These Checklists

1. **During analysis**: Each agent scans code against its relevant checklist
2. **Mark each item**: PASS (code handles it) / FAIL (missing or broken) / N/A (not applicable)
3. **Report FAIL items**: Include in findings with code quotes and file paths
4. **Prioritize**: CRITICAL = data loss or security breach, HIGH = wrong data, MEDIUM = poor UX
5. **Verify in Phase 2**: Every FAIL must be confirmed against current code
