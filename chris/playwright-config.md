# Playwright Configuration & Performance Guide

Read this file when writing E2E tests or during Audit Agent C (Performance).

---

## Seed Data

**Always seed via API/DB, never through UI.**

```typescript
// ✅ DO — direct DB insert (fast, reliable)
test.beforeEach(async () => {
  await supabase.from('employees').insert([
    { name: 'John', salary: 50000, department: 'IT' },
  ]);
});

test.afterEach(async () => {
  await supabase.from('employees').delete().eq('name', 'John');
});

// ❌ DON'T — seed through UI (slow, flaky)
test.beforeEach(async ({ page }) => {
  await page.goto('/employees/new');
  await page.fill('#name', 'John');
  await page.click('button[type=submit]');
});
```

For complex seed data, use a shared helper:
```typescript
// helpers/seed.ts
export async function seedEmployee(overrides = {}) {
  const defaults = { name: 'Test Employee', salary: 50000 };
  const data = { ...defaults, ...overrides };
  const { data: employee } = await supabase.from('employees').insert(data).select().single();
  return employee;
}
```

---

## Authentication & storageState

Reuse login state across tests — don't log in through UI every test.

```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    { name: 'setup', testMatch: /.*\.setup\.ts/ },
    {
      name: 'tests',
      dependencies: ['setup'],
      use: { storageState: '.auth/user.json' },
    },
  ],
});

// auth.setup.ts
import { test as setup } from '@playwright/test';

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill(process.env.TEST_EMAIL!);
  await page.getByLabel('Password').fill(process.env.TEST_PASSWORD!);
  await page.getByRole('button', { name: 'Login' }).click();
  await page.waitForURL('/dashboard');
  await page.context().storageState({ path: '.auth/user.json' });
});
```

---

## Selectors Priority

```
getByRole     → best: semantic, accessible, stable
getByLabel    → good: form elements
getByText     → ok: visible text content
getByTestId   → fallback: when no semantic option
CSS selector  → last resort: PrimeVue/framework components only
```

For PrimeVue components that don't expose semantic selectors:
```typescript
// Acceptable — PrimeVue doesn't give us a better option
await page.locator('.p-dropdown').click();
await page.locator('.p-dropdown-item').filter({ hasText: 'Active' }).click();
```

---

## Waiting — Condition-Based Only

```typescript
// ❌ NEVER
await page.waitForTimeout(3000);

// ✅ Wait for element
await expect(page.getByText('Saved')).toBeVisible();

// ✅ Wait for API response
await page.waitForResponse(resp =>
  resp.url().includes('/api/employees') && resp.ok()
);

// ✅ Wait for navigation
await page.waitForURL('/employees');
```

Default timeout: 5000ms. If a test needs more, the app has a performance bug — fix the app, not the timeout.

---

## Parallel Execution

```typescript
// playwright.config.ts
export default defineConfig({
  fullyParallel: true,
  workers: process.env.CI ? 2 : 4,
});
```

**Parallel safety rules:**
- Each test creates its own data with unique identifiers
- Use worker-isolated prefixes: `test-${test.info().workerIndex}-`
- Never depend on data from another test
- Clean up after each test
- **CRITICAL: Scope ALL locators to your test's data prefix** — never use generic
  text like `text=Pending` + `.first()` to pick from a list. Under parallel load,
  other workers create similar data and `.first()` grabs the wrong row.
  Always include your unique prefix in the locator:
  ```typescript
  // ❌ Grabs any worker's pending row
  page.locator('tr', { has: page.locator('text=Pending') }).first()
  // ✅ Grabs only YOUR test's row
  page.locator('tr', { has: page.locator(`text=${TEST_PREFIX}BILL-001`) }).first()
  ```

---

## Connection Budget

`workers × pool.max` must not exceed DB connection limit.

```
4 workers × 5 pool.max = 20 connections
Supabase free tier = 60 connections
→ OK, but leave headroom for the app itself
```

---

## Heavy/Light Split

Separate slow tests from fast tests:

```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    {
      name: 'fast',
      testMatch: /.*\.spec\.ts/,
      testIgnore: /.*\.slow\.spec\.ts/,
    },
    {
      name: 'slow',
      testMatch: /.*\.slow\.spec\.ts/,
    },
  ],
});
```

Run fast tests in CI on every push, slow tests on merge to main only.

---

## Budget

| Metric | Target |
|--------|--------|
| Total E2E tests | 20-30 max |
| Suite runtime | < 3 minutes |
| Single test | < 10 seconds |
| Login | Once via storageState, not per test |

If over budget, use Agent B (ROI & Trim) criteria to decide what to remove or downgrade to integration tests.

---

## Base URL & Port

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL || 'http://localhost:5173',
  },
  webServer: {
    command: 'npm run dev',
    port: 5173,
    reuseExistingServer: !process.env.CI,
  },
});
```

---

## State Reset

Reset state via API/DB between tests, not by navigating UI:

```typescript
test.afterEach(async () => {
  // Clean up test data directly
  await supabase.from('test_orders').delete().like('ref', 'TEST-%');
});
```

Never rely on test execution order for state.
