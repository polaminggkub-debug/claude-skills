---
name: margaret
description: >
  Named after Margaret Hamilton — who coined "software engineering" and wrote
  zero-defect Apollo flight software. Use for deep module/codebase auditing.
  Triggers: "audit", "find bugs", "security review", "what are we missing",
  "review the whole module", "why do I keep finding bugs", "margaret",
  systematic codebase review requests.
  NOT for single-file review — module-level deep analysis only.
---

# Margaret — Deep Bug, Security & Gap Finder

Systematic multi-phase audit using 7 parallel agents to find real bugs,
security holes, error handling gaps, test coverage issues, and common-sense
problems humans miss.

## Before You Start

Ask the user:
1. **What module/area?** — directory path or module name
2. **Any known pain points?** — recent bugs, suspect areas
3. **How many audit passes?** — You MUST ask this question and wait for an answer before proceeding. Show: "How many audit passes? (1-5, default 1 — suggest 2-3 for important modules)". Do not assume 1 and skip ahead.

Identify: **source code** dirs, **test** dirs, **SQL migrations** (if any).

## Pre-flight Estimate (MANDATORY before audit)

Before starting, estimate and show token usage so the user can decide:

1. **Count source lines** (pick first available):
   - `tokei <target_dir>` → use "code" lines total
   - `cloc --quiet <target_dir>` → use "code" column total
   - Fallback: `git ls-files -- <target_dir> | xargs wc -l | tail -1` (subtract 20%)

2. **Calculate estimate:**
   ```
   code_tokens = lines × 1.3
   read_ratio = 0.5  (audit reads ~50% of codebase)
   overhead = 23K    (system + skill + agent scaffolding)
   output = 10K      (findings per pass)

   tokens_per_pass = (code_tokens × read_ratio) + overhead + output
   merge_overhead = 15K × (N - 1)  (only if N > 1)
   total = (tokens_per_pass × N) + merge_overhead
   ```

3. **Show estimate:**
   ```
   📊 Pre-flight Estimate
   ━━━━━━━━━━━━━━━━━━━
   Codebase: [X] files, [Y] lines (~[Z]K tokens)
   Passes: [N]
   Est. per pass: ~[A]K tokens
   Est. total: ~[B]K tokens (incl. merge)
   ━━━━━━━━━━━━━━━━━━━
   ```
   Then proceed (no confirmation needed unless estimate is very large >500K).

## Reference Files

- `agent-prompts.md` — Full prompts for all 7 agents + verification + common sense
- `phase0-manifest.md` — Phase 0 file manifest instructions (MANDATORY)
- `security-patterns.md` — OWASP Top 10 mapped to Vue/Supabase stack
- `checklists.md` — Structured checklists for security, error handling, data integrity

## Phases

### Phase 0: File Manifest (MANDATORY — DO NOT SKIP)

Before launching any agents, read `phase0-manifest.md` and build the file manifest:

1. **Glob ALL files** in the target module using the patterns in phase0-manifest.md
2. **Classify and assign** each file to its primary agent (see assignment table)
3. **Build explicit file lists** for each agent prompt — absolute paths
4. **Include previous findings** if a prior audit report exists at `docs/audit/{module}-*-report*.html`
5. Each agent prompt MUST include:
   - "Read EVERY file listed. Report [PASS] or [FAIL] per file."
   - The complete file list (absolute paths)
   - Previous audit findings (if any) as context to avoid re-discovering known issues

**Why this matters:** Without Phase 0, agents choose which files to read stochastically — each run covers different files, producing different findings. Phase 0 makes audits deterministic and one-run-done.

### Multi-Pass Execution (if N > 1)

If the user requested more than 1 pass, wrap Phases 1-3 in independent passes:

1. **Phase 0 runs ONCE** — file manifest is deterministic, shared across all passes
2. **For each pass (1 to N):** Launch **1 general-purpose Agent** with:
   - The full Phase 1-3 instructions (from `agent-prompts.md`)
   - The file manifest from Phase 0
   - Instruction: "You are Pass [X] of [N]. Run all 7 analysis agents, verification, and common-sense check. Return ALL findings as structured output."
   - **NO findings from other passes** — each pass is completely independent
3. **Launch all N pass-agents in a SINGLE message** so they run in parallel
4. After all passes return, proceed to Phase 4 with merged findings

**Merging findings (before Phase 4):**
- Same finding (same file:line + same issue) in ≥2 passes → **HIGH CONFIDENCE**
- Finding in only 1 pass → **REVIEW** (still include, lower confidence)
- Deduplicate by file location + description similarity
- Each finding gets a confidence score: `[X/N passes]`
- HIGH CONFIDENCE findings sort first in the report

If N = 1, skip this section entirely — run Phases 1-3 as normal below.

### Phase 1: Parallel Deep Analysis

Read `agent-prompts.md` for the full prompt of each agent. **Prepend the file manifest
from Phase 0** to each agent's prompt. Then launch **7 separate
Agent tool calls (subagent_type=Explore) in a SINGLE message** so they run in parallel:

```
Agent(subagent_type="Explore", name="margaret-A-test-coverage", prompt="...")
Agent(subagent_type="Explore", name="margaret-B-business-logic", prompt="...")
Agent(subagent_type="Explore", name="margaret-C-ui-components", prompt="...")
Agent(subagent_type="Explore", name="margaret-D-data-layer", prompt="...")
Agent(subagent_type="Explore", name="margaret-E-security", prompt="...")
Agent(subagent_type="Explore", name="margaret-F-error-handling", prompt="...")
Agent(subagent_type="Explore", name="margaret-G-flow-integrity", prompt="...")
```

