# Claude Code Skills

Custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Skills

| Skill | Description |
|-------|-------------|
| **chris** | Testable Architecture — analyze code into testable units, write tests, review & audit test suites. Based on Functional Core / Imperative Shell principles. |
| **margaret** | Deep Bug & Security Finder — systematic multi-phase audit using parallel agents to find bugs, security holes, and gaps. Module-level analysis. |

## Install

```bash
git clone https://github.com/polaminggkub-debug/claude-skills.git
cd claude-skills
bash install.sh
```

Or install manually:

```bash
cp -r chris ~/.claude/skills/
cp -r margaret ~/.claude/skills/
```

Restart Claude Code after installing.

## Update

```bash
cd claude-skills
git pull
bash install.sh
```
