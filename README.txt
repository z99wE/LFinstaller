================================================================================
                   LLaMA Factory — Installation & Setup Guide
================================================================================

This is a desktop-ready build of LLaMA Factory. You can run it on macOS or
Windows with a double-click — no command line required after the first build.

================================================================================
  PREREQUISITES (one-time only)
================================================================================

You need Python 3.11 or 3.12 installed on your machine before building.

  macOS:
    brew install python@3.11

  Windows:
    Download from https://www.python.org/downloads/
    During installation check "Add Python to PATH"


================================================================================
  FIRST-TIME SETUP — BUILD THE APP
================================================================================

Open a Terminal (macOS) or Command Prompt (Windows) in this folder, then run:

  macOS:
    chmod +x build-mac.sh
    ./build-mac.sh

  Windows:
    build-windows.bat

This does the following automatically:
  - Creates a private virtual environment (.venv/)
  - Installs Python 3.11 if available, or uses the system Python
  - Downloads all dependencies (~3 GB the first time)
  - Packages everything into a standalone app using PyInstaller

The build takes about 10-20 minutes on the first run.
Subsequent rebuilds take ~2 minutes because the cache is reused.

When it finishes you will see:
  macOS  ->  dist/LLaMA Factory.app
  Windows -> dist\LLaMAFactory\LLaMAFactory.exe


================================================================================
  RUNNING THE APP  (after the build)
================================================================================

  macOS — Double-click one of these:
      run-mac.command
    or
      dist/LLaMA Factory.app

  Windows — Double-click one of these:
      run-windows.bat
    or
      dist\LLaMAFactory\LLaMAFactory.exe

After launching, open your browser and go to:
      http://127.0.0.1:7860

That's it — the Gradio web UI will appear.


================================================================================
  WHAT YOU GET AFTER BUILDING
================================================================================

  dist/LLaMA Factory.app       macOS application bundle (double-click to run)
  dist/LLaMAFactory/           Windows onedir app (contains LLaMAFactory.exe)
  run-mac.command              macOS launcher (auto-builds if needed)
  run-windows.bat              Windows launcher (auto-builds if needed)
  build-mac.sh                 Recreate the macOS app
  build-windows.bat            Recreate the Windows exe
  llamafactory.spec            PyInstaller configuration (advanced users)
  src/                         LLaMA Factory source code
  data/dataset_info.json       Default dataset configuration

The .app / .exe folder is roughly 1 GB because it includes PyTorch, Transformers,
Gradio, and every dependency — nothing needs to be downloaded at runtime.
Startup logs are written to ~/llamafactory.log so double-click launches can
be diagnosed if anything fails.


================================================================================
  TROUBLESHOOTING
================================================================================

"Python not found"
  Install Python 3.11 from https://www.python.org/downloads/

"App won't open — unidentified developer" (macOS)
  Right-click the .app > Open > Open again
  Or run: xattr -cr dist/LLaMA\ Factory.app

"Port 7860 already in use"
  Find and kill the process:
    macOS: lsof -ti:7860 | xargs kill
    Windows: netstat -ano | findstr :7860

Build failing with "FileNotFoundError"
  Delete .venv/ and rebuild:
    rm -rf .venv && ./build-mac.sh

Want to start fresh?
  rm -rf build dist .venv
  Then re-run build-mac.sh or build-windows.bat


================================================================================
  ABOUT THIS PROJECT
================================================================================

This package wraps LLaMA Factory (https://github.com/hiyouga/LLaMA-Factory)
using PyInstaller so it runs as a native desktop app on macOS and Windows.

Powered by PyInstaller  ·  Built from LLaMA Factory v0.9.6


================================================================================
