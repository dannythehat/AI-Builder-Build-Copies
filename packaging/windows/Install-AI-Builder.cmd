@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-AI-Builder.ps1"
if errorlevel 1 (
  echo.
  echo AI Builder installation could not be completed.
  echo Check that the download was extracted and the app is not already running.
  pause
  exit /b 1
)
exit /b 0
