#!/usr/bin/env bash
blocks='▁▂▃▄▅▆▇█'

mem_pct=$(awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{print int((1-a/t)*100)}' /proc/meminfo)
cpu_pct=$(awk '/^cpu / {idle=$5+$6; total=0; for(i=2;i<=NF;i++) total+=$i; print int((1-idle/total)*100)}' /proc/stat)

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

echo "MEM: $(bar $mem_pct)  CPU: $(bar $cpu_pct)"
