#!/usr/bin/env bash
# tests/check_integration_test.sh — E2E for fmix check and hook install

set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
export FMIX_HOME="$repo_root"
export PATH="$repo_root/bin:$PATH"

fail() { echo "[FAIL] $*" >&2; exit 1; }
pass() { echo "[OK]   $*"; }

# --- check: test-only stage on clean fixture (no flint/fcov) ---
(
  cd "$repo_root/tests/fixtures/bare_fmix_req"
  FMIX_CHECK_STAGE=pre-commit FMIX_CHECK_NO_FLINT=1 FMIX_CHECK_NO_FCOV=1 \
    fmix check --stage pre-commit >/dev/null
) || fail "fmix check --no-flint --no-fcov on bare_fmix_req"

pass "fmix check pre-commit (test only) on bare_fmix_req"

# --- stage env: FMIX_CHECK_STAGE ---
(
  cd "$repo_root/tests/fixtures/bare_fmix_req"
  FMIX_CHECK_STAGE=pre-push FMIX_CHECK_NO_FLINT=1 FMIX_CHECK_NO_FCOV=1 \
    fmix check >/dev/null
) || fail "FMIX_CHECK_STAGE=pre-push"

pass "FMIX_CHECK_STAGE=pre-push accepted"

# --- hook: install + uninstall in temp git repo ---
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

git -C "$tmpdir" init -q
git -C "$tmpdir" config user.email test@test
git -C "$tmpdir" config user.name test
echo x >"$tmpdir/f"
git -C "$tmpdir" add f
git -C "$tmpdir" commit -qm init

(
  cd "$tmpdir"
  fmix hook install --stage all >/dev/null 2>&1
) || fail "hook install"
[ -x "$tmpdir/.git/hooks/pre-commit" ] || fail "pre-commit hook missing"
[ -x "$tmpdir/.git/hooks/pre-push" ] || fail "pre-push hook missing"
grep -q vitasound-fmix-hook "$tmpdir/.git/hooks/pre-commit" || fail "hook marker missing"

pass "fmix hook install (pre-commit + pre-push)"

(
  cd "$tmpdir"
  fmix hook uninstall --stage all >/dev/null 2>&1
) || fail "hook uninstall"
[ ! -f "$tmpdir/.git/hooks/pre-commit" ] || fail "pre-commit hook still present"
[ ! -f "$tmpdir/.git/hooks/pre-push" ] || fail "pre-push hook still present"

pass "fmix hook uninstall"

# --- hook install outside git → exit 1 ---
(
  cd /tmp
  fmix hook install >/dev/null 2>&1
) && fail "hook install outside git must fail"
pass "hook install outside git exits non-zero"

echo "check_integration_test ok"
