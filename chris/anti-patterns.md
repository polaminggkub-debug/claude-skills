# Chris — Anti-Patterns Reference

19 anti-patterns organized by source. Each has a Do/Don't code example.

---

## From Core Rules

### 1. Circular Tests
Testing storage/retrieval instead of business logic.

```typescript
// ❌ DON'T — tests the database, not the app
await db.insert('employees', { name: 'John', salary: 50000 });
const result = await db.query('SELECT * FROM employees WHERE name = $1', ['John']);
expect(result.salary).toBe(50000); // will ALWAYS pass

// ✅ DO — tests actual business logic
await db.insert('employees', { name: 'John', salary: 50000, ot_hours: 10 });
await page.goto('/payroll/calculate');
await page.getByRole('button', { name: 'Calculate' }).click();
// 50000/30 * 10 * 1.5 = 25000 OT (hand-calculated from spec)
await expect(page.getByTestId('ot-amount')).toHaveText('25,000.00');
```

### 2. Garbage Assertions
Assertions that prove existence, not correctness.

```typescript
// ❌ DON'T — any wrong data also passes these
await expect(page.getByRole('table')).toBeVisible();
await expect(page.getByRole('row')).toHaveCount(expect.any(Number));
expect(rows.length).toBeGreaterThan(0);

// ✅ DO — assert specific values
await expect(page.getByRole('row').nth(1)).toContainText('John');
await expect(page.getByRole('row').nth(1)).toContainText('50,000.00');
await expect(page.getByRole('row')).toHaveCount(3); // exactly 3 employees match filter
```

### 3. Weakened Tests
Tests modified to pass despite known bugs.

```typescript
// ❌ DON'T — hiding the bug
// TODO: skip filter check because fetchParts doesn't filter active
// await expect(page.getByRole('row')).toHaveCount(5);
await expect(page.getByRole('row')).toHaveCount(expect.any(Number));

// ✅ DO — write the test for correct behavior, let it fail, fix the bug
await expect(page.getByRole('row')).toHaveCount(5); // 5 active parts per spec
// If this fails → fetchParts has a bug → fix fetchParts
```

### 4. waitForTimeout
Using fixed delays instead of condition-based waits.

```typescript
// ❌ DON'T — brittle, slow, hides timing bugs
await page.click('#submit');
await page.waitForTimeout(3000);
await expect(page.locator('.result')).toBeVisible();

// ✅ DO — condition-based, fast, reveals performance issues
await page.getByRole('button', { name: 'Submit' }).click();
await expect(page.getByText('Saved successfully')).toBeVisible();
```

### 5. High Timeouts Masking App Bugs
Tests need long timeouts because the app is slow.

```typescript
// ❌ DON'T — the app has a bug, not the test
await expect(page.getByRole('table')).toBeVisible({ timeout: 15000 });

// ✅ DO — fix the app, keep the timeout reasonable
// App fix: add server-side pagination (fetch 50 rows, not 10,000)
await expect(page.getByRole('table')).toBeVisible({ timeout: 5000 });
```

---

## From goldbergyoni (JavaScript Testing Best Practices)

### 6. Foo/Bar Test Data
Using meaningless data that doesn't reveal bugs.

```typescript
// ❌ DON'T — "foo" won't catch encoding, length, or format bugs
const user = { name: 'foo', email: 'bar@baz.com' };

// ✅ DO — use realistic data with properties that matter
const user = {
  name: 'สมชาย จันทร์ศรี',  // Thai characters → tests encoding
  email: 'somchai+test@company.co.th',  // special chars in email
};
```

### 7. Try/Catch in Tests
Catching exceptions in tests instead of letting them propagate.

```typescript
// ❌ DON'T — swallows the real error
test('should reject invalid input', async () => {
  try {
    await createUser({ name: '' });
  } catch (e) {
    expect(e.message).toContain('name');
  }
  // If createUser doesn't throw, test passes silently!
});

// ✅ DO — use the framework's rejection matcher
test('should reject invalid input', async () => {
  await expect(createUser({ name: '' })).rejects.toThrow(/name is required/);
});
```

### 8. Mocks Over Stubs
Over-mocking hides integration bugs.

```typescript
// ❌ DON'T — mocking the DB means you're testing your mock, not your code
jest.mock('../db', () => ({
  query: jest.fn().mockResolvedValue([{ id: 1, total: 100 }])
}));

// ✅ DO — use a real database (Docker Postgres) for integration tests
// Stub only external services you don't control (payment API, email)
const result = await calculatePayroll(employeeId); // hits real DB
expect(result.total).toBe(75000); // spec-derived value
```

### 9. Large Snapshots
Snapshot testing that captures too much.

```typescript
// ❌ DON'T — 500-line snapshot that changes on every CSS tweak
expect(wrapper.html()).toMatchSnapshot();

// ✅ DO — snapshot only the meaningful structure, or use explicit assertions
expect(wrapper.find('.total').text()).toBe('75,000.00');
```

### 10. Testing Private Methods
Testing internal implementation instead of public behavior.

```typescript
// ❌ DON'T — couples tests to implementation details
// @ts-ignore accessing private method
expect(calculator._roundToSatang(100.555)).toBe(100.56);

// ✅ DO — test through the public API
const result = await calculator.calculateTotal({ price: 100.555, qty: 1 });
expect(result.total).toBe(100.56); // rounding tested indirectly
```

### 11. Global Test Fixtures
Shared fixtures that create hidden dependencies between tests.

