@echo off
REM — Change to the directory where this .bat lives
cd /d "%~dp0"

REM — Launch a new PowerShell elevated, bypass policy, run the script
PowerShell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process pwsh -Verb RunAs -ArgumentList @(
     '-NoProfile',
     '-ExecutionPolicy','Bypass',
     '-File','\"%~dp0automation.ps1\"'
  )"
