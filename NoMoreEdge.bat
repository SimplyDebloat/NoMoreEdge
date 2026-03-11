@echo off
setlocal EnableDelayedExpansion
title Advanced Edge Manager (2026) - Pro Edition

:check_permissions
net session >nul 2>&1
if %errorlevel% neq 0 (
powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
exit /b
)

:menu
cls
echo =========================================================================
echo                ADVANCED EDGE MANAGER (2026)
echo =========================================================================
echo  [!] WARNING: Removing Edge may break Windows Widgets, Teams,
echo      and other apps relying on the WebView2 Runtime.
echo =========================================================================
echo  1) Force Uninstall Microsoft Edge (Aggressive)
echo  2) Reinstall Microsoft Edge (via WinGet)
echo  3) Exit
echo =========================================================================
set /p choice="Select an option (1-3): "

if "%choice%"=="1" goto force_uninstall
if "%choice%"=="2" goto reinstall
if "%choice%"=="3" exit
goto menu

:force_uninstall
echo.
taskkill /f /im msedge.exe /t >nul 2>&1
taskkill /f /im msedgewebview2.exe /t >nul 2>&1

set "edgeDir=C:\Windows\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe"
if not exist "%edgeDir%" mkdir "%edgeDir%" >nul 2>&1
type nul > "%edgeDir%\MicrosoftEdge.exe" 2>nul

set "found=0"
for /d %%i in ("C:\Program Files (x86)\Microsoft\Edge\Application*") do (
if exist "%%i\Installer\setup.exe" (
set "found=1"
start /wait "" "%%i\Installer\setup.exe" --uninstall --system-level --verbose-logging --force-uninstall
)
)

reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdateDev" /v "AllowUninstall" /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d 1 /f >nul 2>&1

echo.
echo Process complete. A restart is recommended.
pause
goto menu

:reinstall
echo.
winget install --id Microsoft.Edge --source winget --accept-source-agreements --accept-package-agreements
if %errorlevel% neq 0 (
start https://www.microsoft.com/edge
)
pause
goto menu