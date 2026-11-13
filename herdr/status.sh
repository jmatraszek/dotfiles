#!/usr/bin/env bash
# Status segment for herdr tab_bar_right: CPU usage and battery (if any).
read -r _ u1 n1 s1 i1 w1 q1 sq1 _ < /proc/stat
sleep 0.5
read -r _ u2 n2 s2 i2 w2 q2 sq2 _ < /proc/stat
idle=$(( (i2 + w2) - (i1 + w1) ))
total=$(( (u2 + n2 + s2 + i2 + w2 + q2 + sq2) - (u1 + n1 + s1 + i1 + w1 + q1 + sq1) ))
out="󰍛 $(( total > 0 ? 100 * (total - idle) / total : 0 ))%"

for b in /sys/class/power_supply/BAT*; do
  [[ -r $b/capacity ]] && out+="  󰁹 $(<"$b/capacity")%" && break
done
echo "$out"
