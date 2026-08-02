#!/bin/bash
# build-mac.sh — Build a macOS .app for LLaMA Factory using PyInstaller
#
# Usage:
#   chmod +x build-mac.sh
#   ./build-mac.sh
#
# Output: dist/LLaMA Factory.app  (double-click to launch)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PYINSTALLER_SPEC="llamafactory.spec"
DIST_DIR="dist"
VENV_NAME=".venv"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

[[ -f "$PYINSTALLER_SPEC" ]] || error "Spec file not found: $PYINSTALLER_SPEC"

# ── Pick Python 3.11 or 3.12 (PyInstaller 6.x is buggy on 3.13) ─────────────
PYTHON=""
for _py in python3.11 python3.12 python3; do
    if command -v "$_py" &>/dev/null; then
        PYTHON=$(command -v "$_py")
        break
    fi
done
[[ -n "$PYTHON" ]] || error "No supported Python found. Need 3.11 or 3.12."

PY_VER=$($PYTHON -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || echo "0.0")
major=${PY_VER%.*}; minor=${PY_VER#*.}
if (( major < 3 || (major == 3 && minor < 11) )); then
    error "Python 3.11+ required (found $PY_VER)."
fi
info "Using $PYTHON ($PY_VER)"

# ── Virtual environment ───────────────────────────────────────────────────────
if [[ ! -d "$VENV_NAME" ]]; then
    info "Creating virtual environment in $VENV_NAME ..."
    $PYTHON -m venv "$VENV_NAME" || error "Failed to create venv"
fi
source "$VENV_NAME/bin/activate"
python -m pip install --upgrade pip setuptools wheel --quiet 2>/dev/null

if ! python -c "import PyInstaller" &>/dev/null; then
    info "Installing PyInstaller ..."
    pip install --quiet 'pyinstaller>=6.0,<7.0'
fi

info "Installing LLaMA Factory dependencies ..."
pip install --quiet \
    "torch>=2.4.0" \
    "torchvision>=0.19.0" "torchaudio>=2.4.0" \
    "transformers>=4.55.0,<=5.8.0,!=4.57.0,!=5.6.0" \
    "datasets>=2.16.0,<=4.0.0" \
    "accelerate>=1.3.0" \
    "peft>=0.18.0,<=0.18.1" \
    "trl>=0.18.0,<=0.24.0" \
    "gradio>=4.38.0,<=5.50.0" \
    "matplotlib>=3.7.0" "tyro<0.9.0" \
    "sentencepiece" "tiktoken" "modelscope" "safetensors" "einops" \
    "uvicorn" "fastapi" "sse-starlette" \
    "pyyaml" "omegaconf" "pydantic" "numpy" "pandas" "scipy" \
    "packaging" "protobuf" "fire" "psutil" \
    2>&1 | grep -v "^WARNING\|already satisfied\|^$" || true

export PYTHONPATH="$SCRIPT_DIR/src:${PYTHONPATH:-}"

# ── Build ────────────────────────────────────────────────────────────────────
# ── Clean stale output before building ───────────────────────────────────────
rm -rf "$DIST_DIR/LLaMA Factory.app"
[[ ! -d "$DIST_DIR/LLaMA Factory" ]] || rm -rf "$DIST_DIR/LLaMA Factory"

info "Running PyInstaller ($PYINSTALLER_SPEC) ..."
echo
pyinstaller --noconfirm --clean "$PYINSTALLER_SPEC" 2>&1 | grep -v "^pygame\|^Hello\|^  from\|^  __import__" | tail -20
echo

# ── Verify ────────────────────────────────────────────────────────────────────
# Belt-and-suspenders: some PyInstaller versions drop the ".app" suffix from
# the BUNDLE output dir, so rename it if needed.
if [[ ! -d "$DIST_DIR/LLaMA Factory.app" && -d "$DIST_DIR/LLaMA Factory" ]]; then
    mv "$DIST_DIR/LLaMA Factory" "$DIST_DIR/LLaMA Factory.app"
fi

APP_PATH="$DIST_DIR/LLaMA Factory.app"
if [[ -d "$APP_PATH" ]]; then
    info "✓ Build successful!"
    info "  App bundle : $APP_PATH"
    info "  Double-click it to open LLaMA Factory."
    info "  Or run:     open \"$APP_PATH\""
    echo
    info "To rebuild later:  ./build-mac.sh"
else
    error "Build failed — no app bundle found at $APP_PATH"
fi

info "Virtual environment retained at $VENV_NAME/ (remove manually if needed)"
