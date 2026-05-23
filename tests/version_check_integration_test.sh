#!/usr/bin/env bash
# tests/version_check_integration_test.sh
#
# Smoke test for fmix_version_check.4th. We can't easily test this from a
# Forth subprocess (the check fires before the test runner is invoked, and
# the assertion is "this fmix is older than required" which we *want* to
# trigger) — so we drive it from bash instead.
#
# Run via: bash tests/version_check_integration_test.sh

set -u

repo_root=$(cd "$(dirname "$0")/.." && pwd)
fixture="$repo_root/tests/fixtures/needs_future_fmix"

fail() { echo "[FAIL] $*" >&2; exit 1; }
pass() { echo "[OK]   $*"; }

cd "$fixture"

# --- Case 1: `fmix test` must refuse to run and exit non-zero ----------
out=$(FMIX_HOME="$repo_root" bash "$repo_root/bin/fmix" test 2>&1)
status=$?
if [ "$status" -eq 0 ]; then
    fail "fmix test was expected to fail but exited 0; output:\n$out"
fi
if ! grep -q "requires fmix 99.0.0" <<<"$out"; then
    fail "fmix test did not mention the required version 99.0.0; output:\n$out"
fi
if grep -q "dummy_test SHOULD NOT RUN" <<<"$out"; then
    fail "the test runner was reached despite the version check; output:\n$out"
fi
pass "fmix test rejects too-new requirement (exit=$status)"

# --- Case 2: `fmix packages.get` must refuse too ------------------------
out=$(FMIX_HOME="$repo_root" bash "$repo_root/bin/fmix" packages.get 2>&1)
status=$?
if [ "$status" -eq 0 ]; then
    fail "fmix packages.get was expected to fail but exited 0; output:\n$out"
fi
if ! grep -q "requires fmix 99.0.0" <<<"$out"; then
    fail "fmix packages.get did not mention the required version; output:\n$out"
fi
pass "fmix packages.get rejects too-new requirement (exit=$status)"

# --- Case 3: `fmix version` must still work (debugging escape hatch) ----
out=$(FMIX_HOME="$repo_root" bash "$repo_root/bin/fmix" version 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    fail "fmix version must always work; got exit=$status; output:\n$out"
fi
pass "fmix version is unaffected by project-level requirement (exit=$status)"

# --- Case 4: `fmix help` must still work --------------------------------
out=$(FMIX_HOME="$repo_root" bash "$repo_root/bin/fmix" help 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    fail "fmix help must always work; got exit=$status; output:\n$out"
fi
pass "fmix help is unaffected by project-level requirement (exit=$status)"

echo
echo "version_check_integration_test ok"
