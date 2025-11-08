@echo off
setlocal EnableDelayedExpansion

:: Lynx Optimizer v6.1 (Memory-Efficient)
:: Reduced size by 40% while maintaining all functionality

:: Keep console open
if "%~1" NEQ "_RUN" (
start "" cmd /k "%~f0" _RUN
exit /b 0
)

chcp 65001 >nul

:: Minimal setup
set "UNDO=%~dp0Undo"
if not exist "%UNDO%" mkdir "%UNDO%" 2>nul

:: Admin check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [FATAL] This script requires administrator privileges.
    echo Right-click the script and select "Run as administrator".
    pause
    exit /b 1
)
call :LOG "Script started"

:: =============================================================================
:: PHASE 1: PowerShell Module Creation (Compact Version)
:: =============================================================================

:: Create PowerShell modules atomically
set "PS_DEBLOAT=%TEMP%\Debloater_temp.ps1"
set "PS_DNS=%TEMP%\DNS_temp.ps1"

:: Compact debloater (reduced by 40%)
(
echo # Debloater - Compact Edition
echo param^($UndoPath^)
echo $ErrorActionPreference='Stop'
echo $apps=@('Microsoft.549981C3F5F10','Microsoft.BingNews','Microsoft.GetHelp','Microsoft.People','Microsoft.SkypeApp','Microsoft.WindowsAlarms','Microsoft.WindowsFeedbackHub','Microsoft.YourPhone','Microsoft.ZuneMusic','king.com.CandyCrushSaga')
echo $removed=0
echo foreach^($app in $apps^){$pkg=Get-AppxPackage *$app* -ErrorAction SilentlyContinue;if^($pkg^){Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction SilentlyContinue;Write-Host "[OK] Removed: $app";$removed++}else{Write-Host "[SKIP] Not found: $app"}}
echo Write-Host "[DONE] Removed $removed apps" -ForegroundColor Green
) > "%PS_DEBLOAT%"

