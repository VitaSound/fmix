#!/usr/bin/env bash
# Install GForth 0.7.9 from the VitaSound GHCR image onto the host.
#
#   bash scripts/install-gforth-from-ghcr.sh
#   export PATH="$HOME/opt/gforth-0.7.9/bin:$PATH"
#   gforth --version
#
# Requires: docker (or podman with `docker` alias), network access to ghcr.io.
# Does not use snap.

set -euo pipefail

IMAGE="${GFORTH_IMAGE:-ghcr.io/vitasound/gforth:0.7.9}"
PREFIX="${GFORTH_PREFIX:-${HOME}/opt/gforth-0.7.9}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found. Install Docker, then re-run this script." >&2
  echo "Or build from source: bash .github/scripts/build-gforth-0.7.9.sh" >&2
  exit 1
fi

if docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  echo "Using local image ${IMAGE}"
else
  echo "Pulling ${IMAGE} ..."
  docker pull "${IMAGE}"
fi

cid="$(docker create "${IMAGE}")"
cleanup() { docker rm -f "${cid}" >/dev/null 2>&1 || true; }
trap cleanup EXIT

rm -rf "${PREFIX}"
mkdir -p "$(dirname "${PREFIX}")"
docker cp "${cid}:/opt/gforth-0.7.9" "${PREFIX}"

"${PREFIX}/bin/gforth" --version 2>&1 | grep -q '0.7.9'
echo "Installed: $("${PREFIX}/bin/gforth" --version 2>&1 | head -1)"
echo "Add to PATH:"
echo "  export PATH=\"${PREFIX}/bin:\$PATH\""
