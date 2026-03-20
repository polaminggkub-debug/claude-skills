# Phase 0: File Manifest — Chris

Before launching any Phase 1 agents, build a deterministic file manifest so every file is assigned to exactly one agent and nothing is missed.

## Step 1: Glob All Files

Run these globs on the target test directory and source directory:

```
{test-dir}/**/*.spec.ts    → test files
{test-dir}/**/*.test.ts    → test files
{source-dir}/**/*.ts       → source files (model, composable, utility)
{source-dir}/**/*.vue      → source components
playwright.config.ts       → config
{test-dir}/**/helpers/*.ts → shared test helpers/fixtures
```

## Step 2: Classify & Assign Files

| Agent | Primary Files | Purpose |
|-------|--------------|---------|
| A: Validity | ALL `*.spec.ts` / `*.test.ts` files | Check if tests test real things |
| B: ROI & Trim | ALL TEST files | Identify what to KEEP / DOWNGRADE / REMOVE |
| C: Performance | ALL `*.spec.ts` + `playwright.config.ts` + helper files | Check speed & reliability |
| D: Architecture | ALL `*.spec.ts` + ALL SOURCE files + shared fixtures | Check structure, maintainability, and testable design |

**Rules:**
- Agents A, B, C all read test files but with DIFFERENT checklists
- Agent D reads BOTH test files AND source files to assess testable architecture
- Every test file MUST appear in agents A, B, C, and D
- Every source file MUST appear in agent D

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
- /absolute/path/to/test1.spec.ts
- /absolute/path/to/test2.spec.ts
...

[Then include the agent's standard checklist from agent-prompts.md]
```

**Agent D special instruction:**
```
For each SOURCE file, identify units and their types:
  [PURE LOGIC] functionName — clear spec, independently testable
  [I/O] functionName — reads/writes external data
  [ORCHESTRATOR] functionName — wires units together
  [UTILITY] functionName — domain-independent helper
  [UNTESTABLE] functionName — mixed concerns, needs refactoring

For each test file, check if tests align with unit specs.
Flag any unit without a happy path test.
```

## Step 4: Include Previous Findings (if any)

If a previous audit report exists at `docs/audit/{module}-*-report*.html`:
1. Read the report
2. Extract CONFIRMED findings
3. Add to each agent's prompt:

```
KNOWN FINDINGS FROM PREVIOUS AUDIT (do not re-report unless changed):
- [CONFIRMED] test-file.spec.ts:42 — circular test pattern
...
Focus on NEW issues or verify that known issues are still present.
```

## Step 5: File Count Limits

- If any agent has >30 files, split into logical sub-groups in the prompt
- Agent can read them sequentially — just list them all

## Convergence Criteria

After Phase 2 verification, calculate the convergence verdict:

| Verdict | Criteria |
|---------|----------|
| **PASS** | 0 CONFIRMED CRITICAL or HIGH findings |
| **CONDITIONAL PASS** | ≤2 HIGH findings, all are known limitations or have workarounds |
| **FAIL** | Any CONFIRMED CRITICAL, or ≥3 CONFIRMED HIGH |

Include this verdict prominently in the HTML report header.
