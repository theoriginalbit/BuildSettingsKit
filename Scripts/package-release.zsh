#!/usr/bin/env zsh
#
# Packages the already-built gensettings binary into release artifacts:
#   gensettings-macos-arm64.zip            standalone binary + license
#   gensettings.artifactbundle.zip         SwiftPM artifact bundle
#   gensettings.artifactbundle.zip.sha256  checksum for a binaryTarget
#
# Usage (after `swift build -c release`):
#   package-release.zsh <version>

set -euo pipefail

VERSION=${1:?"usage: $0 <version>"}

# Run from the repo root regardless of where the script is invoked from
cd "${0:A:h}/.."

MAC_BINARY=.build/release/gensettings

if [[ ! -f $MAC_BINARY ]]; then
  print -u2 "error: $MAC_BINARY not found; run 'swift build -c release' first"
  exit 1
fi

# --- Standalone zip -------------------------------------------------------
STANDALONE_ZIP=gensettings-macos-arm64.zip

# Make sure the binary is executable, then zip it (no parent dirs) with the license
rm -f "$STANDALONE_ZIP"
ditto -c -k "$MAC_BINARY" LICENSE "$STANDALONE_ZIP"

# --- Artifact bundle ------------------------------------------------------
ARTIFACT_BUNDLE=gensettings.artifactbundle
INFO_TEMPLATE=Scripts/artifactbundle-info.template
MAC_BINARY_OUTPUT_DIR="$ARTIFACT_BUNDLE/gensettings-$VERSION-macos/bin"
MAC_EXECUTABLE="$MAC_BINARY_OUTPUT_DIR/gensettings"

# Start from a clean bundle directory
rm -rf "$ARTIFACT_BUNDLE" "$ARTIFACT_BUNDLE.zip"
mkdir -p "$MAC_BINARY_OUTPUT_DIR"

# Generate info.json by filling the version into the template
jq --arg version "$VERSION" '(.. | strings) |= gsub("__VERSION__"; $version)' \
  "$INFO_TEMPLATE" > "$ARTIFACT_BUNDLE/info.json"

# Copy in the binary (executable) and the license
cp "$MAC_BINARY" "$MAC_EXECUTABLE"
cp LICENSE "$ARTIFACT_BUNDLE/"

# Zip the bundle and compute the checksum SwiftPM's binaryTarget needs
ditto -c -k --keepParent "$ARTIFACT_BUNDLE" "$ARTIFACT_BUNDLE.zip"
swift package compute-checksum "$ARTIFACT_BUNDLE.zip" | tee "$ARTIFACT_BUNDLE.zip.sha256"
