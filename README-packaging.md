# LLaMA Factory — Double-Click Packaging

This folder contains everything needed to package **LLaMA Factory** into a native desktop app that opens with a double-click on **macOS** and **Windows**.

## Quick Start

### macOS
```bash
chmod +x build-mac.sh run-mac.command
./build-mac.sh
```
After building, double-click **`run-mac.command`** to launch LLaMA Factory (or open `dist/LLaMA Factory.app`).

### Windows
Open Command Prompt in this folder and run:
```cmd
build-windows.bat
```
Then double-click **`run-windows.bat`** (or run `dist\LLaMAFactory\LLaMAFactory.exe`).

## What Gets Built

| Platform | Output | Size | How to Launch |
|----------|--------|------|---------------|
| macOS | `dist/LLaMA Factory.app` | ~1 GB | Double-click the `.app` or run `run-mac.command` |
| Windows | `dist\LLaMAFactory\LLaMAFactory.exe` | ~1 GB | Double-click the `.exe` or run `run-windows.bat` |

## Files in This Folder

| File | Purpose |
|------|---------|
| `llamafactory.spec` | PyInstaller spec — tells it exactly what to bundle |
| `build-mac.sh` | One-click macOS builder (creates `.app`) |
| `build-windows.bat` | One-click Windows builder (creates `.exe`) |
| `run-mac.command` | Double-click launcher for macOS |
| `run-windows.bat` | Double-click launcher for Windows |
| `pyproject.toml` | LLaMA Factory project config |
| `src/` | LLaMA Factory source code |
| `data/` | Dataset configuration files |
| `MANIFEST.in` | PyPI manifest |

## Requirements

- **Python 3.11** (recommended) or 3.12 — **NOT 3.13** (PyInstaller has known bugs with 3.13)
- ~15 GB free disk space
- Internet connection (first build downloads dependencies)

## How It Works

1. A virtual environment (`.venv/`) is created automatically using Python 3.11.
2. All dependencies are installed into the venv.
3. **PyInstaller** bundles the Python interpreter, PyTorch, Transformers, Gradio, and all of LLaMA Factory into a single self-contained app.
4. On macOS the result is a proper `.app` bundle. On Windows it's a folder (`dist\LLaMAFactory\`) containing the executable and its libraries.
5. The launcher scripts detect whether a build already exists; if not, they trigger a build automatically.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `python3.11 not found` | Install via `brew install python@3.11` or from [python.org](https://www.python.org/downloads/) |
| Build fails with "module not found" | Delete `.venv/` and re-run — transient network errors can corrupt wheel cache |
| App opens but Gradio doesn't respond | Port 7860 may be in use. Kill existing processes: `lsof -ti:7860 \| xargs kill` |
| First build takes 20+ minutes | Normal — subsequent builds reuse the `.venv` and take ~2 min |
| `FileNotFoundError: .../version.txt` or `.../types.json` | Rebuild — the spec now bundles `gradio`, `gradio_client`, `groovy`, and `safehttpx` data files that ship these |
| App opens but nothing works; check `~/llamafactory.log` | Startup errors are logged there so a double-click launch is diagnosable |
| App won't open on macOS ("unidentified developer") | Right-click → Open → Open again, or run: `xattr -cr dist/LLaMA\ Factory.app` |

## Clean Up

To remove the build artifacts and start fresh:
```bash
rm -rf build dist .venv
```

---

Powered by [PyInstaller](https://pyinstaller.org/) · Built from [LLaMA Factory](https://github.com/hiyouga/LLaMA-Factory)
