# Margaret — Security Patterns

OWASP Top 10 mapped to the Vue 3 + Supabase stack.
Use this as a reference during Agent E (Security & Access) analysis.

---

## 1. Broken Access Control

**Risk:** Users access data or actions beyond their permissions.

### Supabase / Vue Checks
- RLS policies on every table with user-facing data
- Route guards on every protected page
- Role checks enforced server-side (RLS), not just client-side

### Do

```sql
-- RLS policy scoped to the user's organization
CREATE POLICY "org_members_only" ON orders
  FOR ALL USING (org_id = (SELECT org_id FROM profiles WHERE id = auth.uid()));
```

```ts
// Router guard
router.beforeEach((to) => {
  if (to.meta.requiresAuth && !useAuth().isAuthenticated.value) {
    return { name: 'login' }
  }
})
```

### Don't

```sql
-- Overly permissive — anyone can read everything
CREATE POLICY "public_read" ON orders FOR SELECT USING (true);
```

```ts
// Page-level check only — user can see flash of content
onMounted(() => {
  if (!isLoggedIn.value) router.push('/login')  // Too late!
})
```

---

## 2. Cryptographic Failures

**Risk:** Sensitive data exposed through improper storage or transmission.

### Do

```ts
// Store tokens in httpOnly cookies (server-set)
// Use Supabase's built-in auth token management
const { data } = await supabase.auth.getSession()
```

### Don't

```ts
// Storing sensitive tokens in localStorage
localStorage.setItem('access_token', token)
localStorage.setItem('refresh_token', refreshToken)

// Hardcoded secrets in client code
const STRIPE_SECRET = 'sk_live_xxxxx'  // NEVER
```

---

## 3. Injection

**Risk:** Untrusted data sent to an interpreter as part of a command or query.

### SQL Injection

#### Do

```ts
// Parameterized queries via Supabase client
const { data } = await supabase
  .from('products')
  .select('*')
  .eq('category', userInput)
```

```sql
-- Parameterized SQL function
CREATE FUNCTION get_product(p_id uuid)
RETURNS SETOF products AS $$
  SELECT * FROM products WHERE id = p_id;
$$ LANGUAGE sql SECURITY DEFINER;
```

#### Don't

```ts
// Raw string interpolation in RPC calls
const { data } = await supabase.rpc('search', {
  query: `SELECT * FROM products WHERE name = '${userInput}'`  // SQL injection!
})
```

### XSS (Cross-Site Scripting)

#### Do

```vue
<!-- Vue auto-escapes by default -->
<p>{{ userComment }}</p>

<!-- Sanitize if v-html is truly needed -->
<div v-html="DOMPurify.sanitize(richContent)"></div>
```

#### Don't

```vue
<!-- Direct v-html with user input = XSS -->
<div v-html="userComment"></div>

<!-- Unsanitized URL -->
<a :href="userProvidedUrl">Click</a>
```

---

## 4. Insecure Design

**Risk:** Missing security controls in the design phase.

### Checks
- No rate limiting on login/signup/password-reset endpoints
- No audit trail for sensitive operations (delete, role change, data export)
- No account lockout after failed login attempts
- Business logic that can be abused (e.g., unlimited free trial signups)

### Do

```sql
-- Audit trail trigger
CREATE FUNCTION audit_log() RETURNS trigger AS $$
BEGIN
  INSERT INTO audit_logs (table_name, record_id, action, user_id, old_data, new_data)
  VALUES (TG_TABLE_NAME, NEW.id, TG_OP, auth.uid(), row_to_json(OLD), row_to_json(NEW));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Don't

```ts
// No logging, no audit trail
await supabase.from('users').delete().eq('id', userId)
// Who deleted this? When? Why? Nobody knows.
```

---

## 5. Security Misconfiguration

**Risk:** Insecure default configs, open cloud storage, verbose errors.

### Checks
- CORS allows only trusted origins (not `*`)
- Debug mode disabled in production builds
- Supabase storage buckets are not public unless intentionally so
- Error messages don't leak stack traces or internal paths

### Do

```ts
// Vite production config
export default defineConfig({
  define: {
    __DEV__: JSON.stringify(false),
  },
})
```

### Don't

```ts
// Permissive CORS in production
app.use(cors({ origin: '*' }))

