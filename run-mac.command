#!/bin/bash
# run-mac.command — Launch LLaMA Factory Web UI on macOS
# Double-click this file to start the app.
# If no bundled app is found, it will build one automatically.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

APP_PATH="dist/LLaMA Factory.app"
BUILD_SCRIPT="build-mac.sh"

if [[ -d "$APP_PATH" ]]; then
    exec open "$APP_PATH"
else
    echo "No bundled app found. Building first-time..."
    echo "This may take several minutes. Please be patient."
    bash "$BUILD_SCRIPT"
    exec open "$APP_PATH"
fi
