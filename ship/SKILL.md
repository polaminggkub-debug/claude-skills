---
name: ship
description: "Ship code to production — the complete local-to-live workflow. Trigger on ANY request involving deploying, shipping, or pushing code to production: 'ship', 'ship it', 'deploy', 'push to prod', 'build and deploy', 'firebase deploy', 'commit deploy push', or partial steps like 'just deploy' or 'just push'. Also trigger on Thai: 'ขึ้น prod', 'deploy หน่อย', 'commit แล้ว deploy'. DO NOT trigger for: setting up hosting config, debugging deploy failures, writing CI/CD scripts, rolling back deploys, building new features/components, or git force-push. This skill is specifically for executing the commit-build-deploy-push pipeline, not for configuring or troubleshooting it."
---

# Ship — Commit, Build, Migrate, Deploy, Push

Ship code to production in one go. Adapt steps based on what's needed — skip commit if nothing changed, skip push if already pushed, etc.

**Project-specific commands** (build, deploy, smoke test) come from project memory or CLAUDE.md — not from this skill. Check memory for the current project's ship config before running.

## Execution Strategy: Parallel Agents

**Use parallel Agent calls wherever steps are independent.** The pipeline has natural dependency groups:

```
Phase 1 (parallel):  Pre-flight checks
  ├── Agent A: git status + check uncommitted changes
  ├── Agent B: bd list (check active beads for current branch)
  └── Agent C: check project memory/CLAUDE.md for build/deploy/smoke commands

Phase 2 (sequential): Commit (if needed)
  └── Stage files → commit with meaningful message

Phase 3 (parallel):  Build + Migrate
  ├── Agent D: Run build command, verify success
  └── Agent E: Check & run pending migrations

Phase 4 (sequential): Deploy (depends on Phase 3 success)
  └── Run deploy command

Phase 5 (parallel):  Post-deploy
  ├── Agent F: git push
  ├── Agent G: Smoke test / verify
  └── Agent H: BD update (close/complete beads)
```

**Rules:**
- Launch all agents in a phase with a **single message** containing multiple Agent tool calls
- Never proceed to next phase until all agents in current phase complete
- If any agent in a phase fails, stop and report — don't continue blindly

## Steps

### Phase 1: Pre-flight (parallel — 3 agents)

Launch these simultaneously:

**Agent A — Git Status:**
- Run `git status` to check for uncommitted changes
- Report: has changes? what files?

**Agent B — BD Status:**
- Run `bd list --assignee $(git config user.name) -s in_progress` to find active beads
- Run `bd list --assignee $(git config user.name) -s open` as fallback
- If the current branch name contains a bead ID (e.g., `feature/PROJ-123`), run `bd show <id>`
- Report: active bead IDs, titles, statuses

**Agent C — Project Config:**
- Check project memory and CLAUDE.md for: build command, deploy command, smoke test command, commit flags
- Report: commands to use in later phases

### Phase 2: Commit (sequential, skip if no changes)

- Stage relevant files (prefer specific files over `git add -A`)
- Write a meaningful commit message
- If BD found an active bead, reference it in the commit message
- Check project memory for commit flags (e.g. `--no-verify` if hooks are broken)

### Phase 3: Build + Migrate (parallel — 2 agents)

Launch these simultaneously:

**Agent D — Build:**
- Run the project's build command (from Phase 1 config)
- Verify build succeeds

**Agent E — Migrate:**
- Check for pending database migrations (e.g. `supabase migration list`, or project-specific command)
- If pending, run them (e.g. `supabase db push`)
- Verify migration succeeded
- If no migrations pending, report skip

### Phase 4: Deploy (sequential, depends on Phase 3)

- Run the project's deploy command (from Phase 1 config)
- Always run from repo root unless project says otherwise

### Phase 5: Post-deploy (parallel — 3 agents)

Launch these simultaneously:

**Agent F — Push:**
```bash
git push
```

**Agent G — Verify:**
- Run the project's smoke test command (from Phase 1 config)
- If no smoke test configured, report deploy is done but unverified
- Do NOT use manual browser screenshots for deploy verification — always prefer automated smoke tests

**Agent H — BD Finalize:**
- For each active bead found in Phase 1:
  - If the bead tracks this feature/fix and shipping completes it:
    ```bash
    bd close <id> --reason "Shipped to production"
    ```
  - If the bead has remaining work (partial ship):
    ```bash
    bd note <id> "Deployed to production. Remaining: <what's left>"
    ```
- If no active beads were found, skip this step
