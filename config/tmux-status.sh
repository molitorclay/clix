#!/usr/bin/env bash
blocks='▁▂▃▄▅▆▇█'

mem_pct=$(awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{print int((1-a/t)*100)}' /proc/meminfo)
# /proc/stat only exposes cumulative-since-boot counters, so sample twice and take the delta.
read_cpu() { awk '/^cpu / {t=0; for(i=2;i<=NF;i++) t+=$i; print t, $5+$6; exit}' /proc/stat; }
read t1 i1 < <(read_cpu); sleep 0.3; read t2 i2 < <(read_cpu)
cpu_pct=$(( (t2-t1) > 0 ? 100 - (i2-i1)*100/(t2-t1) : 0 ))

ai_cache="${XDG_RUNTIME_DIR:-/tmp}/claude-usage.cache"
if [ ! -f "$ai_cache" ] || [ $(( $(date +%s) - $(stat -c %Y "$ai_cache") )) -gt 120 ]; then
  token=$(grep -o '"accessToken":"[^"]*"' ~/.claude/.credentials.json | sed 's/"accessToken":"//;s/"//')
  curl -s \
    -H 'Accept: application/json' \
    -H "Authorization: Bearer $token" \
    -H 'anthropic-beta: oauth-2025-04-20' \
    -H 'User-Agent: claude-cli/2.1.148 (external, cli)' \
    https://api.anthropic.com/api/oauth/usage \
  | sed 's/.*"limits":\[//;s/\],"spend".*//' \
  | tr ',' '\n' \
  | sed -n 's/.*"percent":\([0-9][0-9]*\).*/\1/p' \
  | head -2 > "$ai_cache" 2>/dev/null
fi
ai_session=$(sed -n '1p' "$ai_cache" 2>/dev/null || echo 0)
ai_weekly=$(sed -n '2p' "$ai_cache" 2>/dev/null || echo 0)

bar() {
  local pct=$1
  local idx=$(( pct * 7 / 100 ))
  local color
  if [ "$pct" -ge 90 ]; then
    color="#[fg=colour196]"
  elif [ "$pct" -ge 50 ]; then
    color="#[fg=colour33]"
  else
    color="#[fg=colour244]"
  fi
  echo -n "${color}${blocks:$idx:1}#[fg=default]"
}

ai_bar() {
  local pct=$1
  local idx=$(( pct * 7 / 100 ))
  if [ "$pct" -ge 90 ]; then
    echo -n "#[fg=colour238]${blocks:$idx:1}#[fg=default]"
  else
    echo -n "#[fg=colour244]${blocks:$idx:1}#[fg=default]"
  fi
}

echo "MEM: $(bar $mem_pct)  CPU: $(bar $cpu_pct)  AI: $(ai_bar $ai_session)$(ai_bar $ai_weekly)"
