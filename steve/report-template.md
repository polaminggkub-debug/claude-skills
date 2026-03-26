# Steve — Design Audit HTML Report Template

Use this template to generate the Phase 3 HTML report.
Replace all `{{placeholders}}` with actual audit data.

## Design Principles

- **Light theme** with clean, professional typography (Noto Sans Thai + system-ui)
- **Score ring** at top for instant overview (0-100 scale)
- **4 scored sections** (25 pts each): Visual Design, UX Heuristics, Accessibility, Consistency
- **Finding cards** with colored left borders (red=critical, orange=high, yellow=medium, blue=info)
- **Radar chart** as inline SVG for at-a-glance category comparison
- **Heuristic scorecard** for Nielsen's 10 heuristics (scored 0-4)
- **Prioritized action items** ordered by severity x effort (quick wins first)
- **Print-friendly** and responsive

## CRITICAL: Before/After Must Be Visual Renders, NOT Code

Every finding **MUST** include a Before/After comparison that **renders visually** — the reader should SEE the problem, not read source code. Non-developers must understand the issue at a glance.

### How to create visual Before/After:

1. **Visual issues** (contrast, color, spacing, typography): Render an inline HTML mini-preview that simulates the actual UI element. Use inline styles + the project's dark/light background to show what the user actually sees.
   - Contrast issue → show text on dark bg in the actual failing color vs the fixed color
   - Color mismatch → show colored boxes/borders side by side
   - Spacing issue → show elements with the wrong gap vs the correct gap

2. **Structural issues** (missing ARIA, semantic HTML, missing icons): Show a rendered mini-UI element. For example:
   - Missing button icon → render two buttons (one without icon, one with icon)
   - Clickable span vs button → show a rendered span vs a rendered button
   - Missing label link → show a label that doesn't highlight input vs one that does

3. **Use `.preview` class** for rendered previews: dark rounded box that simulates the app's dark theme UI. Inside, use inline styles to recreate the actual element. Always show both Before and After as rendered output.

4. **Code is supplementary**: If you want to also show the code change, put it BELOW the visual preview in a small `<details>` block — never as the primary content.

### CSS for visual previews (add to template):
```css
/* Visual Preview — simulates actual UI */
.preview { background: #1e293b; border-radius: 8px; padding: 1rem; color: #e2e8f0; font-family: 'Segoe UI', system-ui, sans-serif; font-size: 0.9rem; }
.preview-dark { background: #0f172a; }
.compare-box .preview { margin-top: 0.5rem; }
```

## Template

