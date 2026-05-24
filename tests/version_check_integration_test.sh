#!/usr/bin/env bash
# tests/version_check_integration_test.sh
#
# Smoke tests for fmix_version_check.4th, exercised through the bash
# launcher because the check fires before the Forth-side test runner
# is invoked. Drives the four canonical scenarios:
#
#   1. needs_future_fmix/   — `key-value fmix ~> 99.0`  → must reject
#   2. legacy_fmix_dep/     — pre-0.7.0 `key-list dependencies fmix …`
#                                                         → must reject with migration hint
#   3. invalid_fmix_req/    — `key-value fmix ~> abc`   → must reject with parse-error msg
#   4. bare_fmix_req/       — `key-value fmix 0.0.1`    → must succeed
#
# Plus: `fmix version` / `fmix help` must always work, even inside a
# project the current fmix can't satisfy.
#
# Run via: bash tests/version_check_integration_test.sh

set -u

repo_root=$(cd "$(dirname "$0")/.." && pwd)

fail() { echo "[FAIL] $*" >&2; exit 1; }
pass() { echo "[OK]   $*"; }

# -----------------------------------------------------------------------
# 1. needs_future_fmix: pinned to ~> 99.0 → must be rejected.
# -----------------------------------------------------------------------
fixture="$repo_root/tests/fixtures/needs_future_fmix"
cd "$fixture"

out=$(FMIX_HOME="$repo_root" bash "$repo_root/bin/fmix" test 2>&1)
status=$?
[ "$status" -ne 0 ] || fail "fmix test on needs_future_fmix expected to fail; output:
$out"
grep -q "requires fmix ~> 99.0" <<<"$out" \
    || fail "needs_future_fmix did not echo the required '~> 99.0'; output:
$out"
grep -q "dummy_test SHOULD NOT RUN" <<<"$out" \
    && fail "test runner was reached despite version mismatch; output:
$out"
pass "needs_future_fmix: fmix test rejects ~> 99.0 (exit=$status)"

out=$(FMIX_HOME="$repo_root" bash "$repo_root/bin/fmix" packages.get 2>&1)
status=$?
[ "$status" -ne 0 ] || fail "fmix packages.get on needs_future_fmix expected to fail; output:
$out"
pass "needs_future_fmix: fmix packages.get rejects ~> 99.0 (exit=$status)"

# -----------------------------------------------------------------------
# 2. legacy_fmix_dep: still uses `key-list dependencies fmix <ver>`.
# -----------------------------------------------------------------------
fixture="$repo_root/tests/fixtures/legacy_fmix_dep"
cd "$fixture"

out=$(FMIX_HOME="$repo_root" bash "$repo_root/bin/fmix" test 2>&1)
status=$?
[ "$status" -ne 0 ] || fail "fmix test on legacy_fmix_dep expected to fail; output:
$out"
grep -q "no longer supported" <<<"$out" \
    || fail "legacy_fmix_dep error didn't mention 'no longer supported'; output:
$out"
grep -q "key-value fmix ~>" <<<"$out" \
    || fail "legacy_fmix_dep error didn't show the migration target; output:
$out"
grep -q "dummy_test SHOULD NOT RUN" <<<"$out" \
    && fail "legacy_fmix_dep test runner was reached; output:
$out"
pass "legacy_fmix_dep: rejected with migration hint (exit=$status)"

# -----------------------------------------------------------------------
# 3. invalid_fmix_req: malformed `~> abc`.
# -----------------------------------------------------------------------
fixture="$repo_root/tests/fixtures/invalid_fmix_req"
cd "$fixture"

out=$(FMIX_HOME="$repo_root" bash "$repo_root/bin/fmix" test 2>&1)
status=$?
[ "$status" -ne 0 ] || fail "fmix test on invalid_fmix_req expected to fail; output:
$out"
grep -q "Invalid fmix version requirement" <<<"$out" \
    || fail "invalid_fmix_req error didn't mention 'Invalid fmix version requirement'; output:
$out"
pass "invalid_fmix_req: rejected with parse-error msg (exit=$status)"

# -----------------------------------------------------------------------
# 4. bare_fmix_req: `key-value fmix 0.0.1` (bare = >= 0.0.1), trivially OK.
# -----------------------------------------------------------------------
fixture="$repo_root/tests/fixtures/bare_fmix_req"
cd "$fixture"

out=$(FMIX_HOME="$repo_root" bash "$repo_root/bin/fmix" test 2>&1)
status=$?
[ "$status" -eq 0 ] || fail "fmix test on bare_fmix_req expected to succeed; output:
$out"
grep -q "sanity_test ok" <<<"$out" \
    || fail "bare_fmix_req sanity test did not run; output:
$out"
pass "bare_fmix_req: test ran successfully (exit=$status)"

# -----------------------------------------------------------------------
# 5. `fmix version` / `fmix help` must always work, even in a broken project.
# -----------------------------------------------------------------------
cd "$repo_root/tests/fixtures/needs_future_fmix"

out=$(FMIX_HOME="$repo_root" bash "$repo_root/bin/fmix" version 2>&1)
status=$?
[ "$status" -eq 0 ] || fail "fmix version must always work; got $status; output:
$out"
pass "fmix version unaffected by project requirement (exit=$status)"

out=$(FMIX_HOME="$repo_root" bash "$repo_root/bin/fmix" help 2>&1)
status=$?
[ "$status" -eq 0 ] || fail "fmix help must always work; got $status; output:
$out"
pass "fmix help unaffected by project requirement (exit=$status)"

echo
echo "version_check_integration_test ok"