| Agent | Focus | Reads |
|-------|-------|-------|
| A | Test Coverage | Test files — what's tested, what's not |
| B | Business Logic Bugs + Code Duplication | Models, composables, utilities — also finds shared component opportunities |
| C | UI Component Bugs | Vue/React components |
| D | Data Layer Bugs | SQL migrations, DB functions |
| E | Security & Access | RLS, auth, input validation, secrets |
| F | Error Handling | Async errors, boundaries, retry logic |
| G | Flow Integrity | Cross-layer: UI → Composable → RPC → Guard/Trigger |

No SQL? Skip Agent D. No auth/RLS? Simplify Agent E.
No RPC calls? Skip Agent G.
Adapt agents to the module's tech stack.
**CRITICAL: 7 Agent tool calls in ONE message = parallel. Do NOT call them sequentially.**

### Phase 2: Verification

After all Phase 1 agents return, launch **1 Agent tool call (subagent_type=Explore)**
to verify top findings against CURRENT code.
Classify each as: CONFIRMED BUG / ALREADY FIXED / NOT A BUG / DESIGN CHOICE.
**This phase is NOT optional.** False positives waste the user's time.

### Phase 3: Real-World Sanity Check

Launch **1 Agent tool call (subagent_type=Explore)** using the common-sense prompt
from `agent-prompts.md`.
Finds issues that are technically correct but practically absurd.

### Phase 4: HTML Report (ALWAYS)

**This phase is NOT optional.** Every audit MUST produce an HTML report file.

**If multi-pass (N > 1):** Before generating the report, merge findings from all passes:
1. Normalize findings by file:line + issue type
2. Each finding gets a confidence badge: `[X/N passes]`
3. Sort order: HIGH CONFIDENCE (≥2 passes) first, then REVIEW (1 pass only)
4. Add a **Multi-Pass Summary** section at top of report:
   - Passes run: N
   - High confidence findings (≥2 passes agree): count
   - Review findings (1 pass only): count
   - Total unique findings: count
5. Add a **Per-Pass Breakdown** table:
   ```
   | Pass | Found | New (not in prior passes) | Overlap |
   |------|-------|---------------------------|---------|
   | 1    | 12    | 12 (baseline)             | —       |
   | 2    | 15    | 7                         | 8       |
   | 3    | 10    | 4                         | 6       |
   ```
   This shows diminishing returns clearly — helps users decide if more passes are worth it.
6. Add an **Optimal Pass Recommendation** after the table:
   - Calculate: at which pass did "New findings" drop below 10% of Pass 1's total?
   - State clearly: "Based on this audit, **[X] passes** is the sweet spot for this module — pass [X+1] onward found fewer than 10% new findings."
   - If all passes found significant new findings, say: "All [N] passes contributed meaningfully — consider running more next time."

1. Read `report-template.md` for the full HTML/CSS template
2. Generate an HTML file using the template, populated with ALL verified findings
3. Save to: `{project}/docs/audit/{module}-audit-report.html`
   - Create the `docs/audit/` directory if it doesn't exist
   - Use the module name as prefix (e.g., `store-audit-report.html`)
4. Open the file for the user: tell them the path so they can view it in browser

#### Convergence Verdict (MANDATORY in report header)

After verification, calculate and display prominently:

| Verdict | Criteria |
|---------|----------|
| **PASS** | 0 CONFIRMED CRITICAL or HIGH findings |
| **CONDITIONAL PASS** | ≤2 HIGH findings, all are design choices or have documented workarounds |
| **FAIL** | Any CONFIRMED CRITICAL, or ≥3 CONFIRMED HIGH |

A module that receives **PASS** does not need re-auditing unless code changes significantly.

#### File Coverage Summary (MANDATORY in report)

Include a table showing every file that was assigned and its status:
- Total files assigned vs total files reported on
- Any files an agent failed to report on = **COVERAGE GAP** (flag prominently)

The HTML report MUST include these sections (skip empty ones):
- **Summary cards** — counts of CRITICAL, HIGH, FIXED, DESIGN CHOICE
- **Flow diagram** — if the module has a multi-step workflow/pipeline, show guard status
- **CRITICAL bugs** — with code quotes, file:line, real-world impact
- **HIGH bugs** — same format
- **Security findings** — red cards for security issues (from Agent E)
- **Error handling gaps** — issues found by Agent F
- **Already Fixed** — show what was found but already resolved
- **Test Coverage Matrix** — table with dot indicators (green/yellow/red/gray)
- **Common Sense Issues** — "system does X / user expects Y" side-by-side cards
- **Priority Fix Order** — numbered list sorted by impact, with effort tags (Quick/Medium/Large)

After writing the HTML file, also provide a **brief markdown summary** in chat
(just the counts + top 3 priorities) so the user gets a quick overview.

## Guidelines

- **Verify before reporting** — Phase 2 is mandatory
- **Quote actual code** — exact lines, not vague descriptions
- **Focus on real impact** — wrong data > code style
- **Be specific** — "cancelling shipment doesn't recover stock" not "might break"
- **Adapt checklists** — add domain-specific checks as needed
- **Reference security-patterns.md** for OWASP-informed checks in Agent E
- **Reference checklists.md** for structured verification in all agents
- **HTML report is the primary deliverable** — not markdown tables in chat
- **Use the project's language** — if code/comments are in Thai, report can mix Thai/English
