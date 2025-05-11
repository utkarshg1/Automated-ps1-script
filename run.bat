@echo off
REM Change to the directory where this .bat file resides
cd /d "%~dp0"

REM Launch PowerShell script with elevated privileges
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'powershell.exe' -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','%~dp0automation.ps1' -Verb RunAs"
