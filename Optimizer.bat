@echo off
setlocal EnableDelayedExpansion

:: ---------------------------
:: Optimizer.bat - Light optimized (non-breaking)
:: Keep features, fix bugs, improve safety and consistency.
:: ---------------------------

:: Relaunch in persistent console if not already _RUN
if /i "%~1" NEQ "_RUN" (
    rem pass all args through when relaunching
    start "" cmd /k "%~f0" _RUN %*
    exit /b 0
)

:: Ensure UTF-8 console
chcp 65001 >nul

:: Constants
set "LOGFILE=%~n0.log"
set "UNDO=%~dp0Undo"

if not exist "%UNDO%" mkdir "%UNDO%" 2>nul

:: Admin check
net session >nul 2>&1
if errorlevel 1 (
    echo [FATAL] This script requires administrator privileges.
    echo Right-click the script and select "Run as administrator".
    pause
    exit /b 1
)

call :LOG "Script started"

:: ---------------------------
:: Helper functions (small, safe)
:: ---------------------------

:_Print
:: Usage: call :_Print "color" "[TAG]" "Message"
:: Color argument is ignored in plain batch — kept for compatibility
set "tag=%~2"
set "msg=%~3"
if defined tag (
    echo %tag% %msg%
) else (
    echo %msg%
)
goto :EOF

:progress
:: Usage: call :progress "Title"
set "pmsg=%~1"
echo.
echo %pmsg%...
rem tiny visual delay alternative (non-blocking)
for /l %%i in (1,1,2) do ( <nul set /p "=." & ping -n 1 127.0.0.1 >nul )
echo.
goto :EOF

:confirm
:: Usage: call :confirm "Question" && (use errorlevel 0 = yes, 1 = no)
set "q=%~1"
set /p yn="%q% (Y/N): "
if /i "%yn%"=="Y" (exit /b 0) else (exit /b 1)

:: ---------------------------
:: PowerShell script creation (atomic)
:: ---------------------------

set "PS_DEBLOAT=%TEMP%\Debloater_temp.ps1"
set "PS_DNS=%TEMP%\DNS_temp.ps1"

rem Debloater - compact
(
    echo # Debloater - Compact Edition
    echo param^($UndoPath^)
    echo $ErrorActionPreference='Stop'
    echo $apps=@('Microsoft.549981C3F5F10','Microsoft.BingNews','Microsoft.GetHelp','Microsoft.People','Microsoft.SkypeApp','Microsoft.WindowsAlarms','Microsoft.WindowsFeedbackHub','Microsoft.YourPhone','Microsoft.ZuneMusic','king.com.CandyCrushSaga')
    echo $removed=0
    echo foreach^($app in $apps^){$pkg=Get-AppxPackage *$app* -ErrorAction SilentlyContinue;if^($pkg^){Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction SilentlyContinue;Write-Host "[OK] Removed: $app";$removed++}else{Write-Host "[SKIP] Not found: $app"}}
    echo Write-Host "[DONE] Removed $removed apps" -ForegroundColor Green
) > "%PS_DEBLOAT%"

