#!/usr/bin/env bash
# Install ai-coding-flow for Claude Code, Gemini CLI, and/or OpenAI Codex.
# Uses symlinks where possible so edits / git pull take effect immediately.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Helpers ──────────────────────────────────────────────────────────

CHANGED=0

link() {
  local src="$1" dst="$2" label="$3"
  mkdir -p "$(dirname "$dst")"

  # Already correct symlink -> skip
  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    return
  fi

  # Remove old file/symlink if exists
  [[ -e "$dst" || -L "$dst" ]] && rm "$dst"

  ln -s "$src" "$dst"
  echo "  + $label"
  CHANGED=$((CHANGED + 1))
}

link_tree() {
  local src_root="$1" dst_root="$2" label="$3"
  local changed_before="$CHANGED"
  local src_path rel_path dst_path

  src_root="${src_root%/}"

  mkdir -p "$dst_root"

  while IFS= read -r src_path; do
    rel_path="${src_path#"$src_root"/}"
    dst_path="$dst_root/$rel_path"
    link "$src_path" "$dst_path" "$label: $rel_path"
  done < <(find "$src_root" -type f ! -name '.DS_Store' | sort)

  if [[ $CHANGED -gt $changed_before ]]; then
    echo "  + $label (skill bundle)"
  fi
}

# Merge hooks from a template settings.json into a target settings.json.
# Uses python3 (pre-installed on macOS 12.3+ and most Linux).
# - If target doesn't exist -> cp template directly
# - If target exists but missing hooks -> merge with python3
# - If no python3 -> print manual instructions
# Idempotent: skips hooks already present (matched by command field).
merge_settings() {
  local template="$1" target="$2" tool_name="$3"

  if [[ ! -f "$target" ]]; then
    mkdir -p "$(dirname "$target")"
    cp "$template" "$target"
    echo "  + settings.json (created)"
    CHANGED=$((CHANGED + 1))
    return
  fi

  # Target exists — check if merge is needed
  if command -v python3 &>/dev/null; then
    local result
    result=$(python3 - "$template" "$target" <<'PYEOF'
import json, sys

template_path, target_path = sys.argv[1], sys.argv[2]

with open(template_path) as f:
    template = json.load(f)
with open(target_path) as f:
    target = json.load(f)

if "hooks" not in target:
    target["hooks"] = {}

changed = False
for event, entries in template.get("hooks", {}).items():
    if event not in target["hooks"]:
        target["hooks"][event] = []

    # Collect existing commands for this event
    existing_cmds = set()
    for entry in target["hooks"][event]:
        # Claude format: entry.hooks[].command
        for h in entry.get("hooks", []):
            existing_cmds.add(h.get("command", ""))
        # Gemini format: entry.command
        if "command" in entry:
            existing_cmds.add(entry["command"])

    for new_entry in entries:
        # Determine command(s) in the new entry
        cmds = []
        for h in new_entry.get("hooks", []):
            cmds.append(h.get("command", ""))
        if "command" in new_entry:
            cmds.append(new_entry["command"])

        # Add only if none of its commands already exist
        if not any(c in existing_cmds for c in cmds):
            target["hooks"][event].append(new_entry)
            changed = True

if changed:
    with open(target_path, "w") as f:
        json.dump(target, f, indent=2)
        f.write("\n")
    print("MERGED")
else:
    print("OK")
PYEOF
    )
    if [[ "$result" == "MERGED" ]]; then
      echo "  + settings.json (merged hooks)"
      CHANGED=$((CHANGED + 1))
    fi
  else
    echo "  ! python3 not found — cannot merge settings.json automatically."
    echo "    Install python3 to enable auto-merge:"
    echo "      macOS:  brew install python3"
    echo "      Ubuntu: sudo apt install python3"
    echo "    Or manually copy hooks from $template into $target"
  fi
}

generate_bundled_prompt() {
  local output="$1"
  mkdir -p "$(dirname "$output")"
  cat "$PROJECT_DIR/system-prompt-v5.md" > "$output"
  for skill in response-protocol ai-brain code-verification; do
    printf '\n\n---\n\n' >> "$output"
    cat "$PROJECT_DIR/skills/$skill/SKILL.md" >> "$output"
  done
  echo "  + $(basename "$output") (bundled prompt)"
  CHANGED=$((CHANGED + 1))
}

install_codex_agents() {
  local output="$1"
  mkdir -p "$(dirname "$output")"

  if [[ -f "$output" ]] && cmp -s "$PROJECT_DIR/AGENTS.md" "$output"; then
    return
  fi

  cp "$PROJECT_DIR/AGENTS.md" "$output"
  echo "  + $(basename "$output") (Codex prompt)"
  CHANGED=$((CHANGED + 1))
}

# ── Tool setup functions ─────────────────────────────────────────────

