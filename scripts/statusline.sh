#!/usr/bin/env bash
# Claude Code status line script — 3-line aesthetic layout

input=$(cat)

# --- Colors ---
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
CYAN='\033[36m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'
MAGENTA='\033[35m'

# --- Helpers ---
pick_first() {
  local result
  while [ "$#" -gt 0 ]; do
    result=$(printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null)
    if [ -n "$result" ] && [ "$result" != "null" ]; then
      printf '%s' "$result"
      return 0
    fi
    shift
  done
  return 1
}

pick_recursive() {
  local window_pattern="$1"
  local field_pattern="$2"
  printf '%s' "$input" | jq -r --arg window "$window_pattern" --arg field "$field_pattern" '
    [
      paths(scalars) as $p
      | {
          path: ($p | map(tostring) | join(".") | ascii_downcase),
          value: getpath($p)
        }
      | select(.path | test($window))
      | select(.path | test($field))
      | .value
    ][0] // empty
  ' 2>/dev/null
}

format_pct() {
  local value="$1"
  [ -z "$value" ] && return 1
  printf '%.0f%%' "$value" 2>/dev/null || printf '%s' "$value"
}

usage_metric() {
  local pct="$1"
  local time="$2"
  local bar_width="${3:-8}"
  local pct_int
  local time_fmt="--"
  local used_int
  local filled
  local empty
  local bar_filled=""
  local bar_empty=""
  local bar_color
  local bar
  local pct_part

  if [ -z "$pct" ]; then
    printf "${DIM}waiting...${RESET}"
    return 0
  fi

  pct_int=$(printf "%.0f" "$pct" 2>/dev/null || printf '%s' "$pct")
  used_int=$((100 - pct_int))
  [ "$used_int" -lt 0 ] && used_int=0
  [ "$used_int" -gt 100 ] && used_int=100

  filled=$(( used_int * bar_width / 100 ))
  empty=$(( bar_width - filled ))
  [ "$filled" -lt 0 ] && filled=0
  [ "$filled" -gt "$bar_width" ] && filled=$bar_width
  [ "$empty" -lt 0 ] && empty=0

  [ "$filled" -gt 0 ] && bar_filled=$(printf '%.0s█' $(seq 1 $filled))
  [ "$empty" -gt 0 ] && bar_empty=$(printf '%.0s░' $(seq 1 $empty))

  if [ "$pct_int" -ge 30 ]; then
    bar_color=$GREEN
  elif [ "$pct_int" -ge 10 ]; then
    bar_color=$YELLOW
  else
    bar_color=$RED
  fi

  bar=$(printf "${bar_color}${bar_filled}${DIM}${bar_empty}${RESET}")
  pct_part=$(printf "${bar_color}${BOLD}%s${RESET}" "$(format_pct "$pct_int")")

  if [ -n "$time" ] && [ "$time" != "null" ]; then
    time_fmt="$time"
  fi

  printf "%b %b ${DIM}%s${RESET}" "$bar" "$pct_part" "$time_fmt"
}

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# --- Context window ---
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

BAR_WIDTH=20
COMPACT_BAR_WIDTH=8

