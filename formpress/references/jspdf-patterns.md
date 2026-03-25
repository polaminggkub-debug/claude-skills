# jsPDF Patterns for Formpress

Code patterns extracted from the SSP-ERP project's existing PDF generators.
Follow these patterns when generating formpress templates to maintain consistency.

## Lazy Import Pattern

Always use lazy imports to keep the initial bundle small:

```typescript
import type { jsPDF as JsPDFType } from 'jspdf'

async function getJsPDF() {
  const { default: jsPDF } = await import('jspdf')
  return { jsPDF }
}
```

Note: Do NOT import `jspdf-autotable` for formpress templates. Formpress uses
manual absolute positioning, not auto-generated tables. AutoTable adds borders
and backgrounds that would conflict with the pre-printed form.

## Thai Font Registration

The project uses THSarabun. Font files are served from the public directory:

```typescript
const FONT_BASE = import.meta.env.BASE_URL + 'fonts/'

async function fetchAsBase64(url: string): Promise<string> {
  const res = await fetch(url)
  if (!res.ok) throw new Error(`Fetch failed: ${res.status} ${url}`)
  const buf = await res.arrayBuffer()
  const bytes = new Uint8Array(buf)
  let bin = ''
  for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i])
  return btoa(bin)
}

async function registerThaiFonts(pdf: JsPDFType): Promise<void> {
  const [regular, bold] = await Promise.all([
    fetchAsBase64(FONT_BASE + 'Sarabun-Regular.ttf'),
    fetchAsBase64(FONT_BASE + 'Sarabun-Bold.ttf'),
  ])
  pdf.addFileToVFS('Sarabun-Regular.ttf', regular)
  pdf.addFileToVFS('Sarabun-Bold.ttf', bold)
  pdf.addFont('Sarabun-Regular.ttf', 'Sarabun', 'normal')
  pdf.addFont('Sarabun-Bold.ttf', 'Sarabun', 'bold')
  pdf.setFont('Sarabun')
}
```

## Page Setup

```typescript
const PAGE_W = 210   // A4 width in mm
const PAGE_H = 297   // A4 height in mm

const doc = new jsPDF({
  orientation: 'portrait',
  unit: 'mm',
  format: 'a4',
})
await registerThaiFonts(doc)
```

## Field Positioning — The Core Pattern

This is the heart of formpress. Each field is placed at an absolute (x, y) position:

```typescript
// Simple text field
doc.setFontSize(12)
doc.setFont('Sarabun', 'normal')
doc.text(data.companyName, 35, 52)

// Right-aligned (useful for numbers, dates)
doc.text(data.invoiceNumber, 190, 52, { align: 'right' })

// Center-aligned
doc.text(data.title, 105, 30, { align: 'center' })

// Bold text
doc.setFont('Sarabun', 'bold')
doc.text(data.heading, 35, 40)
doc.setFont('Sarabun', 'normal')  // reset to normal
```

## Text Wrapping

For fields where text may exceed the available width:

```typescript
const maxWidth = 60  // mm
const lines = doc.splitTextToSize(data.address, maxWidth)
doc.text(lines, 35, 70)
// Each subsequent line is auto-offset by the font's line height
```

## Number Formatting

```typescript
function formatNumber(n: number): string {
  return n.toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })
}

// Right-align numbers in a column
doc.text(formatNumber(data.amount), 185, 100, { align: 'right' })
```

## Date Formatting

Project standard is DD/MM/YYYY:

```typescript
function formatDate(dateStr?: string): string {
  if (!dateStr) return ''
  const [y, m, d] = dateStr.split('-')
  return `${d}/${m}/${y}`
}
```

## Table-Like Repeating Rows

For itemized lists on pre-printed forms, manually iterate rows with a fixed Y increment:

```typescript
const TABLE_START_Y = 95   // mm from top where first row begins
const ROW_HEIGHT = 8       // mm between rows
const MAX_ROWS = 15        // rows per page on this form

// Column X positions (from left edge)
const COL_NO = 20          // ลำดับ
const COL_DESC = 35        // รายการ
const COL_QTY = 130        // จำนวน
const COL_PRICE = 155      // ราคา
const COL_TOTAL = 185      // รวม

data.items.forEach((item, i) => {
  const y = TABLE_START_Y + (i * ROW_HEIGHT)
  doc.text(String(i + 1), COL_NO, y, { align: 'center' })
  doc.text(item.description, COL_DESC, y)
  doc.text(formatNumber(item.qty), COL_QTY, y, { align: 'right' })
  doc.text(formatNumber(item.price), COL_PRICE, y, { align: 'right' })
  doc.text(formatNumber(item.total), COL_TOTAL, y, { align: 'right' })
})
```

## Multi-Page Handling

When items exceed a single page:

