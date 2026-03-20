# Margaret — HTML Report Template

Use this template to generate the Phase 4 HTML report.
Replace all `{{placeholders}}` with actual audit data.

## Design Principles

- **Light theme** with clean, professional typography (Noto Sans Thai + system-ui)
- **Score ring** at top for instant overview
- **Risk cards** with colored left borders (red=critical, orange=high, green=fixed, blue=design, purple=security, amber=error-handling)
- **Side-by-side comparison boxes** for common sense issues ("System does" vs "User expects")
- **Effort tags** on priority items (Quick / Medium / Large)
- **Technical content** — include `<code>` inline references, `file:line` paths, code snippets
- **Print-friendly** — works in browser and prints to PDF cleanly
- **Responsive** — adapts to mobile screens

## Template

```html
<!DOCTYPE html>
<html lang="th">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{Module Name}} Audit Report</title>
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
  .report-header .subtitle { font-size: 0.95rem; color: #888; font-style: italic; margin-bottom: 0.25rem; }
  .report-header .date { color: #888; font-size: 0.9rem; }

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
  .score-breakdown { display: flex; flex-direction: column; gap: 0.5rem; }
  .score-item { display: flex; align-items: center; gap: 0.75rem; font-size: 0.95rem; }
  .score-dot { width: 14px; height: 14px; border-radius: 50%; flex-shrink: 0; }
  .score-dot.red { background: #ef4444; }
  .score-dot.orange { background: #f97316; }
  .score-dot.green { background: #22c55e; }
  .score-dot.blue { background: #3b82f6; }
  .score-dot.purple { background: #8b5cf6; }
  .score-dot.amber { background: #f59e0b; }

  /* Sections */
  h2 { font-size: 1.3rem; font-weight: 700; margin: 2.5rem 0 1rem; padding-bottom: 0.5rem; border-bottom: 2px solid #e5e7eb; color: #1a1a2e; }

  /* Flow Diagram */
  .flow-visual { display: flex; align-items: stretch; gap: 0; margin: 1.5rem 0; overflow-x: auto; }
  .flow-step { flex: 1; min-width: 110px; text-align: center; padding: 1rem 0.5rem; border-radius: 12px; }
  .flow-step .step-name { font-weight: 700; font-size: 0.95rem; }
  .flow-step .step-status { font-size: 0.75rem; margin-top: 4px; padding: 2px 8px; border-radius: 999px; display: inline-block; }
  .flow-step.safe { background: #f0fdf4; }
  .flow-step.safe .step-status { background: #dcfce7; color: #166534; }
  .flow-step.risk { background: #fef2f2; }
  .flow-step.risk .step-status { background: #fee2e2; color: #991b1b; }
  .flow-connector { display: flex; align-items: center; color: #d1d5db; font-size: 1.5rem; padding: 0 2px; }

  /* Risk Cards */
  .risk-card { background: #fafafa; border-radius: 16px; padding: 1.5rem; margin-bottom: 1rem; border-left: 5px solid #e5e7eb; page-break-inside: avoid; }
  .risk-card.critical { border-left-color: #ef4444; background: #fef2f2; }
  .risk-card.high { border-left-color: #f97316; background: #fff7ed; }
  .risk-card.fixed { border-left-color: #22c55e; background: #f0fdf4; }
  .risk-card.design { border-left-color: #3b82f6; background: #eff6ff; }
  .risk-card.security { border-left-color: #dc2626; background: #fef2f2; }
  .risk-card.error-handling { border-left-color: #d97706; background: #fffbeb; }
  .risk-level { display: inline-block; padding: 2px 12px; border-radius: 999px; font-size: 0.75rem; font-weight: 700; margin-bottom: 0.5rem; }
  .risk-level.critical { background: #fee2e2; color: #991b1b; }
  .risk-level.high { background: #ffedd5; color: #9a3412; }
  .risk-level.fixed { background: #dcfce7; color: #166534; }
  .risk-level.design { background: #dbeafe; color: #1e40af; }
  .risk-level.security { background: #fee2e2; color: #991b1b; }
  .risk-level.error-handling { background: #fef3c7; color: #92400e; }
  .risk-title { font-size: 1.1rem; font-weight: 700; margin-bottom: 0.5rem; }
  .risk-desc { color: #374151; font-size: 0.95rem; }
  .risk-desc code { background: #f3f4f6; padding: 1px 6px; border-radius: 4px; font-family: 'SF Mono', 'Fira Code', monospace; font-size: 0.85em; color: #e11d48; }
  .risk-impact { margin-top: 0.75rem; padding: 0.75rem 1rem; background: #ffffff; border-radius: 10px; font-size: 0.9rem; border: 1px solid #e5e7eb; }
  .risk-impact .label { font-weight: 600; color: #6b7280; font-size: 0.8rem; margin-bottom: 0.25rem; }
  .risk-file { font-family: 'SF Mono', 'Fira Code', monospace; font-size: 0.75rem; color: #9ca3af; margin-top: 0.5rem; }

  /* Code Snippets inside cards */
  .code-block { margin-top: 0.75rem; padding: 0.75rem 1rem; background: #1e293b; color: #e2e8f0; border-radius: 8px; font-family: 'SF Mono', 'Fira Code', monospace; font-size: 0.8rem; line-height: 1.5; overflow-x: auto; white-space: pre; }

  /* Coverage Matrix */
  .matrix { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
  .matrix th { background: #f9fafb; padding: 0.75rem; text-align: left; border-bottom: 2px solid #e5e7eb; font-weight: 700; }
  .matrix td { padding: 0.6rem 0.75rem; border-bottom: 1px solid #f3f4f6; }
  .matrix tr:hover { background: #f9fafb; }
  .dot { display: inline-block; width: 12px; height: 12px; border-radius: 50%; }
  .dot.green { background: #22c55e; }
  .dot.yellow { background: #eab308; }
  .dot.red { background: #ef4444; }
  .dot.gray { background: #d1d5db; }

  /* Comparison boxes (Common Sense) */
  .compare { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin: 1rem 0; }
  .compare-box { padding: 1rem; border-radius: 12px; font-size: 0.9rem; }
  .compare-box.now { background: #fef2f2; border: 1px solid #fecaca; }
  .compare-box.should { background: #f0fdf4; border: 1px solid #bbf7d0; }
  .compare-label { font-weight: 700; font-size: 0.8rem; margin-bottom: 0.5rem; text-transform: uppercase; letter-spacing: 1px; }
  .compare-box.now .compare-label { color: #dc2626; }
  .compare-box.should .compare-label { color: #16a34a; }
  .compare-box code { background: rgba(0,0,0,0.06); padding: 1px 5px; border-radius: 3px; font-family: 'SF Mono', 'Fira Code', monospace; font-size: 0.85em; }

  /* Priority List */
  .priority-list { counter-reset: p; }
  .priority-item { counter-increment: p; display: flex; align-items: flex-start; gap: 1rem; padding: 1rem 0; border-bottom: 1px solid #f3f4f6; }
  .priority-num { width: 36px; height: 36px; background: linear-gradient(135deg, #6366f1, #8b5cf6); color: white; border-radius: 50%; display: flex; align-items; justify-content: center; font-weight: 800; font-size: 0.9rem; flex-shrink: 0; }
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
  @media print { body { padding: 1cm; max-width: 100%; } .risk-card { break-inside: avoid; } }
  @media (max-width: 640px) { .score-section { flex-direction: column; } .compare { grid-template-columns: 1fr; } body { padding: 1.5rem 1rem; } }
</style>
</head>
<body>

<!-- ==================== HEADER ==================== -->
<div class="report-header">
  <div class="company">{{Project Name}}</div>
  <h1>{{Module Name}} Audit Report</h1>
  <div class="subtitle">Margaret — named after Margaret Hamilton, zero-defect Apollo flight software engineer</div>
  <div class="date">{{date}} &bull; {{stats: e.g. "24 test files &bull; 55+ SQL migrations &bull; 26 Vue components"}}</div>
</div>

<!-- ==================== SCORE ==================== -->
<!-- Score ring: use class "good" (8-10), "warning" (5-7), "danger" (0-4) -->
<div class="score-section">
  <div class="score-ring {{good|warning|danger}}">
    <div class="number">{{score}}</div>
    <div class="out-of">/ 10</div>
  </div>
  <div class="score-breakdown">
    <div class="score-item"><div class="score-dot red"></div> {{critical_count}} critical bugs</div>
    <div class="score-item"><div class="score-dot orange"></div> {{high_count}} high bugs</div>
    <div class="score-item"><div class="score-dot purple"></div> {{security_count}} security issues</div>
    <div class="score-item"><div class="score-dot amber"></div> {{error_handling_count}} error handling gaps</div>
    <div class="score-item"><div class="score-dot green"></div> {{fixed_count}} already fixed</div>
    <div class="score-item"><div class="score-dot blue"></div> {{design_count}} design choices</div>
  </div>
</div>

<!-- ==================== FLOW DIAGRAM (optional — use if module has multi-step workflow) ==================== -->
<!--
<h2>{{Workflow Title}}</h2>
<p style="color:#6b7280; margin-bottom:0.5rem;">{{brief description of the pipeline}}</p>
<div class="flow-visual">
  <div class="flow-step safe">
    <div class="step-name">Step 1</div>
    <div class="step-status">guarded</div>
  </div>
  <div class="flow-connector">&rarr;</div>
  <div class="flow-step risk">
    <div class="step-name">Step 2</div>
    <div class="step-status">no guard</div>
  </div>
</div>
-->

<!-- ==================== CRITICAL BUGS ==================== -->
<h2 style="color:#dc2626;">Critical Bugs</h2>

<!-- Repeat for each critical bug -->
<div class="risk-card critical">
  <div class="risk-level critical">CRITICAL</div>
  <div class="risk-title">#{{n}} {{bug title}}</div>
  <div class="risk-desc">
    {{description with <code>inline code</code> references}}
  </div>
  <!-- Optional: code snippet showing the actual buggy code -->
  <!--
  <div class="code-block">{{relevant code snippet, 3-8 lines max}}</div>
  -->
  <div class="risk-impact">
    <div class="label">Impact</div>
    {{real-world consequence in plain language}}
  </div>
  <div class="risk-file">{{file/path.ts:line-range}}</div>
</div>

<!-- ==================== HIGH BUGS ==================== -->
<h2 style="color:#9a3412;">High Bugs</h2>

<div class="risk-card high">
  <div class="risk-level high">HIGH</div>
  <div class="risk-title">#{{n}} {{bug title}}</div>
  <div class="risk-desc">{{description with <code>code</code> refs}}</div>
  <div class="risk-file">{{file/path.ts:line-range}}</div>
</div>

<!-- ==================== SECURITY FINDINGS ==================== -->
<h2 style="color:#dc2626;">Security Findings</h2>

<!-- Repeat for each security finding from Agent E -->
<div class="risk-card security">
  <div class="risk-level security">SECURITY</div>
  <div class="risk-title">#{{n}} {{finding title}}</div>
  <div class="risk-desc">
    {{description — include OWASP category reference, e.g. "OWASP #1: Broken Access Control"}}
    <br><code>{{relevant code snippet inline}}</code>
  </div>
  <div class="risk-impact">
    <div class="label">Attack Vector</div>
    {{how an attacker could exploit this}}
  </div>
  <div class="risk-file">{{file/path.ts:line-range}}</div>
</div>

<!-- ==================== ERROR HANDLING GAPS ==================== -->
<h2 style="color:#d97706;">Error Handling Gaps</h2>

<!-- Repeat for each error handling issue from Agent F -->
<div class="risk-card error-handling">
  <div class="risk-level error-handling">ERROR HANDLING</div>
  <div class="risk-title">#{{n}} {{issue title}}</div>
  <div class="risk-desc">
    {{description — what happens when it fails}}
  </div>
  <!--
  <div class="code-block">{{code showing the missing error handling}}</div>
  -->
  <div class="risk-impact">
    <div class="label">Failure Scenario</div>
    {{what the user experiences when this fails}}
  </div>
  <div class="risk-file">{{file/path.ts:line-range}}</div>
</div>

<!-- ==================== ALREADY FIXED ==================== -->
<h2 style="color:#16a34a;">Already Fixed</h2>

<div class="risk-card fixed">
  <div class="risk-level fixed">FIXED</div>
  <div class="risk-title">{{original problem}}</div>
  <div class="risk-desc">{{how/where it was fixed — e.g. "Fixed in migration 108"}}</div>
</div>

<!-- ==================== TEST COVERAGE MATRIX ==================== -->
<h2>Test Coverage Matrix</h2>
<table class="matrix">
  <thead>
    <tr><th>Category</th><th>Level</th><th>Notes</th></tr>
  </thead>
  <tbody>
    <!-- green = well tested, yellow = partial, red = weak, gray = none -->
    <tr><td>{{category}}</td><td><span class="dot green"></span> Good</td><td>{{details}}</td></tr>
    <tr><td>{{category}}</td><td><span class="dot yellow"></span> Partial</td><td>{{details}}</td></tr>
    <tr><td>{{category}}</td><td><span class="dot red"></span> Weak</td><td>{{details}}</td></tr>
    <tr><td>{{category}}</td><td><span class="dot gray"></span> None</td><td>{{details}}</td></tr>
  </tbody>
</table>

<!-- ==================== DESIGN CHOICES (optional) ==================== -->
<!--
<h2 style="color:#1e40af;">Design Choices</h2>
<div class="risk-card design">
  <div class="risk-level design">DESIGN</div>
  <div class="risk-title">{{behavior}}</div>
  <div class="risk-desc">{{potential user confusion}}</div>
  <div class="risk-file">{{file reference}}</div>
</div>
-->

<!-- ==================== COMMON SENSE ISSUES ==================== -->
<h2>Common Sense Issues</h2>

<!-- Repeat for each scenario. Include code refs in the comparison boxes. -->
<div class="risk-card" style="border-left-color:#8b5cf6; background:#faf5ff;">
  <div class="risk-title">{{n}}. {{scenario title}}</div>
  <div class="compare">
    <div class="compare-box now">
      <div class="compare-label">System does</div>
      {{what actually happens — can include <code>code refs</code>}}
    </div>
    <div class="compare-box should">
      <div class="compare-label">User expects</div>
      {{what should happen}}
    </div>
  </div>
</div>

<!-- ==================== PRIORITY FIX ORDER ==================== -->
<h2>Priority Fix Order</h2>

<div class="priority-list">
  <div class="priority-item">
    <div class="priority-num">1</div>
    <div class="priority-content">
      <div class="priority-title">{{fix title}} <span class="effort-tag {{quick|medium|large}}">{{Quick Fix|Medium Effort|Large Effort}}</span></div>
      <div class="priority-why">{{brief why + suggested approach with <code>code</code> if helpful}}</div>
    </div>
  </div>
  <!-- Repeat for each priority item -->
</div>

<!-- ==================== FOOTER ==================== -->
<div class="report-footer">
  <p>Generated by Margaret &bull; {{date}} &bull; 6 parallel agents &bull; {{file counts summary}}</p>
  <p style="font-size: 0.7rem; margin-top: 0.25rem; color: #b0b0b0;">Named after Margaret Hamilton — who wrote zero-defect Apollo flight software</p>
</div>

</body>
</html>
```

