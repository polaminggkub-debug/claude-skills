---
name: formpress
description: >
  Named after the printing press — precise data positioning on pre-printed paper forms.
  Guides the workflow of printing data (text, numbers, dates) onto existing physical
  forms so output aligns perfectly with pre-printed fields.
  Triggers: "print on form", "พิมพ์ลงแบบฟอร์ม", "form overlay", "preprinted form",
  "formpress", "พิมพ์ลงกระดาษ", "ปริ้นลงฟอร์ม", "position data on paper",
  "พิมพ์ตรงช่อง", "วางตำแหน่งข้อมูลลงกระดาษ".
  Use this skill whenever the user needs to print data onto paper that already has
  printed lines, boxes, or labels — even if they don't say "form overlay" explicitly.
  Also trigger when discussing PDF coordinate positioning for physical printing,
  calibrating printer output, or creating print templates for existing paper forms.
---

# Formpress — Precise Print-on-Form Positioning

Print data onto pre-printed paper forms with pixel-perfect accuracy.
Named after the printing press — because every character must land exactly where it belongs.

## Reference Files

- `references/conversion-table.md` — Unit conversion formulas (mm↔pt↔px), paper sizes
- `references/calibration-guide.md` — Printer calibration workflow + offset adjustment
- `references/jspdf-patterns.md` — jsPDF code patterns for absolute positioning (Thai font ready)
- `data/paper-sizes.csv` — Standard paper dimensions lookup

Read reference files as needed during the workflow — don't load all at once.

## Modes (Auto-Detected)

| User says | Formpress does |
|-----------|----------------|
| "พิมพ์ลงฟอร์มนี้", "print on this form", [image] | **New Template** → Full interview workflow |
| "ปรับตำแหน่ง", "shift", "offset", "เลื่อน" | **Adjust** → Modify existing template positions |
| "calibrate", "ทดสอบเครื่องพิมพ์", "ปรับจูน" | **Calibrate** → Generate calibration page |
| "preview", "ดูตัวอย่าง" | **Preview** → Overlay data on scanned form image |

---

## New Template Mode — Full Workflow

### Phase 1: Interview

Ask the user these questions (skip any already answered in conversation):

1. **Paper size** — "กระดาษขนาดอะไรครับ? (A4, A5, B5, หรือวัดเป็น mm)"
   - Read `data/paper-sizes.csv` if user gives a standard name
2. **Form image** — "มีรูปสแกนหรือถ่ายแบบฟอร์มไหมครับ? (ถ้าถ่ายจากโทรศัพท์ แนะนำใช้แอป Scan ในเครื่องจะได้ภาพตรงกว่า)"
3. **Fields to print** — "ข้อมูลที่ต้องพิมพ์ลงไปมีอะไรบ้างครับ? (เช่น ชื่อบริษัท, วันที่, รายการสินค้า, จำนวนเงิน)"
4. **Field positions** — Determine positions using ONE of these methods:
   - **Method A: From scan** — User provides scanned image + paper size → calculate scale, estimate positions, confirm with user
   - **Method B: Manual measurement** — User measures with ruler → provides mm from left edge and top edge
   - **Method C: From existing PDF** — User has a PDF template → read coordinates directly
5. **Data source** — "ข้อมูลจะดึงมาจากไหนครับ? (object/interface ที่จะส่งเข้ามา)"
6. **Font requirements** — Default: THSarabun (project standard). Ask if different font needed.

### Phase 2: Calculate & Map

Read `references/conversion-table.md` for formulas.

For each field from the interview:
1. Convert position from user's unit (mm/cm/inches) to jsPDF mm coordinates
2. Account for paper orientation (portrait/landscape)
3. Build a field map and present to user for confirmation:

```typescript
interface FormField {
  name: string           // field identifier
  label: string          // Thai display name
  x_mm: number           // from left edge
  y_mm: number           // from top edge
  width_mm?: number      // max width (for text wrapping)
  fontSize: number       // in points
  fontStyle: 'normal' | 'bold'
  align: 'left' | 'center' | 'right'
}
```

If user provided a scan image:
- Read the image to understand form layout visually
- Ask: "ขนาดกระดาษจริงกว้าง x สูง เท่าไหร่ mm?" (if not standard size)
- Calculate: `scale = paper_width_mm / image_width_px`
- For each field, estimate position from the image and confirm with user:
  "ช่อง [field name] ผมเห็นอยู่ประมาณ x=35mm, y=52mm จากขอบซ้ายบน — ตรงไหมครับ?"
- Note: image-based estimates are approximate (±2-5mm). User should verify with ruler on the actual form for best results.

### Phase 3: Generate Code

Read `references/jspdf-patterns.md` for code templates.

Generate a TypeScript function following the project's existing pattern:
- Lazy import jsPDF (match `deliveryBillPDF.ts` style)
- Register Thai fonts via `fetchAsBase64` + `FONT_BASE` pattern
- Use mm unit system throughout (`new jsPDF({ unit: 'mm', format: 'a4' })`)
- Place each field using `doc.text(text, x, y, options)`
- For table/repeating fields: manual row iteration with y increment per row
- Print ONLY data — no borders, no lines, no background
- Export as `generate{FormName}PDF(data: FormData): Promise<void>`
- Open via `window.open(doc.output('bloburl'))`

### Phase 4: Overlay Preview

Generate a preview function (for screen verification only):
- Embeds the scanned form image as background (full page)
- Overlays the data fields on top in red color
- Adds crosshair markers (+) at each field origin point
- User compares on screen before printing on actual form paper

### Phase 5: Calibration

Read `references/calibration-guide.md`.

If user reports misalignment after printing:
1. Generate calibration page → user prints on plain paper
2. User measures actual crosshair positions with ruler
3. Calculate offset: `dx = actual_x - expected_x`, `dy = actual_y - expected_y`
4. Apply offset to all field positions in the template

### Phase 6: Fine-Tune Loop

After first test print, apply adjustments as requested:
- "เลื่อนทุก field ไปขวา 2mm" → add dx to all x_mm
- "ช่องวันที่ขึ้นไปอีก 1mm" → subtract 1 from that field's y_mm
- "ตัวอักษรเล็กไป" → increase fontSize

Regenerate and repeat until user confirms alignment.

---

## Adjust Mode

For modifying an existing formpress template:

1. Read the existing PDF generation file
2. Parse the field positions from code
3. Apply the requested adjustment (shift, resize, reposition)
4. Show before/after comparison of changed values
5. Regenerate the function

---

## Calibrate Mode

1. Read `references/calibration-guide.md`
2. Generate calibration page with crosshairs at known positions
3. Ask user to print and measure
4. Calculate printer offset (dx_mm, dy_mm)
5. Apply offset to template — either as constants in code or as function parameters

---

## Preview Mode

1. Take existing template + data + scanned form image
2. Generate overlay PDF showing data on top of form image
3. Open for user to inspect alignment

---

## Key Principles

1. **mm everywhere** — All positions stored and calculated in mm. Convert only at the boundary (if library needs different unit).
2. **Data only** — Never print form structure (lines, boxes, labels). The paper already has those.
3. **Confirm before generating** — Always show the field map to user and get confirmation before writing code.
4. **Thai-first** — Default to THSarabun font. All prompts in Thai.
5. **Match project patterns** — Follow existing jsPDF patterns in the codebase (lazy import, `FONT_BASE`, `fetchAsBase64`, page geometry constants).
6. **Printer offset is real** — Every printer shifts output slightly. Calibration is not optional for production use.