```typescript
data.items.forEach((item, i) => {
  const pageIndex = Math.floor(i / MAX_ROWS)
  const rowInPage = i % MAX_ROWS

  if (pageIndex > 0 && rowInPage === 0) {
    doc.addPage()
  }

  const y = TABLE_START_Y + (rowInPage * ROW_HEIGHT)
  // ... draw fields at y
})
```

## Overlay Preview Mode

For debugging alignment before printing on real paper:

```typescript
async function generatePreview(
  data: FormData,
  formImagePath: string,
): Promise<void> {
  const { jsPDF } = await getJsPDF()
  const doc = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' })
  await registerThaiFonts(doc)

  // Load and embed the scanned form as background
  const imgData = await fetchAsBase64(formImagePath)
  doc.addImage(imgData, 'JPEG', 0, 0, 210, 297)

  // Overlay data fields in red for visibility
  doc.setTextColor(255, 0, 0)
  doc.setFontSize(12)

  // Draw each field with a crosshair marker
  for (const field of fields) {
    const value = data[field.name]
    if (!value) continue

    // Crosshair at field origin
    doc.setDrawColor(255, 0, 0)
    doc.setLineWidth(0.2)
    doc.line(field.x_mm - 2, field.y_mm, field.x_mm + 2, field.y_mm)
    doc.line(field.x_mm, field.y_mm - 2, field.x_mm, field.y_mm + 2)

    // Text
    doc.text(String(value), field.x_mm, field.y_mm, { align: field.align })
  }

  // Reset colors
  doc.setTextColor(0, 0, 0)
  window.open(doc.output('bloburl'))
}
```

## Print-Only Mode (Production)

The actual print function omits the background image — only data:

```typescript
async function generateFormPrint(data: FormData): Promise<void> {
  const { jsPDF } = await getJsPDF()
  const doc = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' })
  await registerThaiFonts(doc)

  // NO background image — paper already has the form printed on it
  // NO borders or lines — form paper has those

  doc.setFontSize(12)
  for (const field of fields) {
    const value = data[field.name]
    if (!value) continue

    doc.setFontSize(field.fontSize)
    doc.setFont('Sarabun', field.fontStyle)
    doc.text(String(value), field.x_mm, field.y_mm, { align: field.align })
  }

  window.open(doc.output('bloburl'))
}
```

## Complete Skeleton Template

Copy this as a starting point for any new formpress template:

```typescript
import type { jsPDF as JsPDFType } from 'jspdf'

// --- Lazy imports ---
async function getJsPDF() {
  const { default: jsPDF } = await import('jspdf')
  return { jsPDF }
}

// --- Font loading ---
const FONT_BASE = import.meta.env.BASE_URL + 'fonts/'

async function fetchAsBase64(url: string): Promise<string> {
  const res = await fetch(url)
  if (!res.ok) throw new Error(`Fetch failed: ${res.status} ${url}`)
  const buf = await res.arrayBuffer()
  const bytes = new Uint8Array(buf)
  let bin = ''
  for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i])
  return btoa(bin)
}

async function registerThaiFonts(pdf: JsPDFType): Promise<void> {
  const [regular, bold] = await Promise.all([
    fetchAsBase64(FONT_BASE + 'Sarabun-Regular.ttf'),
    fetchAsBase64(FONT_BASE + 'Sarabun-Bold.ttf'),
  ])
  pdf.addFileToVFS('Sarabun-Regular.ttf', regular)
  pdf.addFileToVFS('Sarabun-Bold.ttf', bold)
  pdf.addFont('Sarabun-Regular.ttf', 'Sarabun', 'normal')
  pdf.addFont('Sarabun-Bold.ttf', 'Sarabun', 'bold')
  pdf.setFont('Sarabun')
}

// --- Page geometry ---
const PAGE_W = 210   // TODO: adjust to actual form size
const PAGE_H = 297

// --- Printer calibration offset ---
const OFFSET_X = 0   // TODO: set after calibration
const OFFSET_Y = 0

// --- Field positions (mm from top-left origin) ---
// TODO: Fill in from interview
const FIELDS = {
  // field_name: { x: mm, y: mm, fontSize: pt, align: 'left'|'center'|'right', bold: false }
} as const

// --- Data interface ---
interface FormData {
  // TODO: define from interview
}

// --- Generate print-only PDF ---
export async function generateFormPDF(
  data: FormData,
  options?: { offsetX?: number; offsetY?: number },
): Promise<void> {
  const ox = options?.offsetX ?? OFFSET_X
  const oy = options?.offsetY ?? OFFSET_Y

  const { jsPDF } = await getJsPDF()
  const doc = new jsPDF({ orientation: 'portrait', unit: 'mm', format: [PAGE_W, PAGE_H] })
  await registerThaiFonts(doc)

  // TODO: place each field
  // doc.setFontSize(FIELDS.field_name.fontSize)
  // doc.text(data.field_name, FIELDS.field_name.x + ox, FIELDS.field_name.y + oy)

  window.open(doc.output('bloburl'))
}
```
