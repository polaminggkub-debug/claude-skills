# Chris — Test Audit HTML Report Template

Use this template to generate the Phase 4 HTML report.
Replace all `{{placeholders}}` with actual audit data.

## Design Principles

- **Light theme** with clean, professional typography (Noto Sans Thai + system-ui)
- **Score ring** at top for instant overview (0-100 scale)
- **4 scored sections** (25 pts each): Validity, ROI & Trim, Performance, Architecture
- **Architecture Map** showing unit decomposition of the audited module
- **Risk cards** with colored left borders (red=critical, orange=high, yellow=medium, green=fixed)
- **Anti-pattern match cards** showing which of the 18 patterns were found
- **Print-friendly** and responsive

## Template

```html
<!DOCTYPE html>
<html lang="th">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{Module Name}} Test Audit Report</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+Thai:wght@300;400;600;700;800&display=swap');

  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    font-family: 'Noto Sans Thai', system-ui, sans-serif;
    background: #ffffff; color: #1a1a2e;
    line-height: 1.8; max-width: 960px;
    margin: 0 auto; padding: 3rem 2rem;
  }

  /* Header */
  .report-header { text-align: center; padding-bottom: 2rem; border-bottom: 3px solid #1a1a2e; margin-bottom: 2.5rem; }
  .report-header .company { font-size: 0.9rem; color: #666; letter-spacing: 2px; text-transform: uppercase; }
  .report-header h1 { font-size: 1.8rem; font-weight: 800; margin: 0.5rem 0; }
  .report-header .subtitle { color: #6366f1; font-weight: 600; font-size: 1rem; }
  .report-header .date { color: #888; font-size: 0.9rem; margin-top: 0.25rem; }

  /* Score Ring */
  .score-section { display: flex; align-items: center; justify-content: center; gap: 3rem; margin: 2.5rem 0; flex-wrap: wrap; }
  .score-ring { width: 160px; height: 160px; border-radius: 50%; display: flex; flex-direction: column; align-items: center; justify-content: center; position: relative; }
  .score-ring::before { content: ''; position: absolute; inset: 0; border-radius: 50%; border: 8px solid #f0f0f0; }
  .score-ring.good::before { border-color: #dcfce7; border-top-color: #22c55e; border-right-color: #22c55e; border-bottom-color: #22c55e; }
  .score-ring.warning::before { border-color: #fff3cd; border-top-color: #f59e0b; border-right-color: #f59e0b; }
  .score-ring.danger::before { border-color: #fee2e2; border-top-color: #ef4444; }
  .score-ring .number { font-size: 3rem; font-weight: 800; }
  .score-ring .out-of { font-size: 0.85rem; color: #888; }
  .score-ring.good .number { color: #16a34a; }
  .score-ring.warning .number { color: #d97706; }
  .score-ring.danger .number { color: #dc2626; }

  /* Score Breakdown */
  .score-breakdown { display: flex; flex-direction: column; gap: 0.75rem; }
  .score-category { display: flex; align-items: center; gap: 0.75rem; }
  .score-bar-bg { width: 120px; height: 8px; background: #f0f0f0; border-radius: 4px; overflow: hidden; }
  .score-bar { height: 100%; border-radius: 4px; }
  .score-bar.high { background: #22c55e; }
  .score-bar.mid { background: #f59e0b; }
  .score-bar.low { background: #ef4444; }
  .score-label { font-size: 0.9rem; font-weight: 600; min-width: 100px; }
  .score-value { font-size: 0.85rem; color: #666; min-width: 40px; }

  /* Sections */
  h2 { font-size: 1.3rem; font-weight: 700; margin: 2.5rem 0 1rem; padding-bottom: 0.5rem; border-bottom: 2px solid #e5e7eb; color: #1a1a2e; }

  /* Finding Cards */
  .finding-card { background: #fafafa; border-radius: 16px; padding: 1.5rem; margin-bottom: 1rem; border-left: 5px solid #e5e7eb; page-break-inside: avoid; }
  .finding-card.critical { border-left-color: #ef4444; background: #fef2f2; }
  .finding-card.high { border-left-color: #f97316; background: #fff7ed; }
  .finding-card.medium { border-left-color: #eab308; background: #fefce8; }
  .finding-card.fixed { border-left-color: #22c55e; background: #f0fdf4; }
  .severity { display: inline-block; padding: 2px 12px; border-radius: 999px; font-size: 0.75rem; font-weight: 700; margin-bottom: 0.5rem; }
  .severity.critical { background: #fee2e2; color: #991b1b; }
  .severity.high { background: #ffedd5; color: #9a3412; }
  .severity.medium { background: #fef9c3; color: #854d0e; }
  .severity.fixed { background: #dcfce7; color: #166534; }
  .finding-title { font-size: 1.1rem; font-weight: 700; margin-bottom: 0.5rem; }
  .finding-desc { color: #374151; font-size: 0.95rem; }
  .finding-desc code { background: #f3f4f6; padding: 1px 6px; border-radius: 4px; font-family: 'SF Mono', 'Fira Code', monospace; font-size: 0.85em; color: #e11d48; }
  .finding-file { font-family: 'SF Mono', 'Fira Code', monospace; font-size: 0.75rem; color: #9ca3af; margin-top: 0.5rem; }

  /* Anti-pattern Tag */
  .pattern-tag { display: inline-block; padding: 2px 10px; border-radius: 999px; font-size: 0.7rem; font-weight: 600; background: #ede9fe; color: #5b21b6; margin-left: 0.5rem; }

  /* Architecture Map */
  .arch-map { background: #f8fafc; border: 2px solid #e2e8f0; border-radius: 16px; padding: 1.5rem; margin: 1.5rem 0; }
  .arch-map h3 { font-size: 1.1rem; font-weight: 700; margin-bottom: 1rem; color: #334155; }
  .unit-row { display: flex; align-items: center; gap: 0.75rem; padding: 0.5rem 0; border-bottom: 1px solid #f1f5f9; }
  .unit-type { display: inline-block; padding: 2px 10px; border-radius: 999px; font-size: 0.7rem; font-weight: 600; min-width: 80px; text-align: center; }
  .unit-type.pure-logic { background: #dbeafe; color: #1e40af; }
  .unit-type.io { background: #dcfce7; color: #166534; }
  .unit-type.orchestrator { background: #fef9c3; color: #854d0e; }
  .unit-type.utility { background: #f3e8ff; color: #6b21a8; }
  .unit-name { font-weight: 600; font-family: 'SF Mono', 'Fira Code', monospace; font-size: 0.85rem; }
  .unit-spec { color: #64748b; font-size: 0.85rem; }
  .unit-test-status { font-size: 0.75rem; font-weight: 600; }
  .unit-test-status.tested { color: #16a34a; }
  .unit-test-status.missing { color: #dc2626; }
  .unit-test-status.skip { color: #9ca3af; }

  /* Code Blocks */
  .code-block { margin-top: 0.75rem; padding: 0.75rem 1rem; background: #1e293b; color: #e2e8f0; border-radius: 8px; font-family: 'SF Mono', 'Fira Code', monospace; font-size: 0.8rem; line-height: 1.5; overflow-x: auto; white-space: pre; }

  /* Do/Don't Comparison */
  .compare { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin: 1rem 0; }
  .compare-box { padding: 1rem; border-radius: 12px; font-size: 0.9rem; }
  .compare-box.dont { background: #fef2f2; border: 1px solid #fecaca; }
  .compare-box.do { background: #f0fdf4; border: 1px solid #bbf7d0; }
  .compare-label { font-weight: 700; font-size: 0.8rem; margin-bottom: 0.5rem; text-transform: uppercase; letter-spacing: 1px; }
  .compare-box.dont .compare-label { color: #dc2626; }
  .compare-box.do .compare-label { color: #16a34a; }

  /* Coverage Table */
  .coverage-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; margin: 1rem 0; }
  .coverage-table th { background: #f9fafb; padding: 0.75rem; text-align: left; border-bottom: 2px solid #e5e7eb; font-weight: 700; }
  .coverage-table td { padding: 0.6rem 0.75rem; border-bottom: 1px solid #f3f4f6; }
  .coverage-table tr:hover { background: #f9fafb; }
  .dot { display: inline-block; width: 12px; height: 12px; border-radius: 50%; }
  .dot.covered { background: #22c55e; }
  .dot.partial { background: #eab308; }
  .dot.missing { background: #ef4444; }
  .dot.na { background: #d1d5db; }

  /* Priority Fix Order */
  .priority-list { counter-reset: p; }
  .priority-item { counter-increment: p; display: flex; align-items: flex-start; gap: 1rem; padding: 1rem 0; border-bottom: 1px solid #f3f4f6; }
  .priority-num { width: 36px; height: 36px; background: linear-gradient(135deg, #6366f1, #8b5cf6); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.9rem; flex-shrink: 0; }
  .priority-content { flex: 1; }
  .priority-title { font-weight: 700; }
  .priority-title code { background: #f3f4f6; padding: 1px 5px; border-radius: 3px; font-family: 'SF Mono', 'Fira Code', monospace; font-size: 0.85em; }
  .priority-why { color: #6b7280; font-size: 0.9rem; }
  .effort-tag { display: inline-block; padding: 2px 10px; border-radius: 999px; font-size: 0.7rem; font-weight: 600; margin-left: 0.5rem; }
  .effort-tag.quick { background: #dcfce7; color: #166534; }
  .effort-tag.medium { background: #fef9c3; color: #854d0e; }
  .effort-tag.large { background: #fee2e2; color: #991b1b; }

  /* Footer */
  .report-footer { margin-top: 3rem; padding-top: 1.5rem; border-top: 2px solid #e5e7eb; text-align: center; color: #9ca3af; font-size: 0.8rem; }

  /* Print + Responsive */
  @media print { body { padding: 1cm; max-width: 100%; } .finding-card { break-inside: avoid; } }
  @media (max-width: 640px) { .score-section { flex-direction: column; } .compare { grid-template-columns: 1fr; } body { padding: 1.5rem 1rem; } }
</style>
</head>
<body>

<!-- ==================== HEADER ==================== -->
<div class="report-header">
  <div class="company">{{Project Name}}</div>
  <h1>{{Module Name}} Test Audit</h1>
  <div class="subtitle">Chris — Testable Architect</div>
  <div class="date">{{date}} &bull; {{stats: e.g. "12 test files &bull; 85 test cases &bull; 3 page objects"}}</div>
</div>

<!-- ==================== SCORE ==================== -->
<div class="score-section">
  <div class="score-ring {{good|warning|danger}}">
    <div class="number">{{score}}</div>
    <div class="out-of">/ 100</div>
  </div>
  <div class="score-breakdown">
    <div class="score-category">
      <span class="score-label">Validity</span>
      <div class="score-bar-bg"><div class="score-bar {{high|mid|low}}" style="width: {{percent}}%"></div></div>
      <span class="score-value">{{n}}/25</span>
    </div>
    <div class="score-category">
      <span class="score-label">ROI & Trim</span>
      <div class="score-bar-bg"><div class="score-bar {{high|mid|low}}" style="width: {{percent}}%"></div></div>
      <span class="score-value">{{n}}/25</span>
    </div>
    <div class="score-category">
      <span class="score-label">Performance</span>
      <div class="score-bar-bg"><div class="score-bar {{high|mid|low}}" style="width: {{percent}}%"></div></div>
      <span class="score-value">{{n}}/25</span>
    </div>
    <div class="score-category">
      <span class="score-label">Architecture</span>
      <div class="score-bar-bg"><div class="score-bar {{high|mid|low}}" style="width: {{percent}}%"></div></div>
      <span class="score-value">{{n}}/25</span>
    </div>
  </div>
</div>

<!-- ==================== ARCHITECTURE MAP (NEW) ==================== -->
<h2 style="color:#334155;">Architecture Map</h2>

<div class="arch-map">
  <h3>Unit Decomposition: {{Module Name}}</h3>
  <!-- Repeat for each identified unit -->
  <div class="unit-row">
    <span class="unit-type pure-logic">Pure Logic</span>
    <span class="unit-name">{{functionName}}</span>
    <span class="unit-spec">{{one-line spec}}</span>
    <span class="unit-test-status tested">Happy path: tested</span>
  </div>
  <div class="unit-row">
    <span class="unit-type io">I/O</span>
    <span class="unit-name">{{functionName}}</span>
    <span class="unit-spec">{{one-line spec}}</span>
    <span class="unit-test-status missing">Happy path: MISSING</span>
  </div>
  <div class="unit-row">
    <span class="unit-type orchestrator">Orchestrator</span>
    <span class="unit-name">{{componentName}}</span>
    <span class="unit-spec">thin wiring — skip</span>
    <span class="unit-test-status skip">Skip</span>
  </div>
</div>

<!-- ==================== HAPPY PATH COVERAGE ==================== -->
<h2 style="color:#16a34a;">Happy Path Coverage</h2>

<div class="finding-card" style="border-left-color:#16a34a; background:#f0fdf4;">
  <div class="finding-title">Happy Path Status</div>
  <div class="finding-desc">
    Units with happy path: <strong>{{n}}/{{total}}</strong><br>
    Missing happy paths: <strong>{{list of units without happy path}}</strong>
  </div>
</div>

<!-- ==================== VALIDITY ISSUES (Agent A) ==================== -->
<h2 style="color:#dc2626;">Validity Issues</h2>

<div class="finding-card critical">
  <div class="severity critical">CRITICAL</div>
  <span class="pattern-tag">Anti-pattern #{{n}}</span>
  <div class="finding-title">{{finding title}}</div>
  <div class="finding-desc">{{description}}</div>
  <div class="finding-file">{{test-file.spec.ts:line-range}}</div>
</div>

<!-- ==================== ROI & TRIM (Agent B) ==================== -->
<h2 style="color:#f97316;">ROI & Trim</h2>

<div class="finding-card" style="border-left-color:#6366f1; background:#f5f3ff;">
  <div class="finding-title">Test Budget</div>
  <div class="finding-desc">
    Current: <strong>{{N}} E2E tests</strong>, {{time}} total runtime<br>
    Budget: <strong>20-30 E2E tests</strong>, &lt; 3 minutes runtime<br>
    Status: <strong>{{OVER BUDGET / ON BUDGET / UNDER BUDGET}}</strong>
  </div>
</div>

<h3 style="margin-top: 1.5rem; font-weight: 600;">Tests to Remove</h3>
<div class="finding-card medium">
  <div class="severity medium">REMOVE</div>
  <div class="finding-title">{{test name}}</div>
  <div class="finding-desc">{{reason}}</div>
  <div class="finding-file">{{file:line}}</div>
</div>

<h3 style="margin-top: 1.5rem; font-weight: 600;">Downgrade to Integration/Unit Tests</h3>
<div class="finding-card" style="border-left-color:#eab308; background:#fefce8;">
  <div class="finding-title">{{test name}}</div>
  <div class="finding-desc">{{reason — tests DB logic/business logic, doesn't need browser}}</div>
  <div class="finding-file">{{file:line}}</div>
</div>

<!-- ==================== PERFORMANCE ISSUES (Agent C) ==================== -->
<h2 style="color:#eab308;">Performance Issues</h2>

<div class="finding-card medium">
  <div class="severity medium">MEDIUM</div>
  <div class="finding-title">{{issue title}}</div>
  <div class="finding-desc">{{description}}</div>
  <div class="finding-file">{{file:line}}</div>
</div>

<!-- ==================== ARCHITECTURE ISSUES (Agent D) ==================== -->
<h2 style="color:#6366f1;">Architecture & Testability Issues</h2>

<div class="finding-card high">
  <div class="severity high">HIGH</div>
  <div class="finding-title">{{issue title}}</div>
  <div class="finding-desc">{{description}}</div>
  <div class="finding-file">{{file:line}}</div>
</div>

<!-- ==================== ANTI-PATTERN MATCHES ==================== -->
<h2>Anti-Pattern Matches</h2>
<p style="color:#6b7280; margin-bottom:1rem;">Matched against 18 known anti-patterns</p>

<div class="finding-card" style="border-left-color:#8b5cf6; background:#faf5ff;">
  <span class="pattern-tag">#{{n}} {{pattern name}}</span>
  <div class="finding-title" style="margin-top:0.5rem;">{{where found}}</div>
  <div class="finding-desc">{{description}}</div>
  <div class="compare">
    <div class="compare-box dont">
      <div class="compare-label">Current Code</div>
      {{actual code}}
    </div>
    <div class="compare-box do">
      <div class="compare-label">Recommended Fix</div>
      {{how to fix}}
    </div>
  </div>
  <div class="finding-file">{{file:line}}</div>
</div>

<!-- ==================== COMMON SENSE ==================== -->
<h2>Common Sense Issues</h2>

<div class="finding-card" style="border-left-color:#8b5cf6; background:#faf5ff;">
  <div class="finding-title">{{observation}}</div>
  <div class="finding-desc">{{why this matters}}</div>
</div>

<!-- ==================== PRIORITY FIX ORDER ==================== -->
<h2>Priority Fix Order</h2>

<div class="priority-list">
  <div class="priority-item">
    <div class="priority-num">1</div>
    <div class="priority-content">
      <div class="priority-title">{{fix title}} <span class="effort-tag {{quick|medium|large}}">{{effort}}</span></div>
      <div class="priority-why">{{why + approach}}</div>
    </div>
  </div>
</div>

<!-- ==================== FOOTER ==================== -->
<div class="report-footer">
  <p>Generated by Chris — Testable Architect &bull; {{date}} &bull; 4 parallel agents &bull; {{summary stats}}</p>
</div>

</body>
</html>
```

## Usage Notes

- **Score ring**: Use class `good` (75-100), `warning` (40-74), `danger` (0-39)
- **Score bars**: Use class `high` (>75%), `mid` (40-74%), `low` (<40%)
- **Architecture Map**: NEW section — show unit decomposition with type badges and happy path status
- **4 sections** map to 4 agents: Validity (A), ROI & Trim (B), Performance (C), Architecture (D)
- Remove empty sections entirely rather than showing "0 items"
- Anti-pattern matches reference the 18 patterns from `anti-patterns.md` by number
- Save output to: `{project_root}/docs/audit/{module}-test-audit-report.html`
- Print to PDF: `Cmd+P` in browser works cleanly
- Use the project's language for descriptions (Thai/English mix is fine)
