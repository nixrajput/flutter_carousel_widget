#!/usr/bin/env bash
# Fails when line coverage over lib/ falls below the threshold given as $1.
# Reads coverage/lcov.info, which `flutter test --coverage` writes.
set -euo pipefail

THRESHOLD="${1:-90}"
LCOV="${2:-coverage/lcov.info}"

if [ ! -f "$LCOV" ]; then
  echo "No coverage report at $LCOV" >&2
  exit 1
fi

# LF = lines found, LH = lines hit; both are emitted once per source file.
read -r found hit < <(
  awk -F: '
    /^LF:/ { found += $2 }
    /^LH:/ { hit   += $2 }
    END    { print found, hit }
  ' "$LCOV"
)

if [ "${found:-0}" -eq 0 ]; then
  echo "Coverage report contains no lines" >&2
  exit 1
fi

percent=$(awk -v h="$hit" -v f="$found" 'BEGIN { printf "%.2f", (h / f) * 100 }')
echo "Line coverage: $percent% ($hit/$found), threshold ${THRESHOLD}%"

if awk -v h="$hit" -v f="$found" -v t="$THRESHOLD" 'BEGIN { exit (h * 100 >= t * f) ? 0 : 1 }'; then
  exit 0
fi

echo "Coverage $percent% is below the ${THRESHOLD}% threshold" >&2
exit 1
