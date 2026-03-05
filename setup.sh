#!/usr/bin/env bash
# Install ai-coding-flow into ~/.claude/ via symlinks.
# After setup, editing project files or running git pull takes effect immediately.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

link() {
  local src="$1" dst="$2" label="$3"
  mkdir -p "$(dirname "$dst")"

  # Already correct symlink → skip
  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    return
  fi

  # Remove old file/symlink if exists
  [[ -e "$dst" || -L "$dst" ]] && rm "$dst"

  ln -s "$src" "$dst"
  echo "✓ $label"
  CHANGED=$((CHANGED + 1))
}

CHANGED=0

# Skills
for skill_dir in "$PROJECT_DIR"/skills/*/; do
  name=$(basename "$skill_dir")
  link "$skill_dir/SKILL.md" "$CLAUDE_DIR/skills/$name/SKILL.md" "$name"
done

# System prompt → CLAUDE.md
link "$PROJECT_DIR/system-prompt-v5.md" "$CLAUDE_DIR/CLAUDE.md" "CLAUDE.md"

# Brain loader script
link "$PROJECT_DIR/scripts/brain-loader.sh" "$CLAUDE_DIR/scripts/brain-loader.sh" "brain-loader.sh"

# Brain gate script (PreToolUse lock)
link "$PROJECT_DIR/scripts/brain-gate.sh" "$CLAUDE_DIR/scripts/brain-gate.sh" "brain-gate.sh"

# Hooks in settings.json
SETTINGS="$CLAUDE_DIR/settings.json"
SESSION_CMD="~/.claude/scripts/brain-loader.sh"
GATE_CMD="~/.claude/scripts/brain-gate.sh"

if command -v jq &>/dev/null; then
  if [[ -f "$SETTINGS" ]]; then
    NEEDS_UPDATE=false

    # Check SessionStart hook
    if ! jq -e '.hooks.SessionStart[]?.hooks[]?.command // empty' "$SETTINGS" 2>/dev/null | grep -q "brain-loader.sh"; then
      NEEDS_UPDATE=true
    fi

    # Check PreToolUse hook
    if ! jq -e '.hooks.PreToolUse[]?.hooks[]?.command // empty' "$SETTINGS" 2>/dev/null | grep -q "brain-gate.sh"; then
      NEEDS_UPDATE=true
    fi

    if [[ "$NEEDS_UPDATE" == "true" ]]; then
      jq --arg scmd "$SESSION_CMD" --arg gcmd "$GATE_CMD" '
        .hooks.SessionStart = [{"matcher": "startup|resume|compact", "hooks": [{"type": "command", "command": $scmd}]}]
        | .hooks.PreToolUse = [{"matcher": "*", "hooks": [{"type": "command", "command": $gcmd}]}]
      ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
      echo "✓ Hooks (SessionStart + PreToolUse)"
      CHANGED=$((CHANGED + 1))
    fi
  else
    # Create minimal settings with both hooks
    jq -n --arg scmd "$SESSION_CMD" --arg gcmd "$GATE_CMD" '{
      "hooks": {
        "SessionStart": [{"matcher": "startup|resume|compact", "hooks": [{"type": "command", "command": $scmd}]}],
        "PreToolUse": [{"matcher": "*", "hooks": [{"type": "command", "command": $gcmd}]}]
      }
    }' > "$SETTINGS"
    echo "✓ Hooks (new settings.json)"
    CHANGED=$((CHANGED + 1))
  fi
else
  echo "⚠ jq not found — skip hook setup. Install jq or add manually to $SETTINGS"
fi

if [[ $CHANGED -eq 0 ]]; then
  echo "Already installed. Symlinks are up to date."
else
  echo "---"
  echo "Installed $CHANGED change(s). Changes to project files now take effect immediately."
fi
