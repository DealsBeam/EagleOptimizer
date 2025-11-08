@echo off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::  Windows 11 PC Optimizer v3.8
::
::  This script provides a collection of tools to optimize Windows 11 performance,
::  clean junk files, and apply various system tweaks.
::
::  Author: Your Name
::  Version: 3.8
::
::  Changelog v3.8:
::  - Feature: Added a true backup/restore system for Service Management.
::  - Feature: Added a true backup/restore system for Game Mode tweaks.
::  - Bugfix: Corrected numbering in the Help section.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: -----------------------------------------------------------------------------
::  Initial Setup
:: -----------------------------------------------------------------------------
chcp 65001 >nul
title Windows 11 PC Optimizer v3.8
mode con: cols=80 lines=33

:: Define ANSI color codes
(echo prompt $E^| cmd) > "%TEMP%\get_esc.cmd"
for /F "delims=" %%a in ('"%TEMP%\get_esc.cmd"') do set "ESC=%%a"
del "%TEMP%\get_esc.cmd" >nul 2>&1
set "COLOR_RESET=%ESC%[0m"
set "COLOR_RED=%ESC%[91m"
set "COLOR_GREEN=%ESC%[92m"
set "COLOR_YELLOW=%ESC%[93m"
set "COLOR_CYAN=%ESC%[96m"
set "spinner=|/-\"

:: -----------------------------------------------------------------------------
::  Pre-loader and Admin Check
:: -----------------------------------------------------------------------------
cls
echo.
echo                                +-----------------------------+
echo                                |  Windows 11 PC Optimizer    |
echo                                +-----------------------------+
echo.
set msg=Initializing...
call :spinner "%msg%"
call :_Print "green" "[ OK ]" "Initialization Finished!"
timeout /t 1 >nul

net session >nul 2>&1
if %errorLevel% neq 0 (
    call :_Print "red" "[FATAL]" "This script requires administrator privileges."
    echo.
    echo %COLOR_YELLOW%Right-click the script and select "Run as administrator".%COLOR_RESET%
    echo.
    pause
    exit
)
if not exist "%~dp0Undo" mkdir "%~dp0Undo"

:: -----------------------------------------------------------------------------
::  Automated/Silent Mode Argument Parser
:: -----------------------------------------------------------------------------
if /i "%~1" equ "/clean" goto SILENT_CLEAN
if /i "%~1" equ "/cleanx" goto SILENT_CLEANX
if /i "%~1" equ "/junk" goto SILENT_JUNK
if /i "%~1" equ "/dns" goto SILENT_DNS
if /i "%~1" equ "/gamemode" goto SILENT_GAMEMODE
if /i "%~1" equ "/rstnet" goto SILENT_RSTNET
if /i "%~1" equ "/sysinfo" goto SILENT_SYSINFO
if /i "%~1" neq "" (
    if /i "%~1" equ "/?" goto SILENT_HELP
    if /i "%~1" equ "/help" goto SILENT_HELP
    call :_Print "red" "[ERROR]" "Invalid argument: %1"
    call :SILENT_HELP
    goto :EOF
)

:: #############################################################################
::  MAIN MENU
:: #############################################################################
:MENU
cls
echo.
echo            %COLOR_CYAN%+-+------------------------------------------+-+%COLOR_RESET%
echo            %COLOR_CYAN%| |    WINDOWS 11 PC OPTIMIZER v3.8            | |%COLOR_RESET%
echo            %COLOR_CYAN%+-+------------------------------------------+-+%COLOR_RESET%
echo.
echo    [1] Optimize Network        - Improves network stability and lowers ping.
echo    [2] System Cleaner          - Cleans temporary files, cache, and update leftovers.
echo    [3] Extended Cleaner        - Cleans browser and Explorer cache.
echo    [4] Junk Finder             - Removes deep logs and dumps from your system drive.
echo    [5] Windows Debloater       - Uninstalls pre-installed Microsoft Store apps.
echo    [6] Optimize DNS            - Switches to Cloudflare DNS for faster and more private browsing.
echo    [7] Manage Services         - Disables unnecessary services like SysMain, Telemetry, and Xbox.
echo    [8] Game Mode + GPU Priority- Optimizes system for gaming.
echo    [9] Advanced Windows Tweaks - Applies advanced tweaks for Prefetch, RAM, and DirectX.
echo    [10] Reset Network Adapter  - Resets the network adapter to default settings.
echo    [11] Input Latency Tweaks   - Reduces input latency for a more responsive experience.
echo    [12] Backup and Restore     - Creates a system restore point and backs up the registry.
echo    [13] Help / Information     - Provides a detailed overview of the script's functionality.
echo    [14] Undo Tweaks            - Reverts specific changes made by the script.
echo    [15] System Information     - Displays key system information.
echo    [0] Exit
echo.
set /p choice="          Select an option: "
if /i "%choice%"=="1" goto ACTION_NET
if /i "%choice%"=="2" goto ACTION_CLEAN
if /i "%choice%"=="3" goto ACTION_CLEANX
if /i "%choice%"=="4" goto ACTION_JUNK
if /i "%choice%"=="5" goto ACTION_DEBLOAT
if /i "%choice%"=="6" goto ACTION_DNS
if /i "%choice%"=="7" goto ACTION_SERV
if /i "%choice%"=="8" goto ACTION_GAMEMODE
if /i "%choice%"=="9" goto ADVANCED_TWEAKS
if /i "%choice%"=="10" goto ACTION_RSTNET
if /i "%choice%"=="11" goto ACTION_INPUT
if /i "%choice%"=="12" goto BACKUP_RESTORE
if /i "%choice%"=="13" goto HELP
if /i "%choice%"=="14" goto UNDO_TWEAKS
if /i "%choice%"=="15" goto ACTION_SYSINFO
if /i "%choice%"=="0" goto EXIT
goto MENU

