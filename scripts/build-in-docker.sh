#!/usr/bin/env bash
#
# Build the FlowtoysUpdater binary inside a container
#
set -euo pipefail

cd "$(dirname "$0")/.."

ENGINE="${CONTAINER_ENGINE:-podman}"
OUT_DIR="prebuilt/linux_amd64"

echo ">> Building FlowtoysUpdater with ${ENGINE}"
mkdir -p "${OUT_DIR}"

DOCKER_BUILDKIT=1 "${ENGINE}" build \
  --target artifact \
  --output "type=local,dest=${OUT_DIR}" \
  -f Dockerfile .

chmod +x "${OUT_DIR}/FlowtoysUpdater"
echo ">> Wrote ${OUT_DIR}/FlowtoysUpdater"
