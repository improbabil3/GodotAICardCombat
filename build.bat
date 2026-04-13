@echo off
setlocal enabledelayedexpansion

REM Build script for Windows desktop export (Godot 4.x)
REM Usage: set GODOT_EXE to your Godot editor path, then run this script.

if "%GODOT_EXE%"=="" (
  set "GODOT_EXE=C:\Program Files\Godot\Godot_v4.7-stable_win64.exe"
)

if not exist "%GODOT_EXE%" (
  echo Godot executable not found at "%GODOT_EXE%".
  echo Set the GODOT_EXE environment variable to your Godot editor binary and retry.
  echo Example (PowerShell): $env:GODOT_EXE = 'C:\Path\To\Godot.exe'
  pause
  exit /b 1
)

mkdir build 2>nul
mkdir build\Windows 2>nul
mkdir releases 2>nul

echo Exporting Windows build via Godot...
"%GODOT_EXE%" --export "Windows Desktop" "build\Windows\GalacticClash.exe"
if errorlevel 1 (
  echo Export failed. Check Godot output and export preset name.
  pause
  exit /b 1
)

echo Packaging release ZIP (build/Windows/* → releases/) ...
powershell -NoProfile -Command "Compress-Archive -Path 'build\Windows\*' -DestinationPath 'releases\GalacticClash-win64.zip' -Force"
if errorlevel 1 (
  echo Packaging failed.
  pause
  exit /b 1
)

echo Build + package complete: releases\GalacticClash-win64.zip
endlocal
exit /b 0