:: #############################################################################
::  HELPER SUBROUTINES
:: #############################################################################

:: -------- Color Printing Function
:_Print
    set "color_name=%~1"
    set "prefix=%~2"
    set "message=%~3"
    if /i "%color_name%" == "red" (
        echo(%COLOR_RED%%prefix% %message%%COLOR_RESET%
    ) else if /i "%color_name%" == "green" (
        echo(%COLOR_GREEN%%prefix% %message%%COLOR_RESET%
    ) else if /i "%color_name%" == "yellow" (
        echo(%COLOR_YELLOW%%prefix% %message%%COLOR_RESET%
    ) else if /i "%color_name%" == "cyan" (
        echo(%COLOR_CYAN%%prefix% %message%%COLOR_RESET%
    ) else (
        echo(%prefix% %message%
    )
    goto :EOF

:: -------- Spinner Animation
:spinner
setlocal enabledelayedexpansion
set "msg=%~1"
for /L %%i in (1,1,20) do (
    set /a "idx=%%i %% 4"
    <nul set /p="                           !msg! !spinner:~%idx%,1!\r"
    >nul ping -n 1 -w 100 127.0.0.1
)
endlocal
echo.
goto :EOF

:: -------- Progress Animation
:progress
setlocal enabledelayedexpansion
set "msg=%~1"
echo.
for /L %%i in (1,1,36) do (
    set "bar=["
    for /L %%j in (1,1,%%i) do set "bar=!bar!█"
    for /L %%k in (%%i,1,36) do set "bar=!bar! "
    set "bar=!bar!]"
    <nul set /p="                 !msg! !bar!`r"
    >nul ping -n 1 -w 5 127.0.0.1
)
echo.
endlocal
goto :EOF

:: #############################################################################
::  INTERACTIVE ACTIONS
:: #############################################################################

:ACTION_NET
cls
call :LOG "Selected option: 1 - Optimize Network"
call :progress "Optimizing Network"
call :SILENT_NET
echo.
call :_Print "green" "[STATUS]" "Network optimization complete!"
pause
goto MENU

:ACTION_CLEAN
cls
call :LOG "Selected option: 2 - System Cleaner"
call :_Print "yellow" "[WARNING]" "This will delete temporary files."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto MENU
call :progress "System Clean"
call :SILENT_CLEAN
echo.
call :_Print "green" "[STATUS]" "Junk cleaned."
pause
goto MENU

:ACTION_CLEANX
cls
call :LOG "Selected option: 3 - Extended Cleaner"
call :_Print "yellow" "[WARNING]" "This will delete browser and Explorer cache files."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto MENU
call :progress "Extended Cleaner"
call :SILENT_CLEANX
echo.
call :_Print "green" "[STATUS]" "Browser/Explorer cache cleaned."
pause
goto MENU

:ACTION_JUNK
cls
call :LOG "Selected option: 4 - Junk Finder"
call :_Print "red" "[CRITICAL]" "This is an aggressive cleanup and may delete important files if"
call :_Print "red" "[CRITICAL]" "you have custom software that uses .log, .bak, or .old extensions."
call :_Print "yellow" "[WARNING]" "It is recommended to back up important data before proceeding."
echo.
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto MENU
call :progress "Junk Finder"
call :SILENT_JUNK
echo.
call :_Print "green" "[STATUS]" "Deep junk removed."
pause
goto MENU

:ACTION_DEBLOAT
cls
call :LOG "Selected option: 5 - Windows Debloater"
:DEBLOAT_MENU
cls
echo.
echo            %COLOR_CYAN%+-+------------------------------------------+-+%COLOR_RESET%
echo            %COLOR_CYAN%| |              WINDOWS DEBLOATER             | |%COLOR_RESET%
echo            %COLOR_CYAN%+-+------------------------------------------+-+%COLOR_RESET%
echo.
echo    [1] Recommended Debloat (Removes common bloatware)
echo    [2] Custom Debloat (Choose which apps to remove)
echo    [0] Back to Main Menu
echo.
set /p debloat_choice="          Select an option: "
if /i "%debloat_choice%"=="1" goto DEBLOAT_RECOMMENDED
if /i "%debloat_choice%"=="2" goto DEBLOAT_CUSTOM
if /i "%debloat_choice%"=="0" goto MENU
goto DEBLOAT_MENU

:DEBLOAT_RECOMMENDED
cls
call :LOG "Selected Debloater option: Recommended"
call :_Print "yellow" "[WARNING]" "This will remove a list of common bloatware apps."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto DEBLOAT_MENU
call :progress "Removing recommended bloatware..."
set "debloat_list=Microsoft.549981C3F5F10;Microsoft.BingNews;Microsoft.BingWeather;Microsoft.GetHelp;Microsoft.Getstarted;Microsoft.MicrosoftOfficeHub;Microsoft.MicrosoftSolitaireCollection;Microsoft.People;Microsoft.SkypeApp;Microsoft.WindowsAlarms;Microsoft.WindowsCamera;microsoft.windowscommunicationsapps;Microsoft.WindowsFeedbackHub;Microsoft.WindowsMaps;Microsoft.YourPhone;Microsoft.ZuneMusic;Microsoft.ZuneVideo;king.com.CandyCrushSaga"
for %%a in (%debloat_list%) do (
    call :_Print "cyan" "[INFO]" "Removing %%a..."
    powershell.exe -ExecutionPolicy Bypass -Command "Get-AppxPackage *%%a* | Remove-AppxPackage"
    call :LOG "Removed AppX Package: %%a"
)
echo.
call :_Print "green" "[STATUS]" "Recommended bloatware removed."
pause
goto DEBLOAT_MENU

:DEBLOAT_CUSTOM
cls
call :LOG "Selected Debloater option: Custom"
call :_Print "yellow" "[WARNING]" "This will allow you to select and remove specific Microsoft Store apps."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto DEBLOAT_MENU

:DEBLOAT_CUSTOM_LOOP
cls
call :_Print "cyan" "[INFO]" "Loading list of installed apps..."
powershell.exe -ExecutionPolicy Bypass -Command "Get-AppxPackage | Select-Object -Property Name, PackageFullName | Format-Table -AutoSize"
echo.
set /p app_name="Enter the full or partial name of the app to remove (or type 'exit' to return): "
if /i "%app_name%"=="exit" goto DEBLOAT_MENU

call :progress "Removing app..."
powershell.exe -ExecutionPolicy Bypass -Command "Get-AppxPackage *%app_name%* | Remove-AppxPackage"
call :LOG "Removed AppX Package: %app_name%"
echo.
call :_Print "green" "[STATUS]" "App removed. You can remove another or type 'exit'."
pause
goto DEBLOAT_CUSTOM_LOOP

:ACTION_DNS
cls
call :LOG "Selected option: 6 - Optimize DNS"
call :progress "Optimizing DNS"
call :SILENT_DNS
echo.
call :_Print "green" "[STATUS]" "DNS optimization done."
pause
goto MENU

:ACTION_SERV
cls
call :LOG "Selected option: 7 - Manage Services"
call :progress "Service Tuning"
echo [1] Disable unnecessary services (SysMain, Telemetry, Xbox)
if exist "%~dp0Undo\Services_SysMain.bat" echo [2] Restore original state
set /p svch="Choose 1/2 or [Enter] to back: "
if "%svch%"=="1" (
    call :_Print "yellow" "[WARNING]" "This will disable several Windows services and back up their current state."
    set /p confirm="Are you sure you want to continue? (Y/N): "
    if /i not "%confirm%"=="Y" goto MENU

    call :_Print "cyan" "[INFO]" "Backing up service configurations..."
    set "service_list=SysMain DiagTrack dmwappushservice XblAuthManager XblGameSave XboxNetApiSvc"
    for %%s in (%service_list%) do (
        (for /f "tokens=2" %%i in ('sc query "%%s" ^| find "STATE"') do (
            if "%%i"=="RUNNING" (echo sc start "%%s") else (echo sc stop "%%s")
        )) > "%~dp0Undo\Services_%%s.bat"
        (for /f "tokens=3" %%i in ('sc qc "%%s" ^| find "START_TYPE"') do (
            echo sc config "%%s" start=%%i
        )) >> "%~dp0Undo\Services_%%s.bat"
    )
    reg export "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "%~dp0Undo\Services_Telemetry.reg" /y

    call :_Print "cyan" "[INFO]" "Disabling services..."
    sc config "SysMain" start=disabled & sc stop "SysMain"
    sc config "DiagTrack" start=disabled & sc stop "DiagTrack"
    sc config "dmwappushservice" start=disabled & sc stop "dmwappushservice"
    sc config "XblAuthManager" start=disabled & sc stop "XblAuthManager"
    sc config "XblGameSave" start=disabled & sc stop "XblGameSave"
    sc config "XboxNetApiSvc" start=disabled & sc stop "XboxNetApiSvc"
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f

    echo.
    call :_Print "green" "[STATUS]" "Services disabled. Restart recommended!"
    pause
    goto MENU
)
if "%svch%"=="2" (
    if not exist "%~dp0Undo\Services_SysMain.bat" goto MENU
    call :_Print "yellow" "[WARNING]" "This will restore the original service configurations."
    set /p confirm="Are you sure you want to continue? (Y/N): "
    if /i not "%confirm%"=="Y" goto MENU

    call :_Print "cyan" "[INFO]" "Restoring services..."
    set "service_list=SysMain DiagTrack dmwappushservice XblAuthManager XblGameSave XboxNetApiSvc"
    for %%s in (%service_list%) do (
        if exist "%~dp0Undo\Services_%%s.bat" (
            call "%~dp0Undo\Services_%%s.bat"
        )
    )
    reg import "%~dp0Undo\Services_Telemetry.reg"

    call :_Print "cyan" "[INFO]" "Cleaning up backup files..."
    for %%s in (%service_list%) do (
        if exist "%~dp0Undo\Services_%%s.bat" (
            del "%~dp0Undo\Services_%%s.bat"
        )
    )
    del "%~dp0Undo\Services_Telemetry.reg"

    echo.
    call :_Print "green" "[STATUS]" "Services restored."
    pause
    goto MENU
)
goto MENU

:ACTION_GAMEMODE
cls
call :LOG "Selected option: 8 - Game Mode + GPU Priority"
call :_Print "yellow" "[WARNING]" "This will modify system settings for gaming optimization and back up current values."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto MENU

call :_Print "cyan" "[INFO]" "Backing up current game mode settings..."
reg export "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\Settings" "%~dp0Undo\GameMode_PowerSettings.reg" /y
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "%~dp0Undo\GameMode_Multimedia.reg" /y
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "%~dp0Undo\GameMode_BackgroundApps.reg" /y

call :progress "Gaming Optimization"
call :SILENT_GAMEMODE
echo.
call :_Print "green" "[STATUS]" "Game Mode, GPU/CPU priority and background apps optimized."
pause
goto MENU

:ADVANCED_TWEAKS
cls
call :LOG "Selected option: 9 - Advanced Windows Tweaks"
:ADVANCED_TWEAKS_MENU
cls
echo.
echo            %COLOR_CYAN%+-+------------------------------------------+-+%COLOR_RESET%
echo            %COLOR_CYAN%| |           ADVANCED WINDOWS TWEAKS          | |%COLOR_RESET%
echo            %COLOR_CYAN%+-+------------------------------------------+-+%COLOR_RESET%
echo.
echo    [1] Enable AdaptiveSync for DirectX
echo    [2] Enable Large System Cache
echo    [3] Disable Prefetcher and Superfetch (for SSDs)
echo    [4] Clear Crash Dumps (Minidump)
echo    [0] Back to Main Menu
echo.
set /p adv_choice="          Select a tweak to apply: "
if /i "%adv_choice%"=="1" goto ACTION_ADAPTIVESYNC
if /i "%adv_choice%"=="2" goto ACTION_LARGESYSTEMCACHE
if /i "%adv_choice%"=="3" goto ACTION_PREFETCHER
if /i "%adv_choice%"=="4" goto ACTION_MINIDUMP
if /i "%adv_choice%"=="0" goto MENU
goto ADVANCED_TWEAKS_MENU

:ACTION_ADAPTIVESYNC
cls
call :LOG "Applying tweak: Enable AdaptiveSync"
call :_Print "yellow" "[WARNING]" "This will enable AdaptiveSync for DirectX."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto ADVANCED_TWEAKS_MENU
reg export "HKLM\SOFTWARE\Microsoft\DirectX" "%~dp0Undo\AdaptiveSync.reg" /y
call :progress "Enabling AdaptiveSync"
reg add "HKLM\SOFTWARE\Microsoft\DirectX" /v EnableAdaptiveSync /t REG_DWORD /d 1 /f
if %errorlevel% neq 0 call :_Print "red" "[ERROR]" "Failed to enable AdaptiveSync."
echo.
call :_Print "green" "[STATUS]" "Tweak applied."
pause
goto ADVANCED_TWEAKS_MENU

:ACTION_LARGESYSTEMCACHE
cls
call :LOG "Applying tweak: Enable Large System Cache"
call :_Print "yellow" "[WARNING]" "This will enable the Large System Cache."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto ADVANCED_TWEAKS_MENU
reg export "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "%~dp0Undo\LargeSystemCache.reg" /y
call :progress "Enabling Large System Cache"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f
if %errorlevel% neq 0 call :_Print "red" "[ERROR]" "Failed to enable LargeSystemCache."
echo.
call :_Print "green" "[STATUS]" "Tweak applied."
pause
goto ADVANCED_TWEAKS_MENU

:ACTION_PREFETCHER
cls
call :LOG "Applying tweak: Disable Prefetcher and Superfetch"
call :_Print "yellow" "[WARNING]" "This will disable the Prefetcher and Superfetch services. Recommended for SSDs."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto ADVANCED_TWEAKS_MENU
reg export "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "%~dp0Undo\Prefetcher.reg" /y
call :progress "Disabling Prefetcher/Superfetch"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f
if %errorlevel% neq 0 call :_Print "red" "[ERROR]" "Failed to disable Prefetcher."
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f
if %errorlevel% neq 0 call :_Print "red" "[ERROR]" "Failed to disable Superfetch."
echo.
call :_Print "green" "[STATUS]" "Tweak applied."
pause
goto ADVANCED_TWEAKS_MENU

:ACTION_MINIDUMP
cls
call :LOG "Applying tweak: Clear Crash Dumps"
call :_Print "yellow" "[WARNING]" "This will delete all crash dump files (*.dmp) in the Minidump folder."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto ADVANCED_TWEAKS_MENU
call :progress "Clearing Crash Dumps"
del /q /f /s "%SystemDrive%\Windows\Minidump\*"
if %errorlevel% neq 0 call :_Print "red" "[ERROR]" "Failed to delete minidump files."
echo.
call :_Print "green" "[STATUS]" "Tweak applied."
pause
goto ADVANCED_TWEAKS_MENU

:ACTION_RSTNET
cls
call :LOG "Selected option: 10 - Reset Network Adapter"
call :_Print "yellow" "[WARNING]" "This will reset your network adapter."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto MENU
call :progress "Network Reset"
call :SILENT_RSTNET
echo.
call :_Print "green" "[STATUS]" "Network reset done."
pause
goto MENU

:ACTION_INPUT
cls
call :LOG "Selected option: 11 - Input Latency Tweaks"
call :progress "Input Latency"
echo [1] Apply lowest latency
if exist "%~dp0Undo\InputLatency_Mouse.reg" echo [2] Restore defaults
set /p inlat="Choose 1/2 [Enter]-menu: "
if "%inlat%"=="1" (
    call :_Print "yellow" "[WARNING]" "This will modify mouse and keyboard settings and back up current values."
    set /p confirm="Are you sure you want to continue? (Y/N): "
    if /i not "%confirm%"=="Y" goto MENU

    call :_Print "cyan" "[INFO]" "Backing up current input settings..."
    reg export "HKCU\Control Panel\Mouse" "%~dp0Undo\InputLatency_Mouse.reg" /y
    reg export "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "%~dp0Undo\InputLatency_Mouclass.reg" /y
    reg export "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "%~dp0Undo\InputLatency_Kbdclass.reg" /y

    call :_Print "cyan" "[INFO]" "Applying new tweaks..."
    reg add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d 10 /f
    if %errorlevel% neq 0 call :_Print "red" "[ERROR]" "Failed to set MouseSensitivity."
    reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
    if %errorlevel% neq 0 call :_Print "red" "[ERROR]" "Failed to set MouseSpeed."
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
    if %errorlevel% neq 0 call :_Print "red" "[ERROR]" "Failed to set MouseThreshold1."
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f
    if %errorlevel% neq 0 call :_Print "red" "[ERROR]" "Failed to set MouseThreshold2."
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v MouseDataQueueSize /t REG_DWORD /d 20 /f
    if %errorlevel% neq 0 call :_Print "red" "[ERROR]" "Failed to set MouseDataQueueSize."
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v KeyboardDataQueueSize /t REG_DWORD /d 20 /f
    if %errorlevel% neq 0 call :_Print "red" "[ERROR]" "Failed to set KeyboardDataQueueSize."
    echo.
    call :_Print "green" "[STATUS]" "Input latency tweaks applied. Restart!"
    pause
    goto MENU
)
if "%inlat%"=="2" (
    if not exist "%~dp0Undo\InputLatency_Mouse.reg" goto MENU
    call :_Print "yellow" "[WARNING]" "This will restore your original mouse and keyboard settings."
    set /p confirm="Are you sure you want to continue? (Y/N): "
    if /i not "%confirm%"=="Y" goto MENU

    call :_Print "cyan" "[INFO]" "Restoring original settings..."
    reg import "%~dp0Undo\InputLatency_Mouse.reg"
    reg import "%~dp0Undo\InputLatency_Mouclass.reg"
    reg import "%~dp0Undo\InputLatency_Kbdclass.reg"

    call :_Print "cyan" "[INFO]" "Cleaning up backup files..."
    del "%~dp0Undo\InputLatency_Mouse.reg"
    del "%~dp0Undo\InputLatency_Mouclass.reg"
    del "%~dp0Undo\InputLatency_Kbdclass.reg"

    echo.
    call :_Print "green" "[STATUS]" "Input latency values restored."
    pause
    goto MENU
)
goto MENU

:BACKUP_RESTORE
cls
call :LOG "Selected option: 12 - Backup and Restore"
echo.
echo            %COLOR_CYAN%+-+------------------------------------------+-+%COLOR_RESET%
echo            %COLOR_CYAN%| |             BACKUP AND RESTORE             | |%COLOR_RESET%
echo            %COLOR_CYAN%+-+------------------------------------------+-+%COLOR_RESET%
echo.
echo    [1] Create System Restore Point
echo    [2] Backup Registry
if exist "%~dp0RegistryBackup_HKCU.reg" (
    echo    [3] Restore Registry
)
echo    [0] Back to Main Menu
echo.
set /p br_choice="          Select an option: "
if /i "%br_choice%"=="1" goto CREATE_RESTORE_POINT
if /i "%br_choice%"=="2" goto BACKUP_REGISTRY
if /i "%br_choice%"=="3" (
    if exist "%~dp0RegistryBackup_HKCU.reg" goto RESTORE_REGISTRY
)
if /i "%br_choice%"=="0" goto MENU
goto BACKUP_RESTORE

:CREATE_RESTORE_POINT
cls
call :progress "Creating System Restore Point"
powershell.exe -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description 'Optimizer Restore Point' -RestorePointType 'MODIFY_SETTINGS'"
echo.
call :_Print "green" "[STATUS]" "System restore point created successfully."
pause
goto BACKUP_RESTORE

:BACKUP_REGISTRY
cls
call :progress "Backing up Registry"
reg export HKCU "%~dp0RegistryBackup_HKCU.reg" /y
reg export HKLM "%~dp0RegistryBackup_HKLM.reg" /y
echo.
call :_Print "green" "[STATUS]" "Registry backup created successfully."
pause
goto BACKUP_RESTORE

:RESTORE_REGISTRY
cls
call :progress "Restoring Registry"
reg import "%~dp0RegistryBackup_HKCU.reg"
reg import "%~dp0RegistryBackup_HKLM.reg"
echo.
call :_Print "green" "[STATUS]" "Registry restored successfully. Restart recommended!"
pause
goto BACKUP_RESTORE

:HELP
cls
call :LOG "Selected option: 13 - Help / Information"
echo.
echo            %COLOR_CYAN%+-+------------------------------------------+-+%COLOR_RESET%
echo            %COLOR_CYAN%| |              HELP / INFORMATION            | |%COLOR_RESET%
echo            %COLOR_CYAN%+-+------------------------------------------+-+%COLOR_RESET%
echo.
echo    %COLOR_CYAN%[1] Optimize Network:%COLOR_RESET%
echo        - Sets TCP autotuning to normal, enables chimney offload, and uses CTCP congestion provider.
echo        - Disables heuristics, enables RSS, and fast open.
echo.
echo    %COLOR_CYAN%[2] System Cleaner:%COLOR_RESET%
echo        - Deletes files from TEMP, C:\Windows\Temp, and Prefetch folders.
echo        - Runs the built-in Disk Cleanup utility.
echo        - Clears the Windows Update cache.
echo.
echo    %COLOR_CYAN%[3] Extended Cleaner:%COLOR_RESET%
echo        - Deletes cache files from Chrome, Edge, and Opera.
echo        - Deletes Explorer's thumbnail cache.
echo.
echo    %COLOR_CYAN%[4] Junk Finder:%COLOR_RESET%
echo        - Deletes .log, .dmp, .bak, .old, and .tmp files from the system drive and user's Downloads folder.
echo.
echo    %COLOR_CYAN%[5] Windows Debloater:%COLOR_RESET%
echo        - Provides options to remove pre-installed Microsoft Store applications, either from a recommended
echo          list or by custom selection.
echo.
echo    %COLOR_CYAN%[6] Optimize DNS:%COLOR_RESET%
echo        - Sets the DNS to Cloudflare's 1.1.1.1 and 1.0.0.1 for all active network adapters.
echo        - Flushes the DNS cache.
echo.
echo    %COLOR_CYAN%[7] Manage Services:%COLOR_RESET%
echo        - Disables SysMain, DiagTrack, dmwappushservice, and Xbox services.
echo        - Disables telemetry through the registry.
echo.
echo    %COLOR_CYAN%[8] Game Mode + GPU Priority:%COLOR_RESET%
echo        - Enables Game Mode, boosts GPU and CPU priority for games.
echo        - Disables background apps and sets the power plan to "High performance".
echo.
echo    %COLOR_CYAN%[9] Advanced Windows Tweaks:%COLOR_RESET%
echo        - Enables AdaptiveSync for DirectX, enables LargeSystemCache.
echo        - Disables prefetcher and superfetch.
echo        - Clears minidump files.
echo.
echo    %COLOR_CYAN%[10] Reset Network Adapter:%COLOR_RESET%
echo         - Releases and renews the IP address, flushes DNS, and resets Winsock and IP.
echo.
echo    %COLOR_CYAN%[11] Input Latency Tweaks:%COLOR_RESET%
echo          - Adjusts mouse and keyboard settings to reduce input latency.
echo.
echo    %COLOR_CYAN%[12] Backup and Restore:%COLOR_RESET%
echo          - Creates a system restore point and backs up the registry.
echo.
pause
goto MENU

:UNDO_TWEAKS
cls
call :LOG "Selected option: 14 - Undo Tweaks"
:UNDO_TWEAKS_MENU
cls
echo.
echo            %COLOR_CYAN%+-+------------------------------------------+-+%COLOR_RESET%
echo            %COLOR_CYAN%| |                   UNDO TWEAKS              | |%COLOR_RESET%
echo            %COLOR_CYAN%+-+------------------------------------------+-+%COLOR_RESET%
echo.
if exist "%~dp0Undo\AdaptiveSync.reg" echo    [1] Undo AdaptiveSync
if exist "%~dp0Undo\LargeSystemCache.reg" echo    [2] Undo Large System Cache
if exist "%~dp0Undo\Prefetcher.reg" echo    [3] Undo Prefetcher and Superfetch
if exist "%~dp0Undo\GameMode_PowerSettings.reg" echo    [4] Undo Game Mode Tweaks
if exist "%~dp0Undo\Services_SysMain.bat" echo    [5] Undo Service Changes
echo    [0] Back to Main Menu
echo.
set /p undo_choice="          Select a tweak to undo: "
if /i "%undo_choice%"=="1" goto UNDO_ADAPTIVESYNC
if /i "%undo_choice%"=="2" goto UNDO_LARGESYSTEMCACHE
if /i "%undo_choice%"=="3" goto UNDO_PREFETCHER
if /i "%undo_choice%"=="4" goto UNDO_GAMEMODE
if /i "%undo_choice%"=="5" goto UNDO_SERVICES
if /i "%undo_choice%"=="0" goto MENU
goto UNDO_TWEAKS_MENU

:UNDO_GAMEMODE
cls
call :LOG "Undoing tweak: Game Mode"
call :_Print "yellow" "[WARNING]" "This will restore the default Game Mode settings."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto UNDO_TWEAKS_MENU
call :progress "Restoring Game Mode Settings"
reg import "%~dp0Undo\GameMode_PowerSettings.reg"
reg import "%~dp0Undo\GameMode_Multimedia.reg"
reg import "%~dp0Undo\GameMode_BackgroundApps.reg"
del "%~dp0Undo\GameMode_PowerSettings.reg"
del "%~dp0Undo\GameMode_Multimedia.reg"
del "%~dp0Undo\GameMode_BackgroundApps.reg"
echo.
call :_Print "green" "[STATUS]" "Tweak undone."
pause
goto UNDO_TWEAKS_MENU

:UNDO_SERVICES
cls
call :LOG "Undoing tweak: Service Changes"
call :_Print "yellow" "[WARNING]" "This will restore the original service configurations."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto UNDO_TWEAKS_MENU
call :progress "Restoring Services"
set "service_list=SysMain DiagTrack dmwappushservice XblAuthManager XblGameSave XboxNetApiSvc"
for %%s in (%service_list%) do (
    if exist "%~dp0Undo\Services_%%s.bat" (
        call "%~dp0Undo\Services_%%s.bat"
        del "%~dp0Undo\Services_%%s.bat"
    )
)
reg import "%~dp0Undo\Services_Telemetry.reg"
del "%~dp0Undo\Services_Telemetry.reg"
echo.
call :_Print "green" "[STATUS]" "Services restored."
pause
goto UNDO_TWEAKS_MENU

:UNDO_ADAPTIVESYNC
cls
call :LOG "Undoing tweak: AdaptiveSync"
call :_Print "yellow" "[WARNING]" "This will restore the default AdaptiveSync setting."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto UNDO_TWEAKS_MENU
call :progress "Restoring AdaptiveSync"
reg import "%~dp0Undo\AdaptiveSync.reg"
if %errorlevel% neq 0 call :_Print "red" "[ERROR]" "Failed to restore AdaptiveSync."
del "%~dp0Undo\AdaptiveSync.reg"
echo.
call :_Print "green" "[STATUS]" "Tweak undone."
pause
goto UNDO_TWEAKS_MENU

:UNDO_LARGESYSTEMCACHE
cls
call :LOG "Undoing tweak: Large System Cache"
call :_Print "yellow" "[WARNING]" "This will restore the default Large System Cache setting."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto UNDO_TWEAKS_MENU
call :progress "Restoring Large System Cache"
reg import "%~dp0Undo\LargeSystemCache.reg"
if %errorlevel% neq 0 call :_Print "red" "[ERROR]" "Failed to restore Large System Cache."
del "%~dp0Undo\LargeSystemCache.reg"
echo.
call :_Print "green" "[STATUS]" "Tweak undone."
pause
goto UNDO_TWEAKS_MENU

:UNDO_PREFETCHER
cls
call :LOG "Undoing tweak: Prefetcher and Superfetch"
call :_Print "yellow" "[WARNING]" "This will restore the default Prefetcher and Superfetch settings."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto UNDO_TWEAKS_MENU
call :progress "Restoring Prefetcher/Superfetch"
reg import "%~dp0Undo\Prefetcher.reg"
if %errorlevel% neq 0 call :_Print "red" "[ERROR]" "Failed to restore Prefetcher."
del "%~dp0Undo\Prefetcher.reg"
echo.
call :_Print "green" "[STATUS]" "Tweak undone."
pause
goto UNDO_TWEAKS_MENU

:ACTION_SYSINFO
cls
call :LOG "Selected option: 15 - System Information"
call :SILENT_SYSINFO
echo.
pause
goto MENU

:EXIT
cls
echo.
call :_Print "cyan" "[ EXIT ]" "Thank you for using the optimizer!"
echo      If you tweaked settings, please restart your computer.
echo.
pause
exit

:: #############################################################################
::  SILENT MODE ACTIONS
:: #############################################################################

:SILENT_NET
call :LOG "Silent operation: Optimize Network"
netsh int tcp set global autotuninglevel=normal
netsh int tcp set global chimney=enabled
netsh int tcp set global congestionprovider=ctcp
netsh int tcp set heuristics disabled
netsh int tcp set global rss=enabled
netsh int tcp set global fastopen=enabled
netsh interface tcp set global timestamps=disabled
goto :EOF

:SILENT_CLEAN
call :LOG "Silent operation: System Cleaner"
del /q /f /s %TEMP%\*
del /q /f /s C:\Windows\Temp\*
del /q /f /s C:\Windows\Prefetch\*
cleanmgr /sagerun:1
net stop wuauserv 2>nul
del /q /f /s C:\Windows\SoftwareDistribution\Download\*
net start wuauserv 2>nul
goto :EOF

:SILENT_CLEANX
call :LOG "Silent operation: Extended Cleaner"
del /q /f /s "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*"
del /q /f /s "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*"
del /q /f /s "%APPDATA%\Opera Software\Opera Stable\Cache\*"
del /q /f /s "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db"
goto :EOF

:SILENT_JUNK
call :LOG "Silent operation: Junk Finder"
del /q /f /s "%SYSTEMDRIVE%\*.log"
del /q /f /s "%SYSTEMDRIVE%\*.dmp"
del /q /f /s "%SYSTEMDRIVE%\*.bak"
del /q /f /s "%SYSTEMDRIVE%\*.old"
del /q /f /s "%USERPROFILE%\Downloads\*.tmp"
goto :EOF

:SILENT_DNS
call :LOG "Silent operation: Optimize DNS"
for /f "tokens=3,*" %%a in ('netsh interface show interface ^| find "Connected"') do (
    call :_Print "cyan" "[INFO]" "Setting DNS for interface: %%b"
    netsh interface ip set dns name="%%b" static 1.1.1.1 primary
    netsh interface ip add dns name="%%b" 1.0.0.1 index=2
)
ipconfig /flushdns
goto :EOF

:SILENT_GAMEMODE
call :LOG "Silent operation: Game Mode + GPU Priority"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\Settings" /v GameMode /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
goto :EOF

:SILENT_RSTNET
call :LOG "Silent operation: Reset Network Adapter"
ipconfig /release
ipconfig /renew
ipconfig /flushdns
netsh winsock reset
netsh int ip reset
netsh interface ipv4 reset
netsh interface ipv6 reset
goto :EOF

:SILENT_SYSINFO
call :LOG "Silent operation: System Information"
echo.
echo            %COLOR_CYAN%+-+------------------------------------------+-+%COLOR_RESET%
echo            %COLOR_CYAN%| |              SYSTEM INFORMATION            | |%COLOR_RESET%
echo            %COLOR_CYAN%+-+------------------------------------------+-+%COLOR_RESET%
echo.
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Manufacturer" /C:"System Model" /C:"System Type" /C:"Total Physical Memory" /C:"Processor(s)"
goto :EOF

:SILENT_HELP
echo.
echo Usage: %0 [argument]
echo.
echo Arguments:
echo   /clean      - System Cleaner
echo   /cleanx     - Extended Cleaner
echo   /junk       - Junk Finder
echo   /dns        - Optimize DNS
echo   /gamemode   - Game Mode + GPU Priority
echo   /rstnet     - Reset Network Adapter
echo   /sysinfo    - System Information
echo   /? or /help - Display this help message
echo.
goto :EOF

:: -------- Logging Function
:LOG
set "log_message=%~1"
echo [%date% %time%] %log_message% >> "%~dp0Optimizer.log"
goto :EOF