## Usage Notes

- **Score ring**: Use class `good` (8-10), `warning` (5-7), `danger` (0-4) to color the ring
- **Flow diagram** is optional — only include if the module has a multi-step workflow/pipeline
- **Design Choices section** is optional — only include if there are design choices to highlight
- **Security Findings section**: Always include if Agent E found any issues. Use red cards with OWASP references.
- **Error Handling Gaps section**: Always include if Agent F found any issues. Use amber cards with failure scenario descriptions.
- **Code snippets** (`<div class="code-block">`) are optional — use for particularly important bugs where seeing the actual code helps
- **Effort tags**: Every priority fix item MUST include an effort tag:
  - `quick` — Can be fixed in < 30 minutes (e.g., add a null check, add a guard)
  - `medium` — Takes 1-4 hours (e.g., add error boundary, implement retry logic)
  - `large` — Takes a day or more (e.g., add RLS policies, implement audit trail)
- Remove empty sections entirely rather than showing "0 items"
- **Technical content is the default** — always include `<code>` refs, `file:line` paths, and inline code. This is a developer report, not an executive summary
- Use the project's language for descriptions (Thai/English mix is fine)
- All `{{placeholders}}` must be replaced with actual audit data
- The CSS is self-contained — only external dependency is Google Fonts (Noto Sans Thai)
- Save output to: `{project_root}/docs/audit/{module}-audit-report.html`
- **Print to PDF**: The template is print-friendly — `Cmd+P` in browser works cleanly
