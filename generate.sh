#!/usr/bin/env bash
set -euo pipefail
BYOK_TOOL_IMAGE=registry.redhat.io/openshift-lightspeed-tech-preview/lightspeed-rag-tool-rhel9:latest
#BYOK_TOOL_IMAGE=quay.io/rhn-support-alkumari/byok_tool:0.0.1
mkdir -p vector
echo "Workspace contents:"
          ls -la
          ls -la vector

podman run -e OUT_IMAGE_TAG=argocd-byok-image -it --rm --device=/dev/fuse \
  -v $XDG_RUNTIME_DIR/containers/auth.json:/run/user/0/containers/auth.json:Z \
  -v ./data:/markdown:Z \
  -v ./vector:/output:Z \
  $BYOK_TOOL_IMAGE
