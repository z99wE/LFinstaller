@echo off
REM run-windows.bat — Launch LLaMA Factory Web UI on Windows
REM Double-click this file to start the app.
REM If no bundled exe is found, it will build one automatically.

setlocal enabledelayedexpansion

cd /d "%~dp0"

set "EXE_PATH=dist\LLaMAFactory\LLaMAFactory.exe"
set "BUILD_SCRIPT=build-windows.bat"

if exist "%EXE_PATH%" (
    start "" "%EXE_PATH%"
) else (
    echo No bundled executable found. Building first-time...
    echo This may take several minutes. Please be patient.
    call "%BUILD_SCRIPT%"
    start "" "%EXE_PATH%"
)