// Verbose errors exposed to client
catch (error) {
  res.status(500).json({ error: error.stack })  // Stack trace leaked!
}
```

---

## 6. Vulnerable and Outdated Components

**Risk:** Using components with known vulnerabilities.

### Checks
- Run `npm audit` regularly
- Check for outdated dependencies with `npm outdated`
- Pin dependency versions in `package-lock.json`
- Review changelogs before major version bumps

### Do

```bash
npm audit --production
npm outdated
npx npm-check-updates
```

### Don't

```json
// Wildcard versions — unpredictable updates
{
  "dependencies": {
    "some-lib": "*",
    "another-lib": ">=1.0.0"
  }
}
```

---

## 7. Identification and Authentication Failures

**Risk:** Weak auth mechanisms allowing unauthorized access.

### Checks
- Password policy enforced (minimum length, complexity)
- MFA available for sensitive accounts
- Session timeout configured
- Password reset tokens are single-use and time-limited
- No user enumeration via login/signup error messages

### Do

```ts
// Supabase auth with proper config
const { error } = await supabase.auth.signUp({
  email,
  password,  // Supabase enforces minimum 6 chars by default
  options: { data: { role: 'user' } }
})

// Consistent error messages (no user enumeration)
if (error) {
  toast.error('Invalid credentials')  // Same message for wrong email OR password
}
```

### Don't

```ts
// User enumeration via different error messages
if (error.message === 'User not found') {
  toast.error('No account with this email')  // Reveals email existence
} else {
  toast.error('Wrong password')  // Confirms email exists
}
```

---

## 8. Software and Data Integrity Failures

**Risk:** Code and data integrity not verified.

### Checks
- API responses validated before use
- CSRF protection on state-changing requests
- Subresource Integrity (SRI) on CDN scripts
- Database constraints enforce data integrity

### Do

```sql
-- Database constraints as the last line of defense
ALTER TABLE order_items
  ADD CONSTRAINT positive_quantity CHECK (quantity > 0),
  ADD CONSTRAINT valid_status CHECK (status IN ('active', 'cancelled', 'completed'));
```

```html
<!-- SRI for CDN resources -->
<script src="https://cdn.example.com/lib.js"
  integrity="sha384-xxxxx"
  crossorigin="anonymous"></script>
```

### Don't

```ts
// Trusting client-side data without server validation
const { quantity } = req.body
await supabase.from('items').insert({ quantity })  // Could be negative!
```

---

## 9. Security Logging and Monitoring Failures

**Risk:** Breaches go undetected due to insufficient logging.

### Checks
- Authentication events logged (login, logout, failed attempts)
- Authorization failures logged
- Data modification on sensitive tables logged
- PII not included in logs
- Logs are structured (JSON) for searchability

### Do

```ts
// Structured logging without PII
logger.warn({
  event: 'auth_failure',
  userId: userId,  // OK — not PII itself
  ip: request.ip,
  timestamp: new Date().toISOString(),
})
```

### Don't

```ts
// PII in logs
console.log(`Login failed for ${email} with password ${password}`)

// No logging at all for sensitive operations
await supabase.from('users').update({ role: 'admin' }).eq('id', targetId)
// No record of who promoted whom to admin
```

---

## 10. Server-Side Request Forgery (SSRF)

**Risk:** Application fetches URLs provided by users without validation.

### Checks
- User-provided URLs are validated against allowlists
- Internal network addresses are blocked (127.0.0.1, 10.x.x.x, 192.168.x.x)
- Redirect chains are not followed blindly
- File upload URLs are validated

### Do

```ts
// URL allowlist validation
const ALLOWED_DOMAINS = ['api.example.com', 'cdn.example.com']
const url = new URL(userProvidedUrl)
if (!ALLOWED_DOMAINS.includes(url.hostname)) {
  throw new Error('Domain not allowed')
}
```

### Don't

```ts
// Fetching arbitrary user-provided URLs
const response = await fetch(userProvidedUrl)  // Could hit internal services!
const data = await response.json()
```

---

## Quick Reference Severity Guide

| Finding | Default Severity |
|---------|-----------------|
| Missing RLS on user-facing table | CRITICAL |
| Service role key in client code | CRITICAL |
| v-html with unsanitized user input | CRITICAL |
| No route guard on protected page | HIGH |
| Tokens in localStorage | HIGH |
| No rate limiting on auth endpoints | HIGH |
| Overly permissive CORS | MEDIUM |
| No audit trail | MEDIUM |
| Debug mode in prod config | MEDIUM |
| Outdated dependencies (no known CVE) | LOW |
