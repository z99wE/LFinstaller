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
    if errorlevel 1 (
        echo [ERROR] Failed to install PyInstaller. Check your network connection.
        exit /b 1
    )
)

:: Install LLaMA Factory runtime dependencies from pyproject.toml.
:: This is the canonical dependency set - do NOT hand-maintain a second list.
echo [INFO] Installing LLaMA Factory dependencies (first run downloads several GB) ...
pip install --quiet -e .
if errorlevel 1 (
    echo [ERROR] pip install failed. Check your network connection and retry.
    exit /b 1
)

:: Verify the core stack imports cleanly. This catches silent partial installs
:: that would otherwise produce a broken executable.
python -c "import torch, gradio, transformers, datasets, accelerate, peft, trl" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Core dependencies are missing or broken. The install did not complete.
    exit /b 1
)

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
