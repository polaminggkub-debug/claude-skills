#!/bin/bash
set -e

SKILLS_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS=("chris" "formpress" "margaret")

mkdir -p "$SKILLS_DIR"

for skill in "${SKILLS[@]}"; do
  if [ -d "$SCRIPT_DIR/$skill" ]; then
    cp -r "$SCRIPT_DIR/$skill" "$SKILLS_DIR/"
    echo "✓ Installed: $skill"
  fi
done

echo ""
echo "Done! Restart Claude Code to use the new skills."
