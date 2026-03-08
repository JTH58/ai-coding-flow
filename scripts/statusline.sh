#!/usr/bin/env bash
# Claude Code status line script — 2-line aesthetic layout

input=$(cat)

# --- Colors ---
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
CYAN='\033[36m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# --- Context window ---
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

BAR_WIDTH=20

if [ -n "$remaining" ] && [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  remaining_int=$(printf "%.0f" "$remaining")

  filled=$(( used_int * BAR_WIDTH / 100 ))
  empty=$(( BAR_WIDTH - filled ))
  [ "$filled" -lt 0 ] && filled=0
  [ "$filled" -gt "$BAR_WIDTH" ] && filled=$BAR_WIDTH
  [ "$empty" -lt 0 ] && empty=0

  bar_filled=""
  bar_empty=""
  [ "$filled" -gt 0 ] && bar_filled=$(printf '%.0s█' $(seq 1 $filled))
  [ "$empty" -gt 0 ] && bar_empty=$(printf '%.0s░' $(seq 1 $empty))

  if [ "$remaining_int" -ge 30 ]; then
    BAR_COLOR=$GREEN
  elif [ "$remaining_int" -ge 10 ]; then
    BAR_COLOR=$YELLOW
  else
    BAR_COLOR=$RED
  fi

  bar=$(printf "${BAR_COLOR}${bar_filled}${DIM}${bar_empty}${RESET}")
  pct=$(printf "${BAR_COLOR}${BOLD}${remaining_int}%%${RESET}")
  ctx_part=$(printf "%b %b remaining" "$bar" "$pct")
else
  ctx_part=$(printf "${DIM}waiting...${RESET}")
fi

# --- Lines added / removed ---
added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
diff_part=$(printf "${GREEN}+${added}${RESET} ${RED}-${removed}${RESET}")

# --- Git branch ---
branch_part=""
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // .workspace.current_dir // ""')
if [ -n "$project_dir" ] && [ -d "$project_dir/.git" ]; then
  branch=$(git -C "$project_dir" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
  [ -n "$branch" ] && branch_part=$(printf "${CYAN}${branch}${RESET}")
fi

# --- Worktree ---
worktree_part=""
wt_name=$(echo "$input" | jq -r '.worktree.name // empty')
if [ -n "$wt_name" ]; then
  MAGENTA='\033[35m'
  worktree_part=$(printf "${MAGENTA}${wt_name}${RESET}")
fi

# --- Output ---
sep=$(printf "${DIM}│${RESET}")

printf "${BOLD}%s${RESET} %b %b\n" "$model" "$sep" "$ctx_part"

line2="${diff_part}"
[ -n "$branch_part" ] && line2="${line2} ${sep} ${branch_part}"
[ -n "$worktree_part" ] && line2="${line2} ${sep} ${worktree_part}"
printf "     %b\n" "$line2"
