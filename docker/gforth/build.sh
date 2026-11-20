#!/usr/bin/env bash
# Build GForth into $GFORTH_PREFIX (used by Dockerfile).
set -euo pipefail

: "${GFORTH_PREFIX:=/opt/gforth-0.7.9}"
: "${GNU_TARBALL:=https://ftp.gnu.org/gnu/gforth/gforth-0.7.9.tar.gz}"
: "${GIT_TARBALL:=https://github.com/forthy42/gforth/archive/refs/tags/0.7.9_20250101.tar.gz}"

cd /tmp/src

if wget -q --timeout=60 --tries=3 -O gforth.tar.gz "${GNU_TARBALL}"; then
  echo "Using GNU gforth-0.7.9.tar.gz"
else
  echo "GNU tarball unavailable, using Git tag 0.7.9_20250101"
  wget -q --timeout=60 --tries=3 -O gforth.tar.gz "${GIT_TARBALL}"
fi

tar -xf gforth.tar.gz
SRC="$(find . -maxdepth 1 -type d -name 'gforth*' | head -1)"
cd "${SRC}"

if [[ ! -f configure ]]; then
  ./autogen.sh
fi

./configure --prefix="${GFORTH_PREFIX}"

# Full `make -j` also builds optimized engines and runs coretests; those
# checks are flaky under Docker (empty coretest.out). We only need the
# normal `gforth` binary for the VitaSound toolchain.
export TERM=dumb
make -j"$(nproc)" gforth
make install

"${GFORTH_PREFIX}/bin/gforth" --version 2>&1 | grep -q '0.7.9'
echo "Built: $("${GFORTH_PREFIX}/bin/gforth" --version 2>&1 | head -1)"
