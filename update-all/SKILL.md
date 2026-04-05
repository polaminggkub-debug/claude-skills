---
name: update-all
description: "Update the entire Claude Code environment — CLI, npm global packages, plugins, skills, and local tools. Trigger on: '/update-all', 'อัพเดททุกอย่าง', 'update everything', 'อัพเดท claude code', 'update all plugins', 'update all skills', or any request to bulk-update the development environment. Also trigger on Thai: 'อัพเดทให้หมด', 'อัพเดทล่าสุด'. DO NOT trigger for: updating a single specific package, updating project dependencies (npm install in a project), or updating OS-level software."
---

# Update All — Full Environment Update

Update Claude Code CLI, global npm packages, plugins, skills, and local git tools in one go. Automatically detects what's installed — works on any machine.

## Steps

### 1. Discover what's installed (parallel)

Run these simultaneously to detect what this machine has:

```bash
claude --version                          # Claude Code CLI
npm list -g --depth=0                     # Global npm packages
npm outdated -g                           # What needs updating
claude plugin list 2>/dev/null            # Installed plugins (may not exist)
which skills 2>/dev/null && skills check  # Skills CLI (may not be installed)
ls ~/tools/ 2>/dev/null                   # Local tools directory (may not exist)
```

Each command may fail if that tool isn't installed — that's fine, skip it.

### 2. Update npm global packages

If `npm outdated -g` returned results:
```bash
npm update -g
```

### 3. Update all plugins

First, refresh all marketplace caches so version lookups are accurate:
```bash
claude plugin marketplace update
```

Then parse the output of `claude plugin list`. For **each** plugin found, run in parallel:
```bash
claude plugin update <name>@<marketplace>
```

If `claude plugin list` returned nothing or isn't available, skip this step.

### 4. Update all skills

Only if `skills` CLI is installed:
```bash
skills update
```

If not installed, skip silently.

### 5. Update local tools

Only if `~/tools/` exists. For each subdirectory that contains a `.git` folder:
```bash
cd ~/tools/<dir> && git pull
```

If there are uncommitted changes, `git stash && git pull && git stash pop`. If `~/tools/` doesn't exist, skip silently.

### 6. Verify & Report

Run `npm outdated -g` to confirm nothing remains outdated.

Report in this format:

```
## Update Summary

**NPM Packages (X updated):**
- package-a 1.0.0 → 1.1.0

**Plugins (X updated):**
- plugin-name 1.0 → 1.1

**Skills:**
- X skill(s) updated

**Local Tools:**
- tool-name — pulled latest

⚠️ Restart Claude Code if any plugin was updated.
```

Only include sections that are relevant to this machine. If plugins aren't installed, don't show the Plugins section. Keep it short.
