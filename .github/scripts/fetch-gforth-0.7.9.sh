#!/usr/bin/env bash
# CI helper: prefer prebuilt GForth from GHCR; fall back to source build.
set -euo pipefail

PREFIX="${HOME}/opt/gforth-0.7.9"
IMAGE="${GFORTH_IMAGE:-ghcr.io/vitasound/gforth:0.7.9}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ -x "${PREFIX}/bin/gforth" ]] \
  && "${PREFIX}/bin/gforth" --version 2>&1 | grep -q '0.7.9'; then
  echo "GForth 0.7.9 already present at ${PREFIX}"
  echo "${PREFIX}/bin" >> "${GITHUB_PATH:-/dev/null}"
  exit 0
fi

if command -v docker >/dev/null 2>&1; then
  echo "Trying GHCR image ${IMAGE} ..."
  if docker pull "${IMAGE}"; then
    cid="$(docker create "${IMAGE}")"
    mkdir -p "$(dirname "${PREFIX}")"
    rm -rf "${PREFIX}"
    docker cp "${cid}:/opt/gforth-0.7.9" "${PREFIX}"
    docker rm -f "${cid}" >/dev/null
    "${PREFIX}/bin/gforth" --version 2>&1 | grep -q '0.7.9'
    echo "Installed from GHCR: $("${PREFIX}/bin/gforth" --version 2>&1 | head -1)"
    echo "${PREFIX}/bin" >> "${GITHUB_PATH}"
    exit 0
  fi
  echo "GHCR pull failed; falling back to source build"
fi

bash "${ROOT}/.github/scripts/build-gforth-0.7.9.sh"