```typescript
// ❌ DON'T — global setup makes tests dependent and hard to debug
beforeAll(async () => {
  await db.seed('employees', globalEmployees); // all tests share this
});

// ✅ DO — each test creates its own data
test('should calculate overtime', async () => {
  const emp = await createTestEmployee({ salary: 50000, ot_hours: 10 });
  const result = await calculatePayroll(emp.id);
  expect(result.ot_amount).toBe(25000); // (50000/30) * 10 * 1.5
  await cleanup(emp.id);
});
```

### 12. Shallow Rendering Overuse
Using shallow rendering that misses integration bugs.

```typescript
// ❌ DON'T — shallow render doesn't catch prop mismatch or slot issues
const wrapper = shallowMount(PayrollTable, { props: { employees } });
expect(wrapper.exists()).toBe(true); // always passes

// ✅ DO — mount with enough depth to test real interactions
const wrapper = mount(PayrollTable, { props: { employees } });
await wrapper.find('[data-testid="sort-salary"]').trigger('click');
expect(wrapper.findAll('tr').at(1).text()).toContain('50,000');
```

---

## From E2E Testing Best Practices

### 13. Assertions in Page Objects
Page objects should contain locators and actions, never assertions.

```typescript
// ❌ DON'T — assertion in page object
class EmployeePage {
  async verifyEmployeeExists(name: string) {
    await expect(this.page.getByText(name)).toBeVisible(); // assertion!
  }
}

// ✅ DO — page object returns data, test makes assertions
class EmployeePage {
  getEmployeeRow(name: string) {
    return this.page.getByRole('row', { name });
  }
}
// In test:
await expect(employeePage.getEmployeeRow('John')).toBeVisible();
```

### 14. Logic in Tests
Tests with conditional logic are multiple tests pretending to be one.

```typescript
// ❌ DON'T — branching logic means some paths might not execute
test('should handle all statuses', async () => {
  for (const status of ['active', 'inactive', 'terminated']) {
    const emp = await createEmployee({ status });
    if (status === 'active') {
      await expect(page.getByText('Active')).toBeVisible();
    } else if (status === 'terminated') {
      await expect(page.getByText('Cannot edit')).toBeVisible();
    }
  }
});

// ✅ DO — separate test for each scenario
test('active employee — shows active badge', async () => { ... });
test('terminated employee — shows cannot edit', async () => { ... });
```

### 15. Bad Locators
Using brittle CSS selectors instead of semantic locators.

```typescript
// ❌ DON'T
await page.click('.btn-primary');
await page.locator('#employee-table > tbody > tr:nth-child(2)').click();

// ✅ DO
await page.getByRole('button', { name: 'Save' }).click();
await page.getByRole('row', { name: /John/ }).click();
```

### 16. Full-Page Screenshots as Assertions
Using screenshot comparison for functional testing.

```typescript
// ❌ DON'T — breaks on font rendering, viewport, OS
await expect(page).toHaveScreenshot('employee-list.png');

// ✅ DO — assert specific data
await expect(page.getByRole('row')).toHaveCount(10);
await expect(page.getByRole('row').first()).toContainText('John');
```

### 17. Duplicate Coverage
Multiple tests checking the same thing in different ways.

```typescript
// ❌ DON'T — three tests all checking "employee appears in table"
test('employee is visible', ...);
test('employee appears in list', ...);
test('employee data is displayed', ...);

// ✅ DO — one test per behavior
test('employee list — shows correct data in columns', ...);
test('employee list — sorts by name on header click', ...);
test('employee list — filters by department', ...);
```

### 18. Unscoped Locators in Parallel Tests
Locators that match ANY worker's data instead of only YOUR test's data.

```typescript
// ❌ DON'T — matches the FIRST pending row, which may belong to another worker
const requestRow = page.locator('.p-datatable-tbody tr', {
  has: page.locator('text=Pending'),
}).first()
await requestRow.getByRole('button', { name: 'Approve' }).click()
// Approves the WRONG request → creates records for wrong bill → test fails

// ✅ DO — scope locator to YOUR test's unique data (prefix, bill number, etc.)
const requestRow = page.locator('.p-datatable-tbody tr', {
  has: page.locator(`text=${TEST_PREFIX}BILL-001`),
}).first()
await requestRow.getByRole('button', { name: 'Approve' }).click()
```

**Why this matters:** Tests pass with 1 worker but fail randomly with parallel workers.
Generic locators like `text=Pending` + `.first()` grab whatever row loads first —
under parallel load, that's often another worker's data.

**Rule:** Every locator that picks from a list MUST include your test's unique identifier
(worker prefix, bill number, customer name). If the unique text is in a child/sibling
element (e.g., expansion row), use XPath to navigate the DOM structure.

---

### 19. Over-Testing (Coverage Theater)
Writing E2E tests for things that don't need E2E tests.

```typescript
// ❌ DON'T — E2E test for a DB constraint
test('over-receive blocked', async () => {
  // 15 seconds of browser automation to test a CHECK constraint
});

// ✅ DO — use the right tool
// DB constraint protects production:
ALTER TABLE plating_log ADD CONSTRAINT check_qty CHECK (qty_received <= qty_sent);

// Integration test (fast, no browser):
test('plating guard rejects over-receive', async () => {
  await expect(pool.query('UPDATE ...')).rejects.toThrow();
});

// E2E only for flows that REQUIRE a browser:
test('full lifecycle: receive → withdraw → produce → ship', async ({ page }) => { ... });
```
