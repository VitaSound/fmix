#!/usr/bin/env bash
# update-cov-badge.sh — refresh Cov shields.io badge URLs in README files.
set -euo pipefail

root="${1:-.}"
pct="${2:?usage: update-cov-badge.sh [root] coverage_pct}"

if (( pct >= 90 )); then color=brightgreen
elif (( pct >= 75 )); then color=green
elif (( pct >= 50 )); then color=yellow
elif (( pct >= 25 )); then color=orange
else color=red
fi

for f in README.md README.ru.md; do
  [[ -f "${root}/${f}" ]] || continue
  sed -i -E "s#\\[\\!\\[Cov\\]\\(https://img.shields.io/badge/Cov-[0-9]+%25-[a-z]+\\.svg\\)\\]#[![Cov](https://img.shields.io/badge/Cov-${pct}%25-${color}.svg)]#g" "${root}/${f}"
done

echo "Cov badge -> ${pct}% (${color})"
