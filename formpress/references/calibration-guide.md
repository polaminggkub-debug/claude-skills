# Printer Calibration Guide

## Why Calibrate?

Every printer introduces a small mechanical offset when feeding paper. This offset is
typically 0.5–3mm and varies by:
- Printer model and brand
- Paper tray used (manual feed vs cassette)
- Paper size and weight
- Feed direction (portrait vs landscape)

Without calibration, fields that look perfect on screen will be shifted on the printed output.

## Calibration Workflow

### Step 1: Generate Calibration Page

Create a PDF with crosshair markers at known positions on A4 paper:

```typescript
async function generateCalibrationPage(): Promise<void> {
  const { jsPDF } = await getJsPDF()
  const doc = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' })
  await registerThaiFonts(doc)

  const PAGE_W = 210
  const PAGE_H = 297

  // Crosshair positions (mm from origin)
  const markers = [
    { x: 20, y: 20, label: 'A (20,20)' },
    { x: 190, y: 20, label: 'B (190,20)' },
    { x: 20, y: 277, label: 'C (20,277)' },
    { x: 190, y: 277, label: 'D (190,277)' },
    { x: 105, y: 148.5, label: 'E (105,148.5) CENTER' },
  ]

  // Draw crosshairs
  const CROSS_SIZE = 8 // mm, total length of each arm
  doc.setDrawColor(0)
  doc.setLineWidth(0.3)
  doc.setFontSize(8)

  for (const m of markers) {
    // Horizontal line
    doc.line(m.x - CROSS_SIZE / 2, m.y, m.x + CROSS_SIZE / 2, m.y)
    // Vertical line
    doc.line(m.x, m.y - CROSS_SIZE / 2, m.x, m.y + CROSS_SIZE / 2)
    // Label
    doc.text(m.label, m.x + 5, m.y - 3)
  }

  // Edge rulers (every 10mm along top and left edges)
  doc.setFontSize(6)
  for (let x = 10; x <= 200; x += 10) {
    doc.line(x, 0, x, 3)
    doc.text(String(x), x, 6, { align: 'center' })
  }
  for (let y = 10; y <= 290; y += 10) {
    doc.line(0, y, 3, y)
    doc.text(String(y), 5, y + 1)
  }

  // Instructions
  doc.setFontSize(10)
  doc.text('FORMPRESS CALIBRATION PAGE', PAGE_W / 2, 40, { align: 'center' })
  doc.setFontSize(8)
  doc.text([
    'Instructions:',
    '1. Print this page at 100% scale (no fit-to-page)',
    '2. Measure each crosshair position with a ruler from the paper edges',
    '3. Report the difference between expected and actual positions',
    '   Example: "A is at 21mm,19.5mm instead of 20,20"',
  ], 50, 50)

  window.open(doc.output('bloburl'))
}
```

### Step 2: User Prints and Measures

User must print at **100% scale** (important: disable "fit to page" in print dialog).

Then measure each crosshair's actual position from the paper's physical edges using a ruler.

### Step 3: Calculate Offset

```
dx = average(actual_x - expected_x) across all markers
dy = average(actual_y - expected_y) across all markers
```

Example:

| Marker | Expected | Actual | Δx | Δy |
|--------|----------|--------|-----|-----|
| A | (20, 20) | (21.5, 19) | +1.5 | -1.0 |
| B | (190, 20) | (191.5, 19) | +1.5 | -1.0 |
| C | (20, 277) | (21.5, 276) | +1.5 | -1.0 |
| D | (190, 277) | (191.5, 276) | +1.5 | -1.0 |
| E | (105, 148.5) | (106.5, 147.5) | +1.5 | -1.0 |

Average offset: **dx = +1.5mm, dy = -1.0mm**

### Step 4: Apply Offset

Subtract the offset from all field positions to compensate:

```typescript
// Printer shifts everything +1.5mm right and -1.0mm up
// So we move our output -1.5mm left and +1.0mm down to compensate
const PRINTER_OFFSET_X = -1.5  // mm (negate the measured dx)
const PRINTER_OFFSET_Y = 1.0   // mm (negate the measured dy)

// Apply to every field
doc.text(text, field.x_mm + PRINTER_OFFSET_X, field.y_mm + PRINTER_OFFSET_Y)
```

Alternatively, pass offsets as function parameters for flexibility:

```typescript
interface PrintOptions {
  offsetX_mm?: number  // printer X offset (default 0)
  offsetY_mm?: number  // printer Y offset (default 0)
}
```

## Tips

- **Re-calibrate** when changing printers, paper trays, or paper sizes
- **Manual feed** often has different offset than cassette feed
- **Landscape vs portrait** can produce different offsets — calibrate per orientation
- **Save offsets** per printer name if using multiple printers:

```typescript
const PRINTER_OFFSETS: Record<string, { dx: number; dy: number }> = {
  'office-hp-1': { dx: -1.5, dy: 1.0 },
  'factory-epson': { dx: -0.5, dy: -0.5 },
}
```

## Common Print Dialog Settings

When printing formpress output, always ensure:
- Scale: **100%** (not "fit to page")
- Margins: **None** or **Minimum**
- Paper size: matches the template
- Orientation: matches the template
