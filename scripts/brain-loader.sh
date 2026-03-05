#!/usr/bin/env bash
# brain-loader.sh — SessionStart hook for Claude Code
# Outputs a Brain Map (~20 lines) into context instead of full file contents.
# AI sees "=== AI BRAIN ===" marker and selectively reads files based on user message.

set -euo pipefail

PROJECT_NAME=$(basename "$PWD")
BRAIN_ROOT="$(dirname "$PWD")/ai-brain"

# No Brain repo → silent exit
[[ -d "$BRAIN_ROOT" ]] || exit 0

# No project Brain → silent exit (new project, not yet initialized)
[[ -d "$BRAIN_ROOT/$PROJECT_NAME" ]] || exit 0

# --- Descriptions (bash 3.2 compatible — no declare -A) ---

pdesc() {
  case "$1" in
    architecture_decisions.md) echo "Hard constraints, tech stack, domain model. Read for ANY code/design task." ;;
    known_issues.md)           echo "Active bugs, pitfalls, workarounds. Read for ANY code/debug task." ;;
    todo.md)                   echo "Task backlog and priorities. Read when planning or checking progress." ;;
    journal.md)                echo "Recent work log. Read when resuming work or reviewing history." ;;
  esac
}

cdesc() {
  case "$1" in
    preferences.md)            echo "Personal preferences: naming, formatting, tool choices." ;;
    troubleshooting.md)        echo "Cross-project solutions to recurring problems." ;;
    toolchain.md)              echo "CLI, IDE, CI/CD, deployment notes." ;;
    conversation-patterns.md)  echo "Recurring conversation patterns (skill-owned)." ;;
    skill-experience.md)       echo "Skill tuning and pitfall log (skill-owned)." ;;
    prompt-violations.md)      echo "Rule violation tracker (skill-owned)." ;;
  esac
}

# --- Entry counter ---
# Counts meaningful entries: markdown headers (##) or list items (- / *)
count_entries() {
  local file="$1"
  [[ -f "$file" ]] || { echo "0"; return; }
  local n
  n=$(grep -c '^## \|^### \|^- \|^\* ' "$file" 2>/dev/null) || true
  echo "${n:-0}"
}

# --- Brain Map output ---

echo "=== AI BRAIN: $PROJECT_NAME ==="
echo ""
echo "## Project Brain (\$BRAIN_ROOT/$PROJECT_NAME/)"
echo ""

TOTAL_ENTRIES=0
for f in architecture_decisions.md known_issues.md todo.md journal.md; do
  if [[ -f "$BRAIN_ROOT/$PROJECT_NAME/$f" ]]; then
    n=$(count_entries "$BRAIN_ROOT/$PROJECT_NAME/$f")
    TOTAL_ENTRIES=$((TOTAL_ENTRIES + n))
    echo "- $f ($n entries) — $(pdesc "$f")"
  fi
done

echo ""
echo "## Common Brain (\$BRAIN_ROOT/_common/)"
echo ""

for f in "$BRAIN_ROOT/_common/"*.md; do
  [[ -f "$f" ]] || continue
  name=$(basename "$f")
  case "$name" in SCHEMA.md) continue ;; esac
  desc=$(cdesc "$name")
  [[ -n "$desc" ]] || continue
  n=$(count_entries "$f")
  TOTAL_ENTRIES=$((TOTAL_ENTRIES + n))
  echo "- $name ($n entries) — $desc"
done

# --- Health Check ---

echo ""
HEALTH_WARNINGS=0
for f in architecture_decisions.md known_issues.md todo.md journal.md; do
  if [[ -f "$BRAIN_ROOT/$PROJECT_NAME/$f" ]]; then
    n=$(count_entries "$BRAIN_ROOT/$PROJECT_NAME/$f")
    if [[ $n -gt 40 ]]; then
      echo "⚠️ $f has $n entries — consider running /distill"
      HEALTH_WARNINGS=$((HEALTH_WARNINGS + 1))
    fi
  fi
done
for f in "$BRAIN_ROOT/_common/"*.md; do
  [[ -f "$f" ]] || continue
  name=$(basename "$f")
  case "$name" in SCHEMA.md) continue ;; esac
  n=$(count_entries "$f")
  if [[ $n -gt 40 ]]; then
    echo "⚠️ _common/$name has $n entries — consider running /distill"
    HEALTH_WARNINGS=$((HEALTH_WARNINGS + 1))
  fi
done
[[ $HEALTH_WARNINGS -eq 0 ]] && echo "Health: OK"

# --- Instructions ---

echo ""
echo "## Instructions"
echo ""
echo "Total entries: $TOTAL_ENTRIES"
echo "1. Read user message → decide which Brain files are relevant"
echo "2. If total relevant entries < 15 → cat the files directly"
echo "3. If total relevant entries >= 15 → use ONE Explore sub-agent to read and summarize"
echo "4. architecture_decisions.md is ALWAYS relevant for code/design tasks"
echo "5. Respond to user FIRST, then use tools for their task"
echo ""
echo "=== END AI BRAIN ==="

# Create lock file — brain-gate.sh will block the first tool call
touch "/tmp/claude-brain-lock-${PROJECT_NAME}"

# Debug trace (persistent) — verify loader actually ran
echo "$(date '+%Y-%m-%d %H:%M:%S') brain-loader: $PROJECT_NAME (map mode)" >> "/tmp/claude-brain-debug.log"