if [ -n "$remaining" ] && [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  remaining_int=$(printf "%.0f" "$remaining")

  filled=$(( used_int * COMPACT_BAR_WIDTH / 100 ))
  empty=$(( COMPACT_BAR_WIDTH - filled ))
  [ "$filled" -lt 0 ] && filled=0
  [ "$filled" -gt "$COMPACT_BAR_WIDTH" ] && filled=$COMPACT_BAR_WIDTH
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
  ctx_part=$(printf "Context %b %b" "$bar" "$pct")
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
path_part=""
if [ -n "$project_dir" ] && [ -d "$project_dir/.git" ]; then
  branch=$(git -C "$project_dir" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
  [ -n "$branch" ] && branch_part=$(printf "${CYAN}${branch}${RESET}")
fi

# --- Path ---
if [ -n "$project_dir" ]; then
  display_path=$(basename "$project_dir")
  path_part=$(printf "${DIM}%s${RESET}" "$display_path")
fi

# --- Worktree ---
worktree_part=""
wt_name=$(echo "$input" | jq -r '.worktree.name // empty')
if [ -n "$wt_name" ]; then
  worktree_part=$(printf "${MAGENTA}${wt_name}${RESET}")
fi

# --- Usage windows ---
format_reset_time() {
  local epoch="$1"
  [ -z "$epoch" ] && return 1
  local now
  now=$(date +%s)
  local diff=$(( epoch - now ))
  [ "$diff" -le 0 ] && { printf "now"; return 0; }
  local days=$(( diff / 86400 ))
  local hours=$(( diff / 3600 ))
  local rem=$(( diff % 86400 ))
  local rem_hours=$(( rem / 3600 ))
  local mins=$(( (rem % 3600) / 60 ))
  if [ "$days" -gt 0 ]; then
    printf "%dd%dh%dm" "$days" "$rem_hours" "$mins"
  elif [ "$hours" -gt 0 ]; then
    printf "%dh%dm" "$hours" "$mins"
  else
    printf "%dm" "$mins"
  fi
}

week_remaining_pct=""
week_remaining_time=""
five_hour_remaining_pct=""
five_hour_remaining_time=""

week_remaining_pct=$(pick_first \
  '.usage.week.remaining_percentage' \
  '.usage.week.remaining_percent' \
  '.usage.week.percent_remaining' \
  '.usage.week.remaining_pct' \
  '.usage.weekly.remaining_percentage' \
  '.usage.weekly.remaining_percent' \
  '.rate_limits.seven_day.remaining_percentage' \
  '.rate_limits.seven_day.remaining_percent' \
  '.limits.week.remaining_percentage' \
  '.limits.week.remaining_percent')
[ -z "$week_remaining_pct" ] && week_remaining_pct=$(pick_recursive 'week|weekly|seven.*day|7.*day' 'remaining.*(percentage|percent|pct)|percent.*remaining|pct.*remaining')

week_used_pct=$(pick_first \
  '.usage.week.used_percentage' \
  '.usage.week.used_percent' \
  '.usage.week.percentage_used' \
  '.usage.weekly.used_percentage' \
  '.usage.weekly.used_percent' \
  '.rate_limits.seven_day.used_percentage' \
  '.rate_limits.seven_day.used_percent' \
  '.limits.week.used_percentage' \
  '.limits.week.used_percent')
[ -z "$week_used_pct" ] && week_used_pct=$(pick_recursive 'week|weekly|seven.*day|7.*day' 'used.*(percentage|percent|pct)|percentage.*used|percent.*used|pct.*used')

if [ -z "$week_remaining_pct" ] && [ -n "$week_used_pct" ]; then
  week_remaining_pct=$((100 - $(printf "%.0f" "$week_used_pct")))
fi

week_remaining_time=$(pick_first \
  '.usage.week.remaining_time' \
  '.usage.week.time_remaining' \
  '.usage.week.reset_in' \
  '.usage.week.remaining_duration' \
  '.usage.weekly.remaining_time' \
  '.usage.weekly.time_remaining' \
  '.rate_limits.seven_day.remaining_time' \
  '.rate_limits.seven_day.time_remaining' \
  '.limits.week.remaining_time' \
  '.limits.week.time_remaining')
[ -z "$week_remaining_time" ] && week_remaining_time=$(pick_recursive 'week|weekly|seven.*day|7.*day' 'remaining.*time|time.*remaining|reset.*in|remaining.*duration')

week_resets_at=$(pick_first \
  '.rate_limits.seven_day.resets_at' \
  '.usage.week.resets_at' \
  '.usage.weekly.resets_at' \
  '.limits.week.resets_at')
[ -z "$week_resets_at" ] && week_resets_at=$(pick_recursive 'week|weekly|seven.*day|7.*day' 'resets.*at')
if [ -z "$week_remaining_time" ] && [ -n "$week_resets_at" ]; then
  week_remaining_time=$(format_reset_time "$week_resets_at")
fi

five_hour_remaining_pct=$(pick_first \
  '.usage.five_hour.remaining_percentage' \
  '.usage.five_hour.remaining_percent' \
  '.usage.five_hour.percent_remaining' \
  '.usage.fiveHour.remaining_percentage' \
  '.usage.fiveHour.remaining_percent' \
  '.usage["5h"].remaining_percentage' \
  '.usage["5h"].remaining_percent' \
  '.rate_limits.five_hour.remaining_percentage' \
  '.rate_limits.five_hour.remaining_percent' \
  '.limits.five_hour.remaining_percentage' \
  '.limits.five_hour.remaining_percent')
[ -z "$five_hour_remaining_pct" ] && five_hour_remaining_pct=$(pick_recursive '5h|five.*hour|hour.*5|fivehour' 'remaining.*(percentage|percent|pct)|percent.*remaining|pct.*remaining')

five_hour_used_pct=$(pick_first \
  '.usage.five_hour.used_percentage' \
  '.usage.five_hour.used_percent' \
  '.usage.fiveHour.used_percentage' \
  '.usage.fiveHour.used_percent' \
  '.usage["5h"].used_percentage' \
  '.usage["5h"].used_percent' \
  '.rate_limits.five_hour.used_percentage' \
  '.rate_limits.five_hour.used_percent' \
  '.limits.five_hour.used_percentage' \
  '.limits.five_hour.used_percent')
[ -z "$five_hour_used_pct" ] && five_hour_used_pct=$(pick_recursive '5h|five.*hour|hour.*5|fivehour' 'used.*(percentage|percent|pct)|percentage.*used|percent.*used|pct.*used')

if [ -z "$five_hour_remaining_pct" ] && [ -n "$five_hour_used_pct" ]; then
  five_hour_remaining_pct=$((100 - $(printf "%.0f" "$five_hour_used_pct")))
fi

five_hour_remaining_time=$(pick_first \
  '.usage.five_hour.remaining_time' \
  '.usage.five_hour.time_remaining' \
  '.usage.five_hour.reset_in' \
  '.usage.fiveHour.remaining_time' \
  '.usage.fiveHour.time_remaining' \
  '.usage["5h"].remaining_time' \
  '.usage["5h"].time_remaining' \
  '.rate_limits.five_hour.remaining_time' \
  '.rate_limits.five_hour.time_remaining' \
  '.limits.five_hour.remaining_time' \
  '.limits.five_hour.time_remaining')
[ -z "$five_hour_remaining_time" ] && five_hour_remaining_time=$(pick_recursive '5h|five.*hour|hour.*5|fivehour' 'remaining.*time|time.*remaining|reset.*in|remaining.*duration')

five_hour_resets_at=$(pick_first \
  '.rate_limits.five_hour.resets_at' \
  '.usage.five_hour.resets_at' \
  '.usage.fiveHour.resets_at' \
  '.usage["5h"].resets_at' \
  '.limits.five_hour.resets_at')
[ -z "$five_hour_resets_at" ] && five_hour_resets_at=$(pick_recursive '5h|five.*hour|hour.*5|fivehour' 'resets.*at')
if [ -z "$five_hour_remaining_time" ] && [ -n "$five_hour_resets_at" ]; then
  five_hour_remaining_time=$(format_reset_time "$five_hour_resets_at")
fi

# --- Output ---
sep=$(printf "${DIM}│${RESET}")

line1="${diff_part}"
[ -n "$branch_part" ] && line1="${line1} ${sep} ${branch_part}"
[ -n "$path_part" ] && line1="${line1} ${sep} ${path_part}"
printf "     %b\n" "$line1"

line2="${BOLD}${model}${RESET} ${sep} ${ctx_part}"
[ -n "$worktree_part" ] && [ "$wt_name" != "$branch" ] && line2="${line2} ${sep} ${worktree_part}"
printf "     %b\n" "$line2"

line3="$(usage_metric "$week_remaining_pct" "$week_remaining_time" 8) ${sep} $(usage_metric "$five_hour_remaining_pct" "$five_hour_remaining_time" 8)"
printf "     %b\n" "$line3"