setup_claude() {
  local CLAUDE_DIR="$HOME/.claude"
  echo ""
  echo "Claude Code"
  echo "─────────────────────────────"

  # Skills
  for skill_dir in "$PROJECT_DIR"/skills/*/; do
    name=$(basename "$skill_dir")
    link "$skill_dir/SKILL.md" "$CLAUDE_DIR/skills/$name/SKILL.md" "$name"
  done

  # Claude prompt
  link "$PROJECT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" "CLAUDE.md"

  # All scripts
  for script in "$PROJECT_DIR"/scripts/*.sh; do
    name=$(basename "$script")
    link "$script" "$CLAUDE_DIR/scripts/$name" "$name"
  done

  # Settings (hooks)
  merge_settings "$PROJECT_DIR/claude/settings.json" "$CLAUDE_DIR/settings.json" "Claude Code"

  # Status line (optional)
  echo ""
  echo "  Status line shows: model, context usage bar, lines ±, git branch, worktree."
  read -rp "  Install status line? [y/N]: " install_sl
  case "$install_sl" in
    y|Y)
      if command -v python3 &>/dev/null; then
        python3 - "$PROJECT_DIR/claude/settings.json" "$CLAUDE_DIR/settings.json" <<'PYEOF'
import json, sys
template_path, target_path = sys.argv[1], sys.argv[2]
with open(template_path) as f:
    template = json.load(f)
with open(target_path) as f:
    target = json.load(f)
if "statusLine" in template:
    target["statusLine"] = template["statusLine"]
    with open(target_path, "w") as f:
        json.dump(target, f, indent=2)
        f.write("\n")
PYEOF
        echo "  + statusLine config"
        CHANGED=$((CHANGED + 1))
      else
        echo "  ! python3 not found — add statusLine manually to ~/.claude/settings.json"
      fi
      ;;
    *)
      echo "  - skipped statusLine"
      ;;
  esac
}

setup_gemini() {
  local GEMINI_DIR="$HOME/.gemini"
  echo ""
  echo "Gemini CLI"
  echo "─────────────────────────────"

  # Bundled prompt
  generate_bundled_prompt "$GEMINI_DIR/GEMINI.md"

  # Scripts (no-coauthor-guard is Claude-specific)
  link "$PROJECT_DIR/scripts/brain-loader.sh" "$GEMINI_DIR/scripts/brain-loader.sh" "brain-loader.sh"
  link "$PROJECT_DIR/scripts/brain-gate.sh" "$GEMINI_DIR/scripts/brain-gate.sh" "brain-gate.sh"

  # Settings (hooks)
  merge_settings "$PROJECT_DIR/gemini/settings.json" "$GEMINI_DIR/settings.json" "Gemini CLI"

  echo ""
  echo "  Note: Gemini CLI hook format may differ from this template."
  echo "  Test with 'gemini' and adjust ~/.gemini/settings.json if needed."
}

setup_codex() {
  local CODEX_DIR="$HOME/.codex"
  echo ""
  echo "OpenAI Codex"
  echo "─────────────────────────────"

  # Codex-specific prompt
  install_codex_agents "$CODEX_DIR/AGENTS.md"

  # Scripts
  for script in "$PROJECT_DIR"/scripts/*.sh; do
    name=$(basename "$script")
    link "$script" "$CODEX_DIR/scripts/$name" "$name"
  done

  # Skills
  for skill_dir in "$PROJECT_DIR"/skills/*/; do
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    name=$(basename "$skill_dir")
    link_tree "$skill_dir" "$CODEX_DIR/skills/$name" "$name"
  done

  echo ""
  echo "  Note: Codex uses the repo's Codex-specific AGENTS.md."
  echo "  Skills are linked into ~/.codex/skills for reuse across projects."
  echo "  Hook-based Claude features are replaced with manual instructions."
}

# ── Menu ─────────────────────────────────────────────────────────────

echo "ai-coding-flow setup"
echo "===================="
echo ""
echo "  [1] Claude Code"
echo "  [2] Gemini CLI"
echo "  [3] OpenAI Codex"
echo "  [a] All"
echo "  [q] Quit"
echo ""
read -rp "Select tool(s) to set up: " choice

case "$choice" in
  1) setup_claude ;;
  2) setup_gemini ;;
  3) setup_codex ;;
  a|A)
    setup_claude
    setup_gemini
    setup_codex
    ;;
  q|Q) echo "Aborted."; exit 0 ;;
  *) echo "Invalid choice: $choice"; exit 1 ;;
esac

# ── Summary ──────────────────────────────────────────────────────────

echo ""
if [[ $CHANGED -eq 0 ]]; then
  echo "Already up to date. No changes needed."
else
  echo "---"
  echo "Done. $CHANGED change(s) applied."
fi
