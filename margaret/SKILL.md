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

Identify: **source code** dirs, **test** dirs, **SQL migrations** (if any).

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
| B | Business Logic Bugs | Models, composables, utilities |
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
