# Unit Conversion Reference

## Coordinate System

jsPDF with `unit: 'mm'` uses:
- **Origin**: top-left corner of page (0, 0)
- **X axis**: left → right (increases rightward)
- **Y axis**: top → bottom (increases downward)
- All positions are in millimeters from the origin

## jsPDF Unit Note

When creating jsPDF with `{ unit: 'mm' }`, all coordinates are already in mm.
No conversion needed — pass mm values directly to `doc.text(text, x_mm, y_mm)`.

```typescript
const doc = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' })
// x and y are in mm — no conversion needed
doc.text('Hello', 35, 52) // 35mm from left, 52mm from top
```

## Conversion Formulas

Use these only when interfacing with systems that use different units.

| From → To | Formula | Example |
|-----------|---------|---------|
| mm → points | `mm × 2.8346` | 35mm = 99.2pt |
| mm → inches | `mm ÷ 25.4` | 35mm = 1.378in |
| mm → px (72 DPI) | `mm × 2.8346` | 35mm = 99.2px |
| mm → px (96 DPI) | `mm × 3.7795` | 35mm = 132.3px |
| mm → px (150 DPI) | `mm × 5.9055` | 35mm = 206.7px |
| mm → px (300 DPI) | `mm × 11.811` | 35mm = 413.4px |
| cm → mm | `cm × 10` | 3.5cm = 35mm |
| inches → mm | `inches × 25.4` | 1.378in = 35mm |
| points → mm | `pt ÷ 2.8346` | 99.2pt = 35mm |

## Image Scale Calculation

When user provides a scanned/photographed form image + actual paper dimensions:

```
scale_x = paper_width_mm / image_width_px
scale_y = paper_height_mm / image_height_px

field_x_mm = pixel_x × scale_x
field_y_mm = pixel_y × scale_y
```

### Worked Example

- Paper: A4 (210mm × 297mm)
- Image: 2480px × 3508px (300 DPI scan)
- Field pixel position: (412, 614)

```
scale_x = 210 / 2480 = 0.08468 mm/px
scale_y = 297 / 3508 = 0.08466 mm/px

field_x = 412 × 0.08468 = 34.9mm ≈ 35mm
field_y = 614 × 0.08466 = 52.0mm
```

### Phone Photo Warning

Photos taken with a phone camera have perspective distortion — the scale is not uniform
across the image. Positions estimated from phone photos have ±3-5mm error.

Recommendation: Use a scanner app (iPhone Notes Scan, Google Drive Scan) which
auto-corrects perspective, or measure positions with a ruler on the actual form.

## Standard Paper Sizes

| Name | Width (mm) | Height (mm) | Notes |
|------|-----------|-------------|-------|
| A4 | 210 | 297 | Most common in Thailand |
| A5 | 148 | 210 | Half of A4 |
| A3 | 297 | 420 | Double A4 |
| B5 (ISO) | 176 | 250 | |
| B5 (JIS) | 182 | 257 | Common in Japan |
| Letter | 215.9 | 279.4 | US standard |
| Legal | 215.9 | 355.6 | US legal |

## Font Size Reference

jsPDF font sizes are in **points** regardless of page unit setting.

| Points | Approximate mm height | Typical use |
|--------|----------------------|-------------|
| 8 | 2.8mm | Fine print, footnotes |
| 10 | 3.5mm | Body text (small) |
| 12 | 4.2mm | Body text (standard) |
| 14 | 4.9mm | Subheadings |
| 16 | 5.6mm | Headings |
| 18 | 6.4mm | Large headings |
| 24 | 8.5mm | Titles |

Note: Actual rendered height depends on the font. THSarabun renders slightly
taller than the point size suggests due to Thai character ascenders/descenders.
