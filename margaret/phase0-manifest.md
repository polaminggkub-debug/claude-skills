# Phase 0: File Manifest — Margaret

Before launching any Phase 1 agents, build a deterministic file manifest so every file is assigned to exactly one agent and nothing is missed.

## Step 1: Glob All Files

Run these globs on the target module directory:

```
**/*.ts          → model, composable, utility, config files
**/*.vue         → UI components
**/*.spec.ts     → test files
**/*.test.ts     → test files
```

If SQL migrations are relevant, also glob:
```
supabase/migrations/*.sql  → filter to module-relevant migrations
```

## Step 2: Classify & Assign Files

Assign each file to ONE primary agent. If a file is relevant to two agents (e.g., a composable is relevant to both B and F), assign it to the primary agent and list it as "also-read" for the secondary.

| Agent | Primary Files | Pattern |
|-------|--------------|---------|
| A: Test Coverage | `*.spec.ts`, `*.test.ts` | Test files only |
| B: Business Logic | `model/**/*.ts`, `*/model/*.ts`, composables (`use*.ts`), `shared/lib/**/*.ts` | Non-UI TypeScript |
| C: UI Components | `**/*.vue`, `*Dialog.vue`, `*Tab.vue` — **paired as parent→child** | Vue components |
| D: Data Layer | `migrations/*.sql` matching the module | SQL only |
| E: Security | `shared/api/*.ts`, `shared/config/*.ts`, `.env*`, RLS migration files | Security-relevant files |
| F: Error Handling | Same files as B + C (reads them with error-handling lens) | Shared with B/C |
| G: Flow Integrity | Cross-layer: composables with `.rpc()` + their SQL definitions + guard triggers + Vue components displaying results | Built dynamically (see below) |

**Rules:**
- Every globbed file MUST appear in at least one agent's list
- If Agent D has no files (no SQL), skip Agent D
- If Agent E has fewer than 3 files, merge its scope into Agent B
- Agent F always shares files with B and C — this is intentional (different checklist)
- Agent G always shares files with B, C, and D — this is intentional (cross-layer lens)

- If no `.rpc()` calls exist in the module, skip Agent G

**Agent G File Assignment (cross-layer, built dynamically):**
1. Grep all `.rpc()` calls in module composables → list the RPC function names
2. Find SQL migrations defining those functions (`CREATE.*FUNCTION fn_name`)
3. Find guard triggers on the same tables (`CREATE TRIGGER.*ON table_name`)
4. Find Vue components that call the composables or display the RPC results
5. Group by user flow and assign the complete file set to Agent G

## Step 3: Build Agent Prompts with Explicit File Lists

For each agent, construct the prompt as:

```
You MUST read and analyze EVERY file listed below.
For each file, report one of:
  [PASS] filename — no issues found
  [FAIL] filename — issue description

Do NOT skip any file. Do NOT read files not on this list.
If a file is empty or trivial, still report [PASS].

YOUR ASSIGNED FILES:
- /absolute/path/to/file1.ts
- /absolute/path/to/file2.ts
- /absolute/path/to/file3.vue
...

[Then include the agent's standard checklist from agent-prompts.md]
```

## Step 4: Include Previous Findings (if any)

If a previous audit report exists at `docs/audit/{module}-*-report*.html`:
1. Read the report
2. Extract CONFIRMED findings (not ALREADY FIXED or NOT A BUG)
3. Add to each agent's prompt:

```
KNOWN FINDINGS FROM PREVIOUS AUDIT (do not re-report these unless they've changed):
- [CONFIRMED] file.ts:42 — null handling issue in calculateTotal
- [CONFIRMED] Dialog.vue:15 — missing loading state
...

Focus on NEW issues or verify that known issues are still present.
```

## Step 5: File Count Limits

- If any agent has >30 files, split into logical sub-groups in the prompt
- Agent can read them sequentially — just list them all
- For very large modules (>100 files), consider splitting into sub-module audits

## Convergence Criteria

After Phase 2 verification, calculate the convergence verdict:

| Verdict | Criteria |
|---------|----------|
| **PASS** | 0 CONFIRMED CRITICAL or HIGH findings |
| **CONDITIONAL PASS** | ≤2 HIGH findings, all are design choices or have documented workarounds |
| **FAIL** | Any CONFIRMED CRITICAL, or ≥3 CONFIRMED HIGH |

Include this verdict prominently in the HTML report header. A module that receives PASS does not need re-auditing unless code changes significantly.
