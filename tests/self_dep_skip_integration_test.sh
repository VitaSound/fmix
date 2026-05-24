#!/usr/bin/env bash
# tests/self_dep_skip_integration_test.sh
#
# Smoke test: packages.get on a project that has only a fmix self-pin
# (`key-value fmix ~> 0.0`) and no real library deps must:
#   - exit 0,
#   - never touch theforth.net,
#   - never even try to fetch a `fmix` package (which doesn't exist
#     there and historically responded with HTTP 500).
#
# We also keep, as a defense-in-depth check, that the pre-0.7.0
# `key-list dependencies fmix <ver>` form is now rejected by version
# check (covered by legacy_fmix_dep case in
# version_check_integration_test.sh).
#
# Run via: bash tests/self_dep_skip_integration_test.sh

set -u

repo_root=$(cd "$(dirname "$0")/.." && pwd)
fixture="$repo_root/tests/fixtures/self_dep_only"

fail() { echo "[FAIL] $*" >&2; exit 1; }
pass() { echo "[OK]   $*"; }

cd "$fixture"

out=$(FMIX_HOME="$repo_root" bash "$repo_root/bin/fmix" packages.get 2>&1)
status=$?

if [ "$status" -ne 0 ]; then
    fail "packages.get expected to exit 0; got $status; output:
$out"
fi
pass "packages.get on self-pin-only fixture exits 0"

if grep -Eqi "(http.*500|internal server error|500 internal)" <<<"$out"; then
    fail "HTTP 500 still surfaces — theforth.net is being hit:
$out"
fi
pass "no HTTP 500 (theforth.net is not contacted)"

if grep -q "\\[GIT\\]" <<<"$out"; then
    fail "expected no library deps to fetch; got [GIT] lines:
$out"
fi
pass "no library deps fetched (only fmix self-pin in fixture)"

echo
echo "self_dep_skip_integration_test ok"
