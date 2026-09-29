@echo off
setlocal
cd /d "%~dp0"
title ESP32 NAT Router - 1-Click Flasher
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0flash.ps1"
echo.
pause
