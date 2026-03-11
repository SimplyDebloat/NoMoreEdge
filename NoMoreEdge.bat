@echo off
setlocal EnableDelayedExpansion
title Advanced Edge Manager (2026)

:check_permissions
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
    exit /b
)

:menu
cls
echo ===========================================
echo       ADVANCED EDGE MANAGER (2026)
echo ===========================================
echo  1) Force Uninstall Microsoft Edge
echo  2) Reinstall Microsoft Edge (via WinGet)
echo  3) Exit
echo ===========================================
set /p choice="Select an option (1-3): "

if "%choice%"=="1" goto force_uninstall
if "%choice%"=="2" goto reinstall
if "%choice%"=="3" exit
goto menu

:force_uninstall
echo.
echo Closing Microsoft Edge processes...
taskkill /f /im msedge.exe /t >nul 2>&1
taskkill /f /im msedgewebview2.exe /t >nul 2>&1
echo Preparing "Exploit" to unlock uninstaller...
:: This specific folder creation 'tricks' Windows into allowing the removal
set "edgeDir=C:\Windows\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe"
if not exist "%edgeDir%" mkdir "%edgeDir%"
type nul > "%edgeDir%\MicrosoftEdge.exe"

echo Searching for installer files...
for /d %%i in ("C:\Program Files (x86)\Microsoft\Edge\Application\*") do (
    if exist "%%i\Installer\setup.exe" (
        echo Found version %%~nxi. Running aggressive removal...
        start /wait "" "%%i\Installer\setup.exe" --uninstall --system-level --verbose-logging --force-uninstall
    )
)

echo Cleaning up registry keys...
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdateDev" /v "AllowUninstall" /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d 1 /f >nul 2>&1

echo.
echo Edge has been targeted. Please check your Start Menu.
echo NOTE: If it's still there, a restart is required to clear locked files.
pause
goto menu

:reinstall
echo.
echo Attempting to reinstall Edge via WinGet...
winget install --id Microsoft.Edge --source winget --accept-source-agreements --accept-package-agreements
if %errorlevel% neq 0 (
    echo.
    echo WinGet failed or not found. Opening official download page...
    start https://www.microsoft.com/edge
)
pause
goto menu
