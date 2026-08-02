# LLaMA Factory — Desktop Installer

A PyInstaller-packaged, double-clickable desktop app for [LLaMA Factory](https://github.com/hiyouga/LLaMA-Factory). Runs natively on **macOS** and **Windows** — no Docker, no terminal required after build.

Once built, just double-click an icon and open `http://127.0.0.1:7860` in your browser.

---

## Quick Links

| Platform | What you get | Launch method |
|----------|-------------|---------------|
| **macOS** | `dist/LLaMA Factory.app` (~1 GB) | Double-click `run-mac.command` |
| **Windows** | `dist/LLaMAFactory/LLaMAFactory.exe` (~1 GB) | Double-click `run-windows.bat` |

> ⚠️ The `.app` / `.exe` is large because it bundles PyTorch, Transformers, Gradio, and every dependency — nothing downloads at runtime.

---

## How to Install

### Prerequisites (one-time only)

You need **Python 3.11** or **3.12** on your machine before building.

```bash
# macOS — via Homebrew
brew install python@3.11

# Windows — download from https://www.python.org/downloads/
#   During installation check "Add Python to PATH"
```

### Step 1 — Clone or download this repo

```bash
git clone https://github.com/z99wE/LFinstaller.git
cd LFinstaller
```

Or download the ZIP and extract it.

### Step 2 — Build the app

Open a Terminal (macOS) or Command Prompt (Windows) inside this folder, then run:

**macOS**
```bash
chmod +x build-mac.sh
./build-mac.sh
```

**Windows**
```cmd
build-windows.bat
```

This script does everything automatically:
- Creates an isolated virtual environment (`.venv/`)
- Installs Python 3.11 if available, otherwise uses system Python
- Downloads all dependencies (~3 GB on first run)
- Runs PyInstaller to package everything into a standalone app

The first build takes **10–20 minutes**. Subsequent builds reuse the cache and take **~2 minutes**.

When it finishes you will see:

```
dist/
├── LLaMA Factory.app      ← macOS application bundle
└── LLaMAFactory/
    └── LLaMAFactory.exe   ← Windows executable (inside its folder)
```

### Step 3 — Run the app

**macOS** — double-click one of these:
```
run-mac.command
dist/LLaMA Factory.app
```

**Windows** — double-click one of these:
```
run-windows.bat
dist\LLaMAFactory\LLaMAFactory.exe
```

After launching, open your browser and go to:
```
http://127.0.0.1:7860
```

That's it — the Gradio web UI appears. 🎉

---

## File Breakdown

| File | Purpose |
|------|---------|
| `build-mac.sh` | One-click macOS builder |
| `build-windows.bat` | One-click Windows builder |
| `run-mac.command` | macOS launcher (auto-builds if needed) |
| `run-windows.bat` | Windows launcher (auto-builds if needed) |
| `llamafactory.spec` | PyInstaller configuration |
| `runtime_hooks.py` | Startup log hook — writes `~/llamafactory.log` |
| `src/` | LLaMA Factory source code |
| `data/dataset_info.json` | Default dataset configuration |
| `README.txt` | Extended plain-text installation guide |
| `pyproject.toml` | LLaMA Factory project config |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `python3.11 not found` | Install via `brew install python@3.11` or from [python.org](https://www.python.org/downloads/) |
| App won't open — *"unidentified developer"* (macOS) | Right-click the `.app` → **Open** → click **Open** again. Or run: `xattr -cr dist/LLaMA\ Factory.app` |
| Port 7860 already in use | Kill the existing process:<br>`lsof -ti:7860 \| xargs kill` (macOS)<br>`netstat -ano \| findstr :7860` then `taskkill /PID <pid>` (Windows) |
| `FileNotFoundError` at startup | Delete `.venv/` and rebuild: `rm -rf .venv && ./build-mac.sh` |
| App launches but nothing works | Check `~/llamafactory.log` — every startup error is logged there |
| First build takes too long | Normal — it downloads ~3 GB of wheels. Subsequent builds are fast thanks to caching. |
| Want to start completely fresh | `rm -rf build dist .venv llamaboard_cache && ./build-mac.sh` |

---

## Reproducing the Build Yourself

If you want to customize the build (different Python version, extra flags):

```bash
# Make sure you're in the repo root
source .venv/bin/activate        # macOS
# .venv\Scripts\activate         # Windows

pip install pyinstaller
python -m PyInstaller --noconfirm --clean llamafactory.spec
```

---

## About This Project

This repository wraps [LLaMA Factory](https://github.com/hiyouga/LLaMA-Factory) using PyInstaller so it runs as a native desktop application on macOS and Windows. The packaging scripts, specs, and configuration were generated to produce a self-contained app that requires no separate Python installation to run.

**Powered by:** PyInstaller · **Built from:** LLaMA Factory v0.9.6