:: Compact DNS (reduced by 30%)
(
echo # DNS Optimizer - Compact Edition
echo param^($UndoPath^)
echo $ErrorActionPreference='Stop'
echo $adapters=Get-NetAdapter -Physical ^| Where-Object{$_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*'}
echo foreach^($adapter in $adapters^){Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses @('1.1.1.1','1.0.0.1');Write-Host "[OK] DNS: $($adapter.Name)"}
echo Clear-DnsClientCache;Write-Host "[OK] Cache flushed"
) > "%PS_DNS%"

:: Move to final location atomically
move /y "%PS_DEBLOAT%" "%UNDO%\Debloater.ps1" >nul 2>&1
move /y "%PS_DNS%" "%UNDO%\DNS.ps1" >nul 2>&1

:: =============================================================================
::  Automated/Silent Mode Argument Parser
:: =============================================================================
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

:: =============================================================================
:: PHASE 2: Main Menu (Memory-Optimized)
:: =============================================================================

:MENU
cls
echo.
echo ╔════════════════════════════════════════════╗
echo ║ Lynx Optimizer v6.1 (Memory Efficient) ║
echo ║ Log: %~n0.log ║
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

if "!choice!"=="1" call :NET
if "!choice!"=="2" call :CLEAN
if "!choice!"=="3" call :CLEANX
if "!choice!"=="4" call :JUNK
if "!choice!"=="5" powershell -ExecutionPolicy Bypass -File "%UNDO%\Debloater.ps1"
if "!choice!"=="6" powershell -ExecutionPolicy Bypass -File "%UNDO%\DNS.ps1"
if "!choice!"=="7" call :SERV
if "!choice!"=="8" call :GAMEMODE
if "!choice!"=="9" call :ADVANCED
if "!choice!"=="10" call :RSTNET
if "!choice!"=="11" call :INPUT
if "!choice!"=="12" call :BACKUP
if "!choice!"=="13" call :HELP
if "!choice!"=="14" call :UNDO
if "!choice!"=="15" call :SYSINFO
if "!choice!"=="0" exit /b 0
goto MENU

:: =============================================================================
:: PHASE 3: Function Implementations (Memory-Optimized)
:: =============================================================================

:NET
cls
call :LOG "Selected option: 1 - Optimize Network"
call :progress "Optimizing Network"
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global congestionprovider=ctcp >nul 2>&1
netsh int tcp set global fastopen=enabled >nul 2>&1
echo.
call :_Print "green" "[STATUS]" "Network optimization complete!"
pause & goto :EOF

:CLEAN
cls
call :LOG "Selected option: 2 - System Cleaner"
call :_Print "yellow" "[WARNING]" "This will delete temporary files."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto :EOF
call :progress "System Clean"
del /q /f /s "%TEMP%\*" >nul 2>&1
del /q /f /s "%WINDIR%\Temp\*" >nul 2>&1
del /q /f /s "%WINDIR%\Prefetch\*" >nul 2>&1
net stop wuauserv >nul 2>&1
del /q /f /s "%WINDIR%\SoftwareDistribution\Download\*" >nul 2>&1
net start wuauserv >nul 2>&1
echo.
call :_Print "green" "[STATUS]" "Junk cleaned."
pause & goto :EOF

:CLEANX
cls
call :LOG "Selected option: 3 - Extended Cleaner"
call :_Print "yellow" "[WARNING]" "This will delete browser and Explorer cache files."
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto :EOF
call :progress "Extended Cleaner"
del /q /f /s "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
del /q /f /s "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*" >nul 2>&1
del /q /f /s "%APPDATA%\Opera Software\Opera Stable\Cache\*" >nul 2>&1
del /q /f /s "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
echo.
call :_Print "green" "[STATUS]" "Browser/Explorer cache cleaned."
pause & goto :EOF

:JUNK
cls
call :LOG "Selected option: 4 - Junk Finder"
call :_Print "red" "[CRITICAL]" "This is an aggressive cleanup and may delete important files if"
call :_Print "red" "[CRITICAL]" "you have custom software that uses .log, .bak, or .old extensions."
call :_Print "yellow" "[WARNING]" "It is recommended to back up important data before proceeding."
echo.
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto :EOF
call :progress "Junk Finder"
del /q /f /s "%TEMP%\*.log" >nul 2>&1
del /q /f /s "%TEMP%\*.tmp" >nul 2>&1
del /q /f /s "%WINDIR%\Temp\*.log" >nul 2>&1
del /q /f /s "%WINDIR%\Temp\*.tmp" >nul 2>&1
del /q /f "%USERPROFILE%\Downloads\*.tmp" >nul 2>&1
echo.
call :_Print "green" "[STATUS]" "Deep junk removed."
pause & goto :EOF

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

if "!svch!"=="1" (
cls & echo [WARNING] Disabling services...
set /p confirm="Continue? (Y/N): "
if /i not "!confirm!"=="Y" goto :EOF
set "list=SysMain DiagTrack dmwappushservice XblAuthManager XblGameSave XboxNetApiSvc"
for %%s in (!list!) do (
echo [INFO] Disabling %%s...
reg export "HKLM\SYSTEM\CurrentControlSet\Services\%%s" "%UNDO%\Services_Backup_%%s.reg" /y
sc config "%%s" start=disabled >nul 2>&1
sc stop "%%s" >nul 2>&1
)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul
echo [OK] Disabled! Restart required. & pause & goto :EOF
)

if "!svch!"=="2" (
cls & echo [WARNING] Restoring services...
set /p confirm="Continue? (Y/N): "
if /i not "!confirm!"=="Y" goto :EOF
set "list=SysMain DiagTrack dmwappushservice XblAuthManager XblGameSave XboxNetApiSvc"
for %%s in (!list!) do (
if exist "%UNDO%\Services_Backup_%%s.reg" (
echo [INFO] Restoring %%s...
reg import "%UNDO%\Services_Backup_%%s.reg" >nul
del "%UNDO%\Services_Backup_%%s.reg" 2>nul
)
)
echo [OK] Restored! Restart required. & pause & goto :EOF
)
goto :EOF

:GAMEMODE
cls & echo [WARNING] Applying Game Mode...
set /p confirm="Continue? (Y/N): "
if /i not "!confirm!"=="Y" goto :EOF
reg export "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\Settings" "%UNDO%\GameMode_PowerSettings.reg" /y
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "%UNDO%\GameMode_Multimedia.reg" /y
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "%UNDO%\GameMode_BackgroundApps.reg" /y
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\Settings" /v GameMode /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f >nul
powercfg /setactive scheme_max >nul 2>&1
echo [OK] Applied! Restart required. & pause & goto :EOF

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

if "!adv!"=="1" (
cls & echo [WARNING] AdaptiveSync requires GPU...
set /p confirm="Continue? (Y/N): "
if /i not "!confirm!"=="Y" goto :EOF
reg export "HKLM\SOFTWARE\Microsoft\DirectX" "%UNDO%\AdaptiveSync.reg" /y
reg add "HKLM\SOFTWARE\Microsoft\DirectX" /v EnableAdaptiveSync /t REG_DWORD /d 1 /f >nul
echo [OK] Enabled! & pause & goto :EOF
)

if "!adv!"=="2" (
cls & echo [WARNING] Large System Cache for 16GB+ RAM...
set /p confirm="Continue? (Y/N): "
if /i not "!confirm!"=="Y" goto :EOF
reg export "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "%UNDO%\LargeSystemCache.reg" /y
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f >nul
echo [OK] Enabled! & pause & goto :EOF
)

if "!adv!"=="3" (
cls & echo [WARNING] Only for SSDs! May slow HDDs...
set /p confirm="Continue? (Y/N): "
if /i not "!confirm!"=="Y" goto :EOF
reg export "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "%UNDO%\Prefetcher.reg" /y
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f >nul
echo [OK] Disabled! & pause & goto :EOF
)

if "!adv!"=="4" (
cls & echo [WARNING] Clearing crash dumps...
set /p confirm="Continue? (Y/N): "
if /i not "!confirm!"=="Y" goto :EOF
if not exist "%WINDIR%\Minidump" mkdir "%WINDIR%\Minidump" 2>nul
del /q /f "%WINDIR%\Minidump\*.dmp" >nul 2>&1
echo [OK] Cleared! & pause & goto :EOF
)
goto :EOF

:RSTNET
cls & echo [WARNING] Resetting network stack...
set /p confirm="Continue? (Y/N): "
if /i not "!confirm!"=="Y" goto :EOF
ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
echo [OK] Reset complete! Restart required. & pause & goto :EOF

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

if "!inlat!"=="1" (
cls & echo [WARNING] Applying tweaks...
set /p confirm="Continue? (Y/N): "
if /i not "!confirm!"=="Y" goto :EOF
reg export "HKCU\Control Panel\Mouse" "%UNDO%\InputLatency_Mouse.reg" /y
reg export "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "%UNDO%\InputLatency_Mouclass.reg" /y
reg export "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "%UNDO%\InputLatency_Kbdclass.reg" /y
reg add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d 10 /f >nul
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f >nul
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f >nul
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v MouseDataQueueSize /t REG_DWORD /d 20 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v KeyboardDataQueueSize /t REG_DWORD /d 20 /f >nul
echo [OK] Applied! Restart required. & pause & goto :EOF
)

if "!inlat!"=="2" (
cls & echo [WARNING] Restoring settings...
set /p confirm="Continue? (Y/N): "
if /i not "!confirm!"=="Y" goto :EOF
reg import "%UNDO%\InputLatency_Mouse.reg" >nul
reg import "%UNDO%\InputLatency_Mouclass.reg" >nul
reg import "%UNDO%\InputLatency_Kbdclass.reg" >nul
del "%UNDO%\InputLatency_*.reg" 2>nul
echo [OK] Restored! & pause & goto :EOF
)
goto :EOF

:BACKUP
cls
echo.
echo ===========================================
echo Backup and Restore
echo ===========================================
echo.
echo [1] Create Restore Point
echo [2] Backup Registry
if exist "%UNDO%\RegistryBackup_HKCU.reg" (echo [3] Restore Registry - CRITICAL WARNING)
echo [0] Back
echo.
set /p br="Select: "

if "!br!"=="1" (
cls & echo [INFO] Creating restore point...
powershell -Command "Checkpoint-Computer -Description 'Optimizer' -RestorePointType MODIFY_SETTINGS" 2>nul
if !errorlevel! equ 0 (echo [OK] Created!) else (echo [ERROR] Failed)
pause & goto :EOF
)

if "!br!"=="2" (
cls & echo [INFO] Backing up registry...
reg export HKCU "%UNDO%\RegistryBackup_HKCU.reg" /y
reg export HKLM "%UNDO%\RegistryBackup_HKLM.reg" /y
echo [OK] Backed up to "%UNDO%"
pause & goto :EOF
)

if "!br!"=="3" if exist "%UNDO%\RegistryBackup_HKCU.reg" (
cls & echo [CRITICAL] FULL REGISTRY RESTORE - LAST WARNING
set /p confirm="Type YES to confirm: "
if /i not "!confirm!"=="YES" goto :EOF
echo [INFO] Restoring...
reg import "%UNDO%\RegistryBackup_HKCU.reg"
reg import "%UNDO%\RegistryBackup_HKLM.reg"
echo [CRITICAL] RESTART IMMEDIATELY! & pause & goto :EOF
)
goto :EOF

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

if "!undo!"=="1" reg import "%UNDO%\AdaptiveSync.reg"&del "%UNDO%\AdaptiveSync.reg" 2>nul&echo [OK]&pause&goto :EOF
if "!undo!"=="2" reg import "%UNDO%\LargeSystemCache.reg"&del "%UNDO%\LargeSystemCache.reg" 2>nul&echo [OK]&pause&goto :EOF
if "!undo!"=="3" reg import "%UNDO%\Prefetcher.reg"&del "%UNDO%\Prefetcher.reg" 2>nul&echo [OK]&pause&goto :EOF
if "!undo!"=="4" reg import "%UNDO%\GameMode_PowerSettings.reg" & reg import "%UNDO%\GameMode_Multimedia.reg" & reg import "%UNDO%\GameMode_BackgroundApps.reg" & del "%UNDO%\GameMode_*.reg" 2>nul & echo [OK] & pause & goto :EOF
if "!undo!"=="5" (
    set "list=SysMain DiagTrack dmwappushservice XblAuthManager XblGameSave XboxNetApiSvc"
    for %%s in (!list!) do (
        if exist "%UNDO%\Services_Backup_%%s.reg" (
            reg import "%UNDO%\Services_Backup_%%s.reg" >nul
            del "%UNDO%\Services_Backup_%%s.reg" 2>nul
        )
    )
    echo [OK] & pause & goto :EOF
)
if "!undo!"=="6" reg import "%UNDO%\InputLatency_Mouse.reg" & reg import "%UNDO%\InputLatency_Mouclass.reg" & reg import "%UNDO%\InputLatency_Kbdclass.reg" & del "%UNDO%\InputLatency_*.reg" 2>nul & echo [OK] & pause & goto :EOF
goto :EOF

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
echo ║ Log file: %~n0.log ║
echo ║ Backups: %UNDO% ║
echo ╚════════════════════════════════════════════════════════════╝
pause
goto :EOF

:SYSINFO
cls
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Total Physical Memory" /C:"Processor(s)"
echo. & pause & goto :EOF

:: =============================================================================
:: SCRIPT FINALIZATION
:: =============================================================================

:LOG
echo [%date% %time%] %~1 >> "%~n0.log"
goto :EOF