```html
<!DOCTYPE html>
<html lang="{{lang|default:th}}">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{Page Name}} Design Audit Report</title>
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
  .report-header .subtitle { color: #e11d48; font-weight: 600; font-size: 1rem; }
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
  .score-label { font-size: 0.9rem; font-weight: 600; min-width: 120px; }
  .score-value { font-size: 0.85rem; color: #666; min-width: 40px; }

  /* Sections */
  h2 { font-size: 1.3rem; font-weight: 700; margin: 2.5rem 0 1rem; padding-bottom: 0.5rem; border-bottom: 2px solid #e5e7eb; color: #1a1a2e; }
  h3 { font-size: 1.1rem; font-weight: 600; margin: 1.5rem 0 0.75rem; }

  /* Finding Cards */
  .finding-card { background: #fafafa; border-radius: 16px; padding: 1.5rem; margin-bottom: 1rem; border-left: 5px solid #e5e7eb; page-break-inside: avoid; }
  .finding-card.critical { border-left-color: #ef4444; background: #fef2f2; }
  .finding-card.high { border-left-color: #f97316; background: #fff7ed; }
  .finding-card.medium { border-left-color: #eab308; background: #fefce8; }
  .finding-card.low { border-left-color: #3b82f6; background: #eff6ff; }
  .severity { display: inline-block; padding: 2px 12px; border-radius: 999px; font-size: 0.75rem; font-weight: 700; margin-bottom: 0.5rem; }
  .severity.critical { background: #fee2e2; color: #991b1b; }
  .severity.high { background: #ffedd5; color: #9a3412; }
  .severity.medium { background: #fef9c3; color: #854d0e; }
  .severity.low { background: #dbeafe; color: #1e40af; }
  .finding-title { font-size: 1.1rem; font-weight: 700; margin-bottom: 0.5rem; }
  .finding-desc { color: #374151; font-size: 0.95rem; }
  .finding-desc code { background: #f3f4f6; padding: 1px 6px; border-radius: 4px; font-family: 'SF Mono', 'Fira Code', monospace; font-size: 0.85em; color: #e11d48; }
  .finding-location { font-family: 'SF Mono', 'Fira Code', monospace; font-size: 0.75rem; color: #9ca3af; margin-top: 0.5rem; }
  .agent-tag { display: inline-block; padding: 2px 10px; border-radius: 999px; font-size: 0.7rem; font-weight: 600; margin-left: 0.5rem; }
  .agent-tag.visual { background: #fce7f3; color: #9d174d; }
  .agent-tag.ux { background: #ede9fe; color: #5b21b6; }
  .agent-tag.a11y { background: #d1fae5; color: #065f46; }
  .agent-tag.consistency { background: #dbeafe; color: #1e40af; }
  .confidence-tag { display: inline-block; padding: 2px 10px; border-radius: 999px; font-size: 0.7rem; font-weight: 600; margin-left: 0.5rem; background: #fef3c7; color: #92400e; }

  /* Radar Chart */
  .radar-section { text-align: center; margin: 2rem 0; }
  .radar-chart { display: inline-block; }
  .radar-chart svg { max-width: 360px; width: 100%; }

  /* Heuristic Scorecard */
  .heuristic-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; margin: 1rem 0; }
  .heuristic-table th { background: #f9fafb; padding: 0.75rem; text-align: left; border-bottom: 2px solid #e5e7eb; font-weight: 700; }
  .heuristic-table td { padding: 0.6rem 0.75rem; border-bottom: 1px solid #f3f4f6; }
  .heuristic-table tr:hover { background: #f9fafb; }
  .heuristic-score { display: inline-flex; gap: 3px; }
  .heuristic-dot { width: 14px; height: 14px; border-radius: 50%; border: 2px solid #e5e7eb; }
  .heuristic-dot.filled { background: #6366f1; border-color: #6366f1; }
  .heuristic-dot.empty { background: #ffffff; }

  /* Do/Don't Comparison */
  .compare { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin: 1rem 0; }
  .compare-box { padding: 1rem; border-radius: 12px; font-size: 0.9rem; }
  .compare-box.dont { background: #fef2f2; border: 1px solid #fecaca; }
  .compare-box.do { background: #f0fdf4; border: 1px solid #bbf7d0; }
  .compare-label { font-weight: 700; font-size: 0.8rem; margin-bottom: 0.5rem; text-transform: uppercase; letter-spacing: 1px; }
  .compare-box.dont .compare-label { color: #dc2626; }
  .compare-box.do .compare-label { color: #16a34a; }

  /* Priority Fix Order */
  .priority-list { counter-reset: p; }
  .priority-item { counter-increment: p; display: flex; align-items: flex-start; gap: 1rem; padding: 1rem 0; border-bottom: 1px solid #f3f4f6; }
  .priority-num { width: 36px; height: 36px; background: linear-gradient(135deg, #e11d48, #f43f5e); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.9rem; flex-shrink: 0; }
  .priority-content { flex: 1; }
  .priority-title { font-weight: 700; }
  .priority-title code { background: #f3f4f6; padding: 1px 5px; border-radius: 3px; font-family: 'SF Mono', 'Fira Code', monospace; font-size: 0.85em; }
  .priority-why { color: #6b7280; font-size: 0.9rem; }
  .effort-tag { display: inline-block; padding: 2px 10px; border-radius: 999px; font-size: 0.7rem; font-weight: 600; margin-left: 0.5rem; }
  .effort-tag.quick { background: #dcfce7; color: #166534; }
  .effort-tag.medium { background: #fef9c3; color: #854d0e; }
  .effort-tag.large { background: #fee2e2; color: #991b1b; }

  /* Severity x Effort Matrix */
  .matrix-table { width: 100%; border-collapse: collapse; font-size: 0.85rem; margin: 1rem 0; text-align: center; }
  .matrix-table th { background: #f9fafb; padding: 0.6rem; border: 1px solid #e5e7eb; font-weight: 600; }
  .matrix-table td { padding: 0.6rem; border: 1px solid #e5e7eb; }
  .matrix-table .quick-win { background: #dcfce7; font-weight: 700; }
  .matrix-table .do-next { background: #fef9c3; }
  .matrix-table .plan { background: #ffedd5; }
  .matrix-table .later { background: #f3f4f6; }

  /* Footer */
  .report-footer { margin-top: 3rem; padding-top: 1.5rem; border-top: 2px solid #e5e7eb; text-align: center; color: #9ca3af; font-size: 0.8rem; }

  /* Print + Responsive */
  @media print { body { padding: 1cm; max-width: 100%; } .finding-card { break-inside: avoid; } }
  @media (max-width: 640px) { .score-section { flex-direction: column; } .compare { grid-template-columns: 1fr; } body { padding: 1.5rem 1rem; } .radar-chart svg { max-width: 280px; } }
</style>
</head>
<body>

<!-- ==================== HEADER ==================== -->
<div class="report-header">
  <div class="company">{{Project Name}}</div>
  <h1>{{Page Name}} Design Audit</h1>
  <div class="subtitle">Steve — Design Critic</div>
  <div class="date">{{date}} &bull; {{stats: e.g. "4 agents &bull; 23 findings &bull; 3 critical"}}</div>
</div>

<!-- ==================== SCORE ==================== -->
<!-- Score ring: use class "good" (75-100), "warning" (40-74), "danger" (0-39) -->
<div class="score-section">
  <div class="score-ring {{good|warning|danger}}">
    <div class="number">{{score}}</div>
    <div class="out-of">/ 100</div>
  </div>
  <div class="score-breakdown">
    <div class="score-category">
      <span class="score-label">Visual Design</span>
      <div class="score-bar-bg"><div class="score-bar {{high|mid|low}}" style="width: {{percent}}%"></div></div>
      <span class="score-value">{{n}}/25</span>
    </div>
    <div class="score-category">
      <span class="score-label">UX Heuristics</span>
      <div class="score-bar-bg"><div class="score-bar {{high|mid|low}}" style="width: {{percent}}%"></div></div>
      <span class="score-value">{{n}}/25</span>
    </div>
    <div class="score-category">
      <span class="score-label">Accessibility</span>
      <div class="score-bar-bg"><div class="score-bar {{high|mid|low}}" style="width: {{percent}}%"></div></div>
      <span class="score-value">{{n}}/25</span>
    </div>
    <div class="score-category">
      <span class="score-label">Consistency</span>
      <div class="score-bar-bg"><div class="score-bar {{high|mid|low}}" style="width: {{percent}}%"></div></div>
      <span class="score-value">{{n}}/25</span>
    </div>
  </div>
</div>

<!-- ==================== RADAR CHART ==================== -->
<div class="radar-section">
  <h3>Category Overview</h3>
  <div class="radar-chart">
    <!-- Replace the polygon points with actual scores. Each axis goes from center (180,180) to edge.
         Axes: Visual (top), UX (right), A11y (bottom), Consistency (left)
         Scale: 0 = center (180,180), 25 = edge (140px radius)
         Formula: For each axis, calculate point at (score/25 * 140px) from center along that axis direction.
         Top: (180, 180 - score/25*140), Right: (180 + score/25*140, 180),
         Bottom: (180, 180 + score/25*140), Left: (180 - score/25*140, 180) -->
    <svg viewBox="0 0 360 360" xmlns="http://www.w3.org/2000/svg">
      <!-- Grid lines -->
      <polygon points="180,40 320,180 180,320 40,180" fill="none" stroke="#e5e7eb" stroke-width="1"/>
      <polygon points="180,75 285,180 180,285 75,180" fill="none" stroke="#e5e7eb" stroke-width="1"/>
      <polygon points="180,110 250,180 180,250 110,180" fill="none" stroke="#e5e7eb" stroke-width="1"/>
      <polygon points="180,145 215,180 180,215 145,180" fill="none" stroke="#e5e7eb" stroke-width="1"/>
      <!-- Axes -->
      <line x1="180" y1="40" x2="180" y2="320" stroke="#e5e7eb" stroke-width="1"/>
      <line x1="40" y1="180" x2="320" y2="180" stroke="#e5e7eb" stroke-width="1"/>
      <!-- Data polygon — replace points with actual score coordinates -->
      <polygon points="{{top_x}},{{top_y}} {{right_x}},{{right_y}} {{bottom_x}},{{bottom_y}} {{left_x}},{{left_y}}"
               fill="rgba(225,29,72,0.15)" stroke="#e11d48" stroke-width="2.5"/>
      <!-- Score dots -->
      <circle cx="{{top_x}}" cy="{{top_y}}" r="5" fill="#e11d48"/>
      <circle cx="{{right_x}}" cy="{{right_y}}" r="5" fill="#e11d48"/>
      <circle cx="{{bottom_x}}" cy="{{bottom_y}}" r="5" fill="#e11d48"/>
      <circle cx="{{left_x}}" cy="{{left_y}}" r="5" fill="#e11d48"/>
      <!-- Labels -->
      <text x="180" y="28" text-anchor="middle" font-size="13" font-weight="600" fill="#1a1a2e">Visual</text>
      <text x="335" y="184" text-anchor="start" font-size="13" font-weight="600" fill="#1a1a2e">UX</text>
      <text x="180" y="348" text-anchor="middle" font-size="13" font-weight="600" fill="#1a1a2e">A11y</text>
      <text x="25" y="184" text-anchor="end" font-size="13" font-weight="600" fill="#1a1a2e">Consistency</text>
    </svg>
  </div>
</div>

<!-- ==================== VISUAL DESIGN (Agent A) ==================== -->
<h2 style="color:#e11d48;">Visual Design</h2>

<!-- Repeat for each finding. EVERY finding MUST include a Before/After comparison. -->
<div class="finding-card critical">
  <div class="severity critical">CRITICAL</div>
  <span class="agent-tag visual">Visual</span>
  <div class="finding-title">{{finding title}}</div>
  <div class="finding-desc">
    {{description with <code>inline code</code> references}}
  </div>
  <!-- MANDATORY: Before/After example showing actual project code -->
  <div class="compare">
    <div class="compare-box dont">
      <div class="compare-label">Before</div>
      <code>{{actual code from the project showing the problem}}</code>
    </div>
    <div class="compare-box do">
      <div class="compare-label">After</div>
      <code>{{corrected code showing the fix}}</code>
    </div>
  </div>
  <div class="finding-location">{{element or component reference}}</div>
</div>

<!-- ==================== UX HEURISTICS (Agent B) ==================== -->
<h2 style="color:#7c3aed;">UX Heuristics</h2>

<!-- Heuristic Scorecard -->
<h3>Heuristic Scorecard</h3>
<table class="heuristic-table">
  <thead>
    <tr><th>#</th><th>Heuristic</th><th>Score</th><th>Key Issue</th></tr>
  </thead>
  <tbody>
    <!-- Repeat for each of the 10 heuristics -->
    <tr>
      <td>H1</td>
      <td>Visibility of system status</td>
      <td>
        <div class="heuristic-score">
          <!-- Fill dots based on score 0-4. Example: score 3 = 3 filled + 1 empty -->
          <span class="heuristic-dot filled"></span>
          <span class="heuristic-dot filled"></span>
          <span class="heuristic-dot filled"></span>
          <span class="heuristic-dot empty"></span>
        </div>
      </td>
      <td>{{brief issue or "No issues found"}}</td>
    </tr>
    <!-- H2 through H10 ... -->
  </tbody>
</table>
<p style="color:#6b7280; font-size:0.85rem; margin-top:0.5rem;">Total: {{sum}}/40 (normalized to {{normalized}}/25)</p>

<!-- UX Finding Cards — EVERY finding MUST include Before/After -->
<div class="finding-card high">
  <div class="severity high">HIGH</div>
  <span class="agent-tag ux">UX</span>
  <div class="finding-title">{{finding title}}</div>
  <div class="finding-desc">{{description}}</div>
  <div class="compare">
    <div class="compare-box dont">
      <div class="compare-label">Before</div>
      <code>{{actual code/behavior from the project}}</code>
    </div>
    <div class="compare-box do">
      <div class="compare-label">After</div>
      <code>{{corrected code/behavior}}</code>
    </div>
  </div>
  <div class="finding-location">{{element or flow reference}}</div>
</div>

<!-- ==================== ACCESSIBILITY (Agent C) ==================== -->
<h2 style="color:#059669;">Accessibility</h2>

<div class="finding-card critical">
  <div class="severity critical">CRITICAL</div>
  <span class="agent-tag a11y">A11y</span>
  <div class="finding-title">{{finding title}}</div>
  <div class="finding-desc">
    {{description — reference WCAG criterion e.g. <code>WCAG 1.4.3</code>}}
  </div>
  <!-- MANDATORY: Before/After example -->
  <div class="compare">
    <div class="compare-box dont">
      <div class="compare-label">Before</div>
      <code>{{actual code from the project}}</code>
    </div>
    <div class="compare-box do">
      <div class="compare-label">After</div>
      <code>{{corrected code}}</code>
    </div>
  </div>
  <div class="finding-location">{{element reference}}</div>
</div>

<!-- ==================== CONSISTENCY (Agent D) ==================== -->
<h2 style="color:#2563eb;">Consistency</h2>

<div class="finding-card medium">
  <div class="severity medium">MEDIUM</div>
  <span class="agent-tag consistency">Consistency</span>
  <div class="finding-title">{{finding title}}</div>
  <div class="finding-desc">{{description — note the 2+ locations where inconsistency appears}}</div>
  <!-- MANDATORY: Before/After example -->
  <div class="compare">
    <div class="compare-box dont">
      <div class="compare-label">Before</div>
      <code>{{actual inconsistent code from the project}}</code>
    </div>
    <div class="compare-box do">
      <div class="compare-label">After</div>
      <code>{{standardized code}}</code>
    </div>
  </div>
  <div class="finding-location">{{location A}} vs {{location B}}</div>
</div>

<!-- ==================== CROSS-AGENT FINDINGS ==================== -->
<h2>Cross-Agent Findings</h2>
<p style="color:#6b7280; margin-bottom:1rem;">Issues flagged by multiple agents — highest confidence</p>

<div class="finding-card critical">
  <div class="severity critical">CRITICAL</div>
  <span class="agent-tag visual">Visual</span>
  <span class="agent-tag a11y">A11y</span>
  <span class="confidence-tag">HIGH CONFIDENCE</span>
  <div class="finding-title">{{finding title — e.g. "Low contrast on secondary text"}}</div>
  <div class="finding-desc">{{merged description from multiple agents}}</div>
  <!-- MANDATORY: Before/After example -->
  <div class="compare">
    <div class="compare-box dont">
      <div class="compare-label">Before</div>
      <code>{{actual code from the project}}</code>
    </div>
    <div class="compare-box do">
      <div class="compare-label">After</div>
      <code>{{corrected code}}</code>
    </div>
  </div>
  <div class="finding-location">{{element reference}}</div>
</div>

<!-- ==================== SEVERITY x EFFORT MATRIX ==================== -->
<h2>Severity x Effort Matrix</h2>

<table class="matrix-table">
  <thead>
    <tr><th></th><th>Quick (&lt;30 min)</th><th>Medium (1-4 hrs)</th><th>Large (&gt;4 hrs)</th></tr>
  </thead>
  <tbody>
    <tr>
      <th>Critical</th>
      <td class="quick-win">{{count}} QUICK WINS</td>
      <td class="do-next">{{count}} DO NEXT</td>
      <td class="plan">{{count}} PLAN</td>
    </tr>
    <tr>
      <th>High</th>
      <td class="quick-win">{{count}} QUICK WINS</td>
      <td class="do-next">{{count}} DO NEXT</td>
      <td class="plan">{{count}} PLAN</td>
    </tr>
    <tr>
      <th>Medium</th>
      <td class="do-next">{{count}}</td>
      <td class="later">{{count}}</td>
      <td class="later">{{count}}</td>
    </tr>
    <tr>
      <th>Low</th>
      <td class="do-next">{{count}}</td>
      <td class="later">{{count}}</td>
      <td class="later">{{count}}</td>
    </tr>
  </tbody>
</table>

<!-- ==================== PRIORITY FIX ORDER ==================== -->
<h2>Priority Fix Order</h2>
<p style="color:#6b7280; margin-bottom:1rem;">Ordered by: quick wins first, then severity, then effort</p>

<div class="priority-list">
  <div class="priority-item">
    <div class="priority-num">1</div>
    <div class="priority-content">
      <div class="priority-title">{{fix title}} <span class="effort-tag {{quick|medium|large}}">{{effort label}}</span></div>
      <div class="priority-why">{{brief why + suggested approach}}</div>
    </div>
  </div>
  <!-- Repeat for each priority item -->
</div>

<!-- ==================== FOOTER ==================== -->
<div class="report-footer">
  <p>Generated by Steve — Design Critic &bull; {{date}} &bull; 4 parallel agents &bull; {{summary stats}}</p>
</div>

</body>
</html>
```

## Usage Notes

- **Score ring**: Use class `good` (75-100), `warning` (40-74), `danger` (0-39)
- **Score bars**: Use class `high` (>75%), `mid` (40-74%), `low` (<40%)
- **4 sections** map to 4 agents: Visual Design (A), UX Heuristics (B), Accessibility (C), Consistency (D)
- **Heuristic scorecard**: Show 10 rows, score 0-4 each, total /40 normalized to /25
- **Radar chart**: Calculate SVG polygon points using the formula in the template comments
- **Agent tags**: Use class `visual`, `ux`, `a11y`, `consistency` to show which agent found each issue
- **Confidence tags**: Add `HIGH CONFIDENCE` tag when 2+ agents flagged the same issue
- **Severity x Effort matrix**: Count findings in each cell, highlight quick wins
- Remove empty sections entirely rather than showing "0 items"
- Save output to: `{project_root}/docs/audit/{page}-design-audit-report.html`
- Print to PDF: `Cmd+P` in browser works cleanly
- Use the project's language for descriptions (Thai/English mix is fine)
