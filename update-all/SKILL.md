---
name: update-all
description: "Update the entire Codex environment — CLI, npm global packages, Homebrew packages/casks, plugin marketplaces, skills, RTK, Graphify, and local tools. Trigger on: '/update-all', 'อัพเดททุกอย่าง', 'update everything', 'อัพเดท codex', 'update all plugins', 'update all skills', 'update homebrew', 'update brew', 'update rtk', 'update graphify', or any request to bulk-update the development environment. Also trigger on Thai: 'อัพเดทให้หมด', 'อัพเดทล่าสุด'. DO NOT trigger for: updating a single specific package outside the Codex/toolchain environment or updating project dependencies (npm install in a project)."
---

# Update All — Full Environment Update

Update Codex CLI, global npm packages, Homebrew packages/casks, Codex plugin marketplaces, skills, RTK, Graphify, and local git tools in one go. Automatically detects what's installed.

## Steps

## Parallel execution policy

Prefer parallel execution whenever commands do not share package-manager locks or update the runtime used by another command.

Safe parallel groups:
- Discovery commands in Step 1: run all at once.
- After discovery: `codex plugin marketplace upgrade`, `skills update`, and local git tool pulls can run in parallel.
- `npm update -g` can run in parallel with Codex marketplace/skills/local git updates when global npm packages are outdated.

Serialize these:
- Run Homebrew as one exclusive phase: `brew update`, then `brew upgrade`, then `brew upgrade --cask`. Do not run multiple `brew` update/upgrade commands in parallel.
- Run RTK verification/update after Homebrew, because Homebrew may own `rtk`.
- Run Graphify update after Homebrew, because Homebrew may update `uv`, `pipx`, or Python.
- Run final verification after all update phases finish.

### 1. Discover what's installed (parallel)

Run these simultaneously to detect what this machine has:

```bash
codex --version                                      # Codex CLI
npm list -g --depth=0                                # Global npm packages
npm outdated -g                                      # What needs updating
which brew 2>/dev/null && brew outdated --formula    # Homebrew formula updates
which brew 2>/dev/null && brew outdated --cask       # Homebrew cask updates
codex plugin marketplace upgrade --help 2>/dev/null  # Plugin marketplace support
which skills 2>/dev/null && skills check             # Skills CLI, if installed
which rtk 2>/dev/null && rtk --version               # RTK CLI, if installed
which graphify 2>/dev/null && graphify --help | head # Graphify CLI, if installed
which uv 2>/dev/null && uv tool list | rg graphify    # Graphify uv tool, if installed
ls ~/.agents/skills ~/.codex/skills 2>/dev/null      # Personal/system skills
ls ~/tools/ 2>/dev/null                              # Local tools directory, if present
```

Each command may fail if that tool isn't installed — that's fine, skip it.

### 2. Update npm global packages

If `npm outdated -g` returned results:
```bash
npm update -g
```

### 3. Update Homebrew packages

If `brew` is installed, update Homebrew metadata and upgrade outdated formulae and casks:

```bash
brew update
brew upgrade
brew upgrade --cask
```

Notes:
- This intentionally updates all Homebrew-managed formulae, including runtimes such as `node`, `python`, `uv`, `pipx`, and tools such as `trivy`, `semgrep`, `ripgrep`, `ollama`, `gh`, and `supabase`.
- Do not use `--greedy`, `--force`, or destructive cleanup flags unless the user explicitly asks.
- If a cask is blocked, already current, has no auto-update metadata, or requires manual action, report it and continue.
- Capture before/after outdated counts for the summary.

### 4. Update Codex plugin marketplaces

If `codex plugin marketplace upgrade --help` works, refresh installed marketplaces:

```bash
codex plugin marketplace upgrade
```

If specific marketplace names are known from local config or prior output, update each one explicitly when useful:

```bash
codex plugin marketplace upgrade <marketplace-name>
```

Codex currently exposes marketplace upgrade, not a generic `codex plugin list` / `codex plugin update` workflow. Do not invent unavailable commands.

### 5. Update all skills

If `skills` CLI is installed:

```bash
skills update
```

If not installed, skip silently. For git-backed local skills under `~/.agents/skills`, `~/.codex/skills`, or `~/.codex/superpowers/skills`, only run `git pull` inside directories that are actual git repos and have no risky uncommitted changes.

### 6. Update RTK

If `rtk` is installed, verify it through its detected install source.

RTK stays separate because it may be installed from Homebrew or a local source repo. A full Homebrew upgrade covers only Homebrew-owned `rtk`; it does not cover a dirty or custom local checkout.

If Homebrew owns the binary and the Homebrew step did not already upgrade it, run:

```bash
brew upgrade rtk
```

If `rtk` has a local source repo such as `~/Documents/rtk`, only fetch/pull when the repo is clean:

```bash
git -C ~/Documents/rtk fetch --all --prune
git -C ~/Documents/rtk pull --ff-only
```

If the repo has uncommitted changes or the checked-out branch is intentionally ahead/diverged, do not merge or reset. Report the current version and upstream state instead.

### 7. Update Graphify

If `graphify` is installed through `uv tool`, update the package and reinstall the Codex skill:

```bash
uv tool upgrade graphifyy
graphify install --platform codex
```

If installed with `pipx`, use:

```bash
pipx upgrade graphifyy
graphify install --platform codex
```

If installed with plain `pip`, use the Python that owns the `graphify` command:

```bash
python -m pip install --upgrade graphifyy
graphify install --platform codex
```

Graphify's GitHub tags may be newer than the latest published `graphifyy` package. Prefer the latest package manager release unless the user explicitly asks to install directly from GitHub.

### 8. Update local tools

Only if `~/tools/` exists. For each subdirectory that contains a `.git` folder:
```bash
cd ~/tools/<dir> && git pull
```

If there are uncommitted changes, `git stash && git pull && git stash pop`. If `~/tools/` doesn't exist, skip silently.

### 9. Verify & Report

Run these after updates where available:

```bash
codex --version
npm outdated -g
which brew 2>/dev/null && brew outdated --formula
which brew 2>/dev/null && brew outdated --cask
codex plugin marketplace upgrade --help 2>/dev/null
rtk --version
which graphify 2>/dev/null && uv tool list | rg graphify
test -f ~/.agents/skills/graphify/.graphify_version && cat ~/.agents/skills/graphify/.graphify_version
```

Report in this format:

```
## Update Summary

**Codex CLI:**
- before-version → after-version

**NPM Packages (X updated):**
- package-a 1.0.0 → 1.1.0

**Homebrew (X formulae, Y casks updated):**
- formula/cask before-count → after-count
- notable packages: node, python, uv, trivy, semgrep, ripgrep, etc.

**Codex Plugin Marketplaces:**
- marketplace-name — upgraded/refreshed

**Skills:**
- X skill(s) updated

**RTK:**
- before-version → after-version

**Graphify:**
- graphifyy before-version → after-version
- Codex skill reinstalled/refreshed

**Local Tools:**
- tool-name - pulled latest

Restart Codex if any plugin marketplace or runtime plugin changed.
```

Only include sections that are relevant to this machine. Keep it short.
