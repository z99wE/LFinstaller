@echo off
REM build-windows.bat — Build a Windows .exe for LLaMA Factory using PyInstaller
REM
REM Usage (from this folder in CMD):
REM   build-windows.bat
REM
REM Note: Requires Python 3.11+ with pip.

setlocal enabledelayedexpansion

set "SPEC_FILE=llamafactory.spec"
set "DIST_DIR=dist"
set "VENV_NAME=.venv"

:: ── Colour helpers (works in modern Windows terminals) ──────────────────────
set "RED=" & set "GREEN=" & set "YELLOW=" & set "NC="
if exist "%TEMP%\__lf_has_color" (
    chcp 65001 >nul 2>&1
)

:: ── Pre-flight checks ───────────────────────────────────────────────────────
if not exist "%SPEC_FILE%" (
    echo [ERROR] Spec file not found: %SPEC_FILE%
    exit /b 1
)

:: Find python3
where python >nul 2>&1 || (
    echo [ERROR] python not found. Install Python 3.11+ from https://www.python.org/downloads/
    exit /b 1
)

for /f "tokens=2 delims=." %%a in ('python -c "import sys; print(sys.version)"') do set PY_MIN=%%a
if !PY_MIN! lss 11 (
    echo [ERROR] Python 3.11+ is required. Found version above.
    exit /b 1
)
echo [INFO] Python found.

:: ── Create / activate virtual environment ───────────────────────────────────
if not exist "%VENV_NAME%" (
    echo [INFO] Creating virtual environment ...
    python -m venv "%VENV_NAME%" || (
        echo [ERROR] Failed to create venv
        exit /b 1
    )
)
call "%VENV_NAME%\Scripts\activate.bat"

:: Upgrade pip
python -m pip install --upgrade pip setuptools wheel --quiet 2>nul

:: Install PyInstaller if missing
python -c "import PyInstaller" 2>nul || (
    echo [INFO] Installing PyInstaller ...
    pip install --quiet pyinstaller
)

:: Install LLaMA Factory runtime dependencies
echo [INFO] Installing LLaMA Factory dependencies ...
pip install --quiet ^
    "torch>=2.4.0" ^
    "torchvision>=0.19.0" "torchaudio>=2.4.0" ^
    "transformers>=4.55.0,<=5.8.0,!=4.57.0,!=5.6.0" ^
    "datasets>=2.16.0,<=4.0.0" ^
    "accelerate>=1.3.0" ^
    "peft>=0.18.0,<=0.18.1" ^
    "trl>=0.18.0,<=0.24.0" ^
    "gradio>=4.38.0,<=5.50.0" ^
    "matplotlib>=3.7.0" "tyro<0.9.0" ^
    "sentencepiece" "tiktoken" "modelscope" "safetensors" "einops" ^
    "uvicorn" "fastapi" "sse-starlette" ^
    "pyyaml" "omegaconf" "pydantic" "numpy" "pandas" "scipy" ^
    "packaging" "protobuf" "fire" "psutil" 2>nul

set "PYTHONPATH=%CD%\src;%PYTHONPATH%"

:: ── Build ───────────────────────────────────────────────────────────────────
echo.
echo [INFO] Running PyInstaller (%SPEC_FILE%) ...
echo.
pyinstaller --noconfirm --clean "%SPEC_FILE%" 2>&1 | findstr /V "WARNING already satisfied"
echo.

:: ── Verify ──────────────────────────────────────────────────────────────────
if exist "%DIST_DIR%\LLaMAFactory\LLaMAFactory.exe" (
    echo [OK] Build successful!
    echo     Exe : %DIST_DIR%\LLaMAFactory\LLaMAFactory.exe
    echo.
    echo     Double-click LLaMAFactory.exe to launch LLaMA Factory.
) else if exist "%DIST_DIR%\LLaMA Factory.app" (
    echo [OK] Build successful!
    echo     App : %DIST_DIR%\LLaMA Factory.app
) else (
    echo [ERROR] Build failed — no executable found in %DIST_DIR%\
    exit /b 1
)

echo.
echo [INFO] Virtual environment kept at %VENV_NAME%\ (remove manually if needed)
if "%CI%"=="" pause