rem DNS script - compact
(
    echo # DNS Optimizer - Compact Edition
    echo param^($UndoPath^)
    echo $ErrorActionPreference='Stop'
    echo $adapters=Get-NetAdapter -Physical ^| Where-Object{$_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*'}
    echo foreach^($adapter in $adapters^){Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses @('1.1.1.1','1.0.0.1');Write-Host "[OK] DNS: $($adapter.Name)"}
    echo Clear-DnsClientCache;Write-Host "[OK] Cache flushed"
) > "%PS_DNS%"

if exist "%PS_DEBLOAT%" move /y "%PS_DEBLOAT%" "%UNDO%\Debloater.ps1" >nul 2>&1
if exist "%PS_DNS%" move /y "%PS_DNS%" "%UNDO%\DNS.ps1" >nul 2>&1

:: ---------------------------
:: Argument parser (ignores internal _RUN)
:: ---------------------------

if /i "%~1"=="_RUN" (
    shift
)

if /i "%~1" equ "/clean" goto SILENT_CLEAN
if /i "%~1" equ "/cleanx" goto SILENT_CLEANX
if /i "%~1" equ "/junk" goto SILENT_JUNK
if /i "%~1" equ "/dns" goto SILENT_DNS
if /i "%~1" equ "/gamemode" goto SILENT_GAMEMODE
if /i "%~1" equ "/rstnet" goto SILENT_RSTNET
if /i "%~1" equ "/sysinfo" goto SILENT_SYSINFO
if /i "%~1" equ "/?" goto SILENT_HELP
if /i "%~1" equ "/help" goto SILENT_HELP

if not "%~1"=="" (
    call :_Print "red" "[ERROR]" "Invalid argument: %1"
    goto SILENT_HELP
)

:: ---------------------------
:: MAIN MENU
:: ---------------------------

:MENU
cls
echo.
echo ╔════════════════════════════════════════════╗
echo ║ Lynx Optimizer v6.1 (Memory Efficient) ║
echo ║ Log: %LOGFILE% ║
echo ╚════════════════════════════════════════════╝
echo.
echo [1] Network Optimization
echo [2] System Cleaner
echo [3] Extended Cleaner
echo [4] Junk Finder
echo [5] Debloater (PS)
echo [6] DNS Optimizer (PS)
echo [7] Service Manager
echo [8] Game Mode
echo [9] Advanced Tweaks
echo [10] Reset Network
echo [11] Input Latency
echo [12] Backup/Restore
echo [13] Help
echo [14] Undo Tweaks
echo [15] System Info
echo [0] Exit
echo.
set /p choice="Select 0-15: "

if "%choice%"=="1" goto NET
if "%choice%"=="2" goto CLEAN
if "%choice%"=="3" goto CLEANX
if "%choice%"=="4" goto JUNK
if "%choice%"=="5" goto ACTION_DEBLOAT
if "%choice%"=="6" (
    if exist "%UNDO%\DNS.ps1" (
        powershell -ExecutionPolicy Bypass -File "%UNDO%\DNS.ps1"
        if errorlevel 1 echo [ERROR] DNS script failed.
    ) else (
        echo [ERROR] DNS script not found in "%UNDO%".
    )
    pause
    goto MENU
)
if "%choice%"=="7" goto SERV
if "%choice%"=="8" goto GAMEMODE
if "%choice%"=="9" goto ADVANCED
if "%choice%"=="10" goto RSTNET
if "%choice%"=="11" goto INPUT
if "%choice%"=="12" goto BACKUP
if "%choice%"=="13" goto HELP
if "%choice%"=="14" goto UNDO
if "%choice%"=="15" goto SYSINFO
if "%choice%"=="0" exit /b 0
goto MENU

:: ---------------------------
:: NETWORK
:: ---------------------------

:NET
cls
echo [INFO] Network optimization...
netsh int tcp set global autotuninglevel=normal >nul 2>&1
if errorlevel 1 echo [ERROR] Failed to set autotuninglevel.
netsh int tcp set global congestionprovider=ctcp >nul 2>&1
if errorlevel 1 echo [ERROR] Failed to set congestionprovider.
netsh int tcp set global fastopen=enabled >nul 2>&1
if errorlevel 1 echo [ERROR] Failed to set fastopen.
echo [OK] Complete!
pause
goto MENU

:: ---------------------------
:: CLEAN (System Cleaner)
:: ---------------------------

:CLEAN
cls
call :LOG "Selected option: 2 - System Cleaner"
call :_Print "yellow" "[WARNING]" "This will delete temporary files."
call :confirm "Are you sure you want to continue?"
if errorlevel 1 goto MENU
call :progress "System Clean"
if exist "%TEMP%\*" (
    del /q /f /s "%TEMP%\*" >nul 2>&1
)
if exist "%WINDIR%\Temp\*" (
    del /q /f /s "%WINDIR%\Temp\*" >nul 2>&1
)
if exist "%WINDIR%\Prefetch\*" (
    del /q /f /s "%WINDIR%\Prefetch\*" >nul 2>&1
)
net stop wuauserv >nul 2>&1
if exist "%WINDIR%\SoftwareDistribution\Download\*" (
    del /q /f /s "%WINDIR%\SoftwareDistribution\Download\*" >nul 2>&1
)
net start wuauserv >nul 2>&1
echo.
call :_Print "green" "[STATUS]" "Junk cleaned."
pause
goto MENU

:: ---------------------------
:: CLEANX (Extended Cleaner)
:: ---------------------------

:CLEANX
cls
call :LOG "Selected option: 3 - Extended Cleaner"
call :_Print "yellow" "[WARNING]" "This will delete browser and Explorer cache files."
call :confirm "Are you sure you want to continue?"
if errorlevel 1 goto MENU
call :progress "Extended Cleaner"
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*" del /q /f /s "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*" del /q /f /s "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*" >nul 2>&1
if exist "%APPDATA%\Opera Software\Opera Stable\Cache\*" del /q /f /s "%APPDATA%\Opera Software\Opera Stable\Cache\*" >nul 2>&1
if exist "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" del /q /f /s "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
echo.
call :_Print "green" "[STATUS]" "Browser/Explorer cache cleaned."
pause
goto MENU

:: ---------------------------
:: JUNK
:: ---------------------------

:JUNK
cls
call :LOG "Selected option: 4 - Junk Finder"
call :_Print "red" "[CRITICAL]" "This is an aggressive cleanup and may delete important files if you have custom software that uses .log, .bak, or .old extensions."
call :_Print "yellow" "[WARNING]" "It is recommended to back up important data before proceeding."
call :confirm "Are you sure you want to continue?"
if errorlevel 1 goto MENU
call :progress "Junk Finder"
if exist "%TEMP%\*.log" del /q /f /s "%TEMP%\*.log" >nul 2>&1
if exist "%TEMP%\*.tmp" del /q /f /s "%TEMP%\*.tmp" >nul 2>&1
if exist "%WINDIR%\Temp\*.log" del /q /f /s "%WINDIR%\Temp\*.log" >nul 2>&1
if exist "%WINDIR%\Temp\*.tmp" del /q /f /s "%WINDIR%\Temp\*.tmp" >nul 2>&1
if exist "%USERPROFILE%\Downloads\*.tmp" del /q /f "%USERPROFILE%\Downloads\*.tmp" >nul 2>&1
echo.
call :_Print "green" "[STATUS]" "Deep junk removed."
pause
goto MENU

:: ---------------------------
:: DEBLOATER menu and actions
:: ---------------------------

:ACTION_DEBLOAT
cls
call :LOG "Selected option: 5 - Windows Debloater"
:DEBLOAT_MENU
cls
echo.
echo ===========================================
echo Windows Debloater
echo ===========================================
echo.
echo [1] Recommended Debloat (Removes common bloatware)
echo [2] Custom Debloat (Choose which apps to remove)
echo [0] Back to Main Menu
echo.
set /p debloat_choice="Select an option: "
if /i "%debloat_choice%"=="1" goto DEBLOAT_RECOMMENDED
if /i "%debloat_choice%"=="2" goto DEBLOAT_CUSTOM
if /i "%debloat_choice%"=="0" goto MENU
goto DEBLOAT_MENU

:DEBLOAT_RECOMMENDED
cls
call :LOG "Selected Debloater option: Recommended"
call :_Print "yellow" "[WARNING]" "This will remove a list of common bloatware apps."
call :confirm "Are you sure you want to continue?"
if errorlevel 1 goto DEBLOAT_MENU
if exist "%UNDO%\Debloater.ps1" (
    powershell -ExecutionPolicy Bypass -File "%UNDO%\Debloater.ps1"
    if errorlevel 1 echo [ERROR] Debloater script failed.
) else (
    echo [ERROR] Debloater script not found in "%UNDO%".
)
pause
goto DEBLOAT_MENU

:DEBLOAT_CUSTOM
cls
call :LOG "Selected Debloater option: Custom"
call :_Print "yellow" "[WARNING]" "This will allow you to select and remove specific Microsoft Store apps."
call :confirm "Are you sure you want to continue?"
if errorlevel 1 goto DEBLOAT_MENU

:DEBLOAT_CUSTOM_LOOP
cls
echo [INFO] Loading list of installed apps...
powershell.exe -ExecutionPolicy Bypass -Command "Get-AppxPackage | Select-Object -Property Name, PackageFullName | Format-Table -AutoSize"
echo.
set /p app_name="Enter the full or partial name of the app to remove (or type 'exit' to return): "
if /i "%app_name%"=="exit" goto DEBLOAT_MENU
if "%app_name%"=="" goto DEBLOAT_CUSTOM_LOOP

powershell.exe -ExecutionPolicy Bypass -Command "Get-AppxPackage *%app_name%* | Remove-AppxPackage" >nul 2>&1
if errorlevel 1 echo [ERROR] Failed to remove app or none matched.
call :LOG "Attempted to remove AppX Package: %app_name%"
echo.
echo [INFO] Operation complete. You can remove another or type 'exit'.
pause
goto DEBLOAT_CUSTOM_LOOP

:: ---------------------------
:: SERVICE manager
:: ---------------------------

:SERV
cls
echo.
echo ===========================================
echo Service Management
echo ===========================================
echo.
if exist "%UNDO%\Services_Backup_SysMain.reg" (
    echo [1] Disable Services
    echo [2] Restore Services
) else (
    echo [1] Disable Services
)
echo [0] Back
echo.
set /p svch="Select: "

if "%svch%"=="1" (
    cls
    call :_Print "yellow" "[WARNING]" "Disabling services..."
    call :confirm "Continue?"
    if errorlevel 1 goto MENU
    set "list=SysMain DiagTrack dmwappushservice XblAuthManager XblGameSave XboxNetApiSvc"
    for %%s in (%list%) do (
        echo [INFO] Disabling %%s...
        reg export "HKLM\SYSTEM\CurrentControlSet\Services\%%s" "%UNDO%\Services_Backup_%%s.reg" /y >nul 2>&1
        sc config "%%s" start=disabled >nul 2>&1
        if errorlevel 1 echo [ERROR] Failed to disable %%s.
        sc stop "%%s" >nul 2>&1
    )
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
    if errorlevel 1 echo [ERROR] Failed to disable telemetry.
    echo [OK] Disabled! Restart required.
    pause
    goto MENU
)

if "%svch%"=="2" (
    cls
    call :_Print "yellow" "[WARNING]" "Restoring services..."
    call :confirm "Continue?"
    if errorlevel 1 goto MENU
    set "list=SysMain DiagTrack dmwappushservice XblAuthManager XblGameSave XboxNetApiSvc"
    for %%s in (%list%) do (
        if exist "%UNDO%\Services_Backup_%%s.reg" (
            echo [INFO] Restoring %%s...
            reg import "%UNDO%\Services_Backup_%%s.reg" >nul 2>&1
            del "%UNDO%\Services_Backup_%%s.reg" 2>nul
        )
    )
    echo [OK] Restored! Restart required.
    pause
    goto MENU
)

goto MENU

:: ---------------------------
:: GAMEMODE
:: ---------------------------

:GAMEMODE
cls
call :_Print "yellow" "[WARNING]" "Applying Game Mode..."
call :confirm "Continue?"
if errorlevel 1 goto MENU

reg export "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\Settings" "%UNDO%\GameMode_PowerSettings.reg" /y >nul 2>&1
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "%UNDO%\GameMode_Multimedia.reg" /y >nul 2>&1
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "%UNDO%\GameMode_BackgroundApps.reg" /y >nul 2>&1

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\Settings" /v GameMode /t REG_DWORD /d 1 /f >nul 2>&1
if errorlevel 1 echo [ERROR] Failed to enable GameMode.

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f >nul 2>&1

powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
if errorlevel 1 (
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
    if errorlevel 1 echo [ERROR] Failed to set power scheme.
)

echo [OK] Applied! Restart required.
pause
goto MENU

:: ---------------------------
:: ADVANCED tweaks
:: ---------------------------

:ADVANCED
cls
echo.
echo ===========================================
echo Advanced Tweaks
echo ===========================================
echo.
echo [1] AdaptiveSync (DirectX)
echo [2] Large System Cache
echo [3] Disable Prefetcher
echo [4] Clear Crash Dumps
echo [0] Back
echo.
set /p adv="Select: "

if "%adv%"=="1" (
    cls
    call :_Print "yellow" "[WARNING]" "AdaptiveSync requires GPU..."
    call :confirm "Continue?"
    if errorlevel 1 goto MENU
    reg export "HKLM\SOFTWARE\Microsoft\DirectX" "%UNDO%\AdaptiveSync.reg" /y >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\DirectX" /v EnableAdaptiveSync /t REG_DWORD /d 1 /f >nul 2>&1
    echo [OK] Enabled!
    pause
    goto MENU
)

if "%adv%"=="2" (
    cls
    call :_Print "yellow" "[WARNING]" "Large System Cache for 16GB+ RAM..."
    call :confirm "Continue?"
    if errorlevel 1 goto MENU
    reg export "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "%UNDO%\LargeSystemCache.reg" /y >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f >nul 2>&1
    echo [OK] Enabled!
    pause
    goto MENU
)

if "%adv%"=="3" (
    cls
    call :_Print "yellow" "[WARNING]" "Only for SSDs! May slow HDDs..."
    call :confirm "Continue?"
    if errorlevel 1 goto MENU
    reg export "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "%UNDO%\Prefetcher.reg" /y >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f >nul 2>&1
    echo [OK] Disabled!
    pause
    goto MENU
)

if "%adv%"=="4" (
    cls
    call :_Print "yellow" "[WARNING]" "Clearing crash dumps..."
    call :confirm "Continue?"
    if errorlevel 1 goto MENU
    if not exist "%WINDIR%\Minidump" mkdir "%WINDIR%\Minidump" 2>nul
    del /q /f "%WINDIR%\Minidump\*.dmp" >nul 2>&1
    echo [OK] Cleared!
    pause
    goto MENU
)

goto MENU

:: ---------------------------
:: Reset Network
:: ---------------------------

:RSTNET
cls
call :_Print "yellow" "[WARNING]" "Resetting network stack..."
call :confirm "Continue?"
if errorlevel 1 goto MENU

ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
echo [OK] Reset complete! Restart required.
pause
goto MENU

:: ---------------------------
:: INPUT LATENCY
:: ---------------------------

:INPUT
cls
echo.
echo ===========================================
echo Input Latency Tweaks
echo ===========================================
echo.
if exist "%UNDO%\InputLatency_Mouse.reg" (
    echo [1] Apply Lowest Latency
    echo [2] Restore Defaults
) else (
    echo [1] Apply Lowest Latency
)
echo [0] Back
echo.
set /p inlat="Select: "

if "%inlat%"=="1" (
    cls
    call :_Print "yellow" "[WARNING]" "Applying tweaks..."
    call :confirm "Continue?"
    if errorlevel 1 goto MENU
    reg export "HKCU\Control Panel\Mouse" "%UNDO%\InputLatency_Mouse.reg" /y >nul 2>&1
    reg export "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "%UNDO%\InputLatency_Mouclass.reg" /y >nul 2>&1
    reg export "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "%UNDO%\InputLatency_Kbdclass.reg" /y >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d 10 /f >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v MouseDataQueueSize /t REG_DWORD /d 20 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v KeyboardDataQueueSize /t REG_DWORD /d 20 /f >nul 2>&1
    echo [OK] Applied! Restart required.
    pause
    goto MENU
)

if "%inlat%"=="2" (
    cls
    call :_Print "yellow" "[WARNING]" "Restoring settings..."
    call :confirm "Continue?"
    if errorlevel 1 goto MENU
    if exist "%UNDO%\InputLatency_Mouse.reg" reg import "%UNDO%\InputLatency_Mouse.reg" >nul 2>&1
    if exist "%UNDO%\InputLatency_Mouclass.reg" reg import "%UNDO%\InputLatency_Mouclass.reg" >nul 2>&1
    if exist "%UNDO%\InputLatency_Kbdclass.reg" reg import "%UNDO%\InputLatency_Kbdclass.reg" >nul 2>&1
    del "%UNDO%\InputLatency_*.reg" 2>nul
    echo [OK] Restored!
    pause
    goto MENU
)

goto MENU

:: ---------------------------
:: BACKUP / RESTORE
:: ---------------------------

:BACKUP
cls
echo.
echo ===========================================
echo Backup and Restore
echo ===========================================
echo.
echo [1] Create Restore Point
echo [2] Backup Registry
if exist "%UNDO%\RegistryBackup_HKCU.reg" echo [3] Restore Registry - CRITICAL WARNING
echo [0] Back
echo.
set /p br="Select: "

if "%br%"=="1" (
    cls
    echo [INFO] Creating restore point...
    powershell -Command "Checkpoint-Computer -Description 'Optimizer' -RestorePointType MODIFY_SETTINGS" 2>nul
    if errorlevel 1 (echo [ERROR] Failed) else (echo [OK] Created!)
    pause
    goto MENU
)

if "%br%"=="2" (
    cls
    echo [INFO] Backing up registry...
    reg export HKCU "%UNDO%\RegistryBackup_HKCU.reg" /y >nul 2>&1
    reg export HKLM "%UNDO%\RegistryBackup_HKLM.reg" /y >nul 2>&1
    echo [OK] Backed up to "%UNDO%"
    pause
    goto MENU
)

if "%br%"=="3" (
    if exist "%UNDO%\RegistryBackup_HKCU.reg" (
        cls
        echo [CRITICAL] FULL REGISTRY RESTORE - LAST WARNING
        set /p confirm="Type YES to confirm: "
        if /i not "%confirm%"=="YES" goto MENU
        echo [INFO] Restoring...
        reg import "%UNDO%\RegistryBackup_HKCU.reg" >nul 2>&1
        reg import "%UNDO%\RegistryBackup_HKLM.reg" >nul 2>&1
        echo [CRITICAL] RESTART IMMEDIATELY!
        pause
        goto MENU
    ) else (
        echo [ERROR] No registry backup found.
        pause
        goto MENU
    )
)

goto MENU

:: ---------------------------
:: UNDO tweaks
:: ---------------------------

:UNDO
cls
echo.
echo ===========================================
echo Undo Tweaks
echo ===========================================
echo.
if exist "%UNDO%\AdaptiveSync.reg" echo [1] AdaptiveSync
if exist "%UNDO%\LargeSystemCache.reg" echo [2] LargeSystemCache
if exist "%UNDO%\Prefetcher.reg" echo [3] Prefetcher
if exist "%UNDO%\GameMode_PowerSettings.reg" echo [4] GameMode
if exist "%UNDO%\Services_Backup_SysMain.reg" echo [5] Services
if exist "%UNDO%\InputLatency_Mouse.reg" echo [6] InputLatency
echo [0] Back
echo.
set /p undo="Select: "

if "%undo%"=="1" (
    if exist "%UNDO%\AdaptiveSync.reg" (reg import "%UNDO%\AdaptiveSync.reg" >nul 2>&1 & del "%UNDO%\AdaptiveSync.reg" 2>nul & echo [OK])
    pause
    goto MENU
)
if "%undo%"=="2" (
    if exist "%UNDO%\LargeSystemCache.reg" (reg import "%UNDO%\LargeSystemCache.reg" >nul 2>&1 & del "%UNDO%\LargeSystemCache.reg" 2>nul & echo [OK])
    pause
    goto MENU
)
if "%undo%"=="3" (
    if exist "%UNDO%\Prefetcher.reg" (reg import "%UNDO%\Prefetcher.reg" >nul 2>&1 & del "%UNDO%\Prefetcher.reg" 2>nul & echo [OK])
    pause
    goto MENU
)
if "%undo%"=="4" (
    if exist "%UNDO%\GameMode_PowerSettings.reg" (
        reg import "%UNDO%\GameMode_PowerSettings.reg" >nul 2>&1
    )
    if exist "%UNDO%\GameMode_Multimedia.reg" reg import "%UNDO%\GameMode_Multimedia.reg" >nul 2>&1
    if exist "%UNDO%\GameMode_BackgroundApps.reg" reg import "%UNDO%\GameMode_BackgroundApps.reg" >nul 2>&1
    del "%UNDO%\GameMode_*.reg" 2>nul
    echo [OK]
    pause
    goto MENU
)
if "%undo%"=="5" (
    set "list=SysMain DiagTrack dmwappushservice XblAuthManager XblGameSave XboxNetApiSvc"
    for %%s in (%list%) do (
        if exist "%UNDO%\Services_Backup_%%s.reg" (
            reg import "%UNDO%\Services_Backup_%%s.reg" >nul 2>&1
            del "%UNDO%\Services_Backup_%%s.reg" 2>nul
        )
    )
    echo [OK]
    pause
    goto MENU
)
if "%undo%"=="6" (
    if exist "%UNDO%\InputLatency_Mouse.reg" reg import "%UNDO%\InputLatency_Mouse.reg" >nul 2>&1
    if exist "%UNDO%\InputLatency_Mouclass.reg" reg import "%UNDO%\InputLatency_Mouclass.reg" >nul 2>&1
    if exist "%UNDO%\InputLatency_Kbdclass.reg" reg import "%UNDO%\InputLatency_Kbdclass.reg" >nul 2>&1
    del "%UNDO%\InputLatency_*.reg" 2>nul
    echo [OK]
    pause
    goto MENU
)

goto MENU

:: ---------------------------
:: HELP
:: ---------------------------

:HELP
cls
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║ Lynx Optimizer v6.1 - Help ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo [1] Network: TCP autotuning, congestion control
echo [2] Cleaner: Temp files, prefetch, update cache
echo [3] Extended: Browser cache, thumbnails
echo [4] Junk: Safe deletion from temp folders ONLY
echo [5] Debloat: Remove Microsoft Store apps (PowerShell)
echo [6] DNS: Set Cloudflare DNS (PowerShell)
echo [7] Services: Disable telemetry/Xbox with backup
echo [8] GameMode: Boost GPU/CPU priority
echo [9] Advanced: DirectX tweaks, cache settings
echo [10] ResetNet: Reset Winsock, TCP/IP stack
echo [11] Input: Reduce mouse/keyboard latency
echo [12] Backup: Create restore point & registry backup
echo [13] Help: This screen
echo [14] Undo: Revert specific changes
echo [15] SysInfo: Display system details
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║ SAFETY FIRST: Always use Option 12 before changes! ║
echo ║ Log file: %LOGFILE% ║
echo ║ Backups: %UNDO% ║
echo ╚════════════════════════════════════════════════════════════╝
pause
goto MENU

:: ---------------------------
:: SYSINFO
:: ---------------------------

:SYSINFO
cls
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Total Physical Memory" /C:"Processor(s)"
echo.
pause
goto MENU

:: ---------------------------
:: SILENT HELP / silent handlers (basic)
:: ---------------------------

:SILENT_HELP
echo Usage: %~nx0 [options]
echo Options:
echo   /clean   - Run Cleaner (non-interactive)
echo   /dns     - Run DNS optimizer (non-interactive)
echo   /sysinfo - Print system info
goto :EOF

:: Example simple silent implementations (kept minimal to avoid behavior change)
:SILENT_CLEAN
call :LOG "Silent clean requested"
goto CLEAN

:SILENT_CLEANX
call :LOG "Silent cleanx requested"
goto CLEANX

:SILENT_JUNK
call :LOG "Silent junk requested"
goto JUNK

:SILENT_DNS
if exist "%UNDO%\DNS.ps1" (
    powershell -ExecutionPolicy Bypass -File "%UNDO%\DNS.ps1"
) else (
    echo [ERROR] DNS script not found.
)
goto :EOF

:SILENT_GAMEMODE
goto GAMEMODE

:SILENT_RSTNET
goto RSTNET

:SILENT_SYSINFO
goto SYSINFO

:: ---------------------------
:: LOG - centralized logging with timestamp
:: ---------------------------

:LOG
:: Usage: call :LOG "message"
set "msg=%~1"
set "ts=%date% %time%"
if defined msg (
    >> "%LOGFILE%" echo [%ts%] %msg%
) else (
    >> "%LOGFILE%" echo [%ts%] (no message)
)
goto :EOF

:: End of script
endlocal
exit /b 0
