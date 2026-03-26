# Phase 0: File Manifest — Steve

Before launching any Phase 1 agents, build a deterministic file manifest so every Vue component is assigned and analyzed.

## Step 1: Glob All Files

Run these globs on the target module/page directory:

```
**/*.vue         → all Vue components (pages, dialogs, tabs, widgets)
**/*.ts          → composables and utilities (for understanding component behavior)
```

## Step 2: Classify & Assign Files

All 4 agents read Vue components, but with DIFFERENT checklists:

| Agent | Primary Files | Purpose |
|-------|--------------|---------|
| A: Visual Design | ALL `*.vue` components | Color, contrast, typography, spacing |
| B: UX Heuristics | ALL `*.vue` + page-level components | Nielsen's 10 heuristics, cognitive load |
| C: Accessibility | ALL `*.vue` components | WCAG 2.2 AA compliance |
| D: Consistency | ALL `*.vue` + shared component library files | Pattern consistency |

**Rules:**
- ALL agents read ALL `.vue` files — they each apply different lenses
- Agent D also reads shared/reusable component files for cross-referencing
- Every `.vue` file MUST appear in every agent's list

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
- /absolute/path/to/Component1.vue
- /absolute/path/to/Component2.vue
...

[Then include the agent's standard checklist from agent-prompts.md]
```

## Step 4: Include Previous Findings (if any)

If a previous design audit report exists at `docs/audit/{page}-design-audit-report*.html`:
1. Read the report
2. Extract CONFIRMED findings
3. Add to each agent's prompt:

```
KNOWN FINDINGS FROM PREVIOUS AUDIT (do not re-report these unless they've changed):
- [CONFIRMED] Dialog.vue — low contrast on secondary text (#999 on white)
- [CONFIRMED] Tab.vue — missing focus indicator on tab buttons
...

Focus on NEW issues or verify that known issues are still present.
```

## Step 5: Screenshot Integration (Optional)

If `agent-browser` is available and the module has a running URL:
- Take screenshots of each page/view state before launching agents
- Include screenshot paths in agent prompts for visual reference:

```
SCREENSHOTS (for visual reference — cross-check against source code):
- /path/to/screenshot-dashboard.png
- /path/to/screenshot-dialog-open.png
```

This helps agents catch visual issues that aren't obvious from reading source code alone.

## Step 6: File Count Limits

- If any agent has >30 `.vue` files, split into logical sub-groups
- Group by feature area (e.g., dialogs, tabs, shared components)

## Convergence Criteria

After Phase 2 verification, calculate the convergence verdict:

| Verdict | Criteria |
|---------|----------|
| **PASS** | Score ≥75/100, 0 CONFIRMED CRITICAL findings |
| **CONDITIONAL PASS** | Score 50-74/100, ≤2 HIGH findings |
| **FAIL** | Score <50/100, or any CONFIRMED CRITICAL |

Include this verdict prominently in the HTML report header.
