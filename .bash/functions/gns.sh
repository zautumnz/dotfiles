# shellcheck shell=bash

gns() {
  local x="$1"
  echo "scale=6; $x + 0.3 + ($x * 0.044)" | bc
}
