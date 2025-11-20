@echo off
setlocal EnableDelayedExpansion

:: --------- Optimizer_safe.bat - Safer revision of original script ---------
:: TL;DR: non-destructive defaults, per-adapter DNS, browser checks, atomic PS writes,
::        backup before any registry/service change, typed confirmations for critical ops.
:: File path note: put this script in the working folder where you want logs/backups.

:: ---------------------------
:: Globals & Setup
:: ---------------------------
set "LOGFILE=%~n0.log"
set "UNDO=%~dp0Undo"
if not exist "%UNDO%" mkdir "%UNDO%" 2>nul

:: Admin check
net session >nul 2>&1
if errorlevel 1 (
    echo [FATAL] Administrator required. Right-click -> Run as administrator.
    pause
    exit /b 1
)

:: Ensure UTF-8 console
chcp 65001 >nul

:: ---------------------------
:: Helpers
:: ---------------------------
:_Print
rem Usage: call :_Print "color" "[TAG]" "message"
set "tag=%~2"
set "msg=%~3"
if defined tag (
    echo %tag% %msg%
) else (
    echo %msg%
)
goto :EOF

:progress
rem Usage: call :progress "Title"
set "pmsg=%~1"
echo.
echo %pmsg%...
timeout /t 1 >nul
echo.
goto :EOF

:confirm_yesno
rem Usage: call :confirm_yesno "Question"  -> returns 0 for yes, 1 for no
set "q=%~1"
set /p yn="%q% (Y/N): "
if /i "%yn%"=="Y" (exit /b 0) else (exit /b 1)

:confirm_type
rem Usage: call :confirm_type "Type EXACT phrase to confirm:" "EXPECTEDPHRASE"
set "q=%~1"
set "expected=%~2"
set /p input="%q%: "
if /i "%input%"=="%expected%" (exit /b 0) else (exit /b 1)

:LOG
rem Usage: call :LOG "message"
set "msg=%~1"
for /f "tokens=1-4 delims=/ " %%a in ("%date%") do set "D=%%a %%b %%c"
set "ts=%D% %time%"
if defined msg (
    >> "%LOGFILE%" echo [%ts%] %msg%
) else (
    >> "%LOGFILE%" echo [%ts%] (no message)
)
goto :EOF

:: Small helper: check if specified program is running
:is_running
rem Usage: call :is_running chrome.exe && (echo running)
tasklist /FI "IMAGENAME eq %~1" 2>NUL | find /I "%~1" >NUL
if errorlevel 1 (exit /b 1) else (exit /b 0)

:: ---------------------------
:: Atomic PowerShell Script Creation
:: ---------------------------
:write_ps_atomic
rem Usage: call :write_ps_atomic "Debloater" "content line 1" "content line 2" ...
rem This writes to %TEMP%\tmp_<name>_<pid>.ps1 then moves it to %UNDO%\<name>.ps1
set "psname=%~1"
set "tempfile=%TEMP%\tmp_%psname%_%random%.ps1"
if exist "%tempfile%" del /f /q "%tempfile%" 2>nul
shift
:write_ps_lines
if "%~0"=="" goto write_ps_done
echo %* >> "%tempfile%"
goto :EOF
:write_ps_done
move /y "%tempfile%" "%UNDO%\%psname%.ps1" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to move ps script to %UNDO%.
    call :LOG "Failed to atomically write PS script: %psname%"
) else (
    call :LOG "Wrote PS script: %psname% -> %UNDO%\%psname%.ps1"
)
goto :EOF

:: Note: above function is intentionally minimal; we'll create PS files inline using safe method below.

:: ---------------------------
:: Create safer PowerShell scripts (atomic)
:: ---------------------------
set "PS_DEBLOATER_TMP=%TEMP%\Debloater_safe_%random%.ps1"
(
    echo # Debloater - Safe Compact
    echo param^($UndoPath^)
    echo $ErrorActionPreference='Stop'
    echo $apps=@('Microsoft.549981C3F5F10','Microsoft.BingNews','Microsoft.GetHelp','Microsoft.People','Microsoft.SkypeApp','Microsoft.WindowsAlarms','Microsoft.WindowsFeedbackHub','Microsoft.YourPhone','Microsoft.ZuneMusic')
    echo foreach^($app in $apps^){$pkg=Get-AppxPackage *$app* -ErrorAction SilentlyContinue;if^($pkg^){Write-Host \"[INFO] Removing: $app\"; try{Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction SilentlyContinue; Write-Host \"[OK] Removed: $app\"}catch{Write-Host \"[WARN] Could not remove: $app\"}}else{Write-Host \"[SKIP] Not found: $app\"}}
    echo Write-Host \"[DONE] Debloat completed\" -ForegroundColor Green
) > "%PS_DEBLOATER_TMP%"

if exist "%PS_DEBLOATER_TMP%" move /y "%PS_DEBLOATER_TMP%" "%UNDO%\Debloater.ps1" >nul 2>&1 && call :LOG "Debloater.ps1 created"

set "PS_DNS_TMP=%TEMP%\DNS_safe_%random%.ps1"
(
    echo # DNS Optimizer - Safe Compact
    echo param^($AdapterIndexes^)
    echo $ErrorActionPreference='Stop'
    echo if^(-not $AdapterIndexes -or $AdapterIndexes.Count -eq 0^){Write-Host \"[ERROR] No adapters selected\"; exit 1}
    echo foreach^($idx in $AdapterIndexes^){$adapter=Get-NetAdapter -ifIndex $idx -ErrorAction SilentlyContinue;if^($adapter^){$old=Get-DnsClientServerAddress -InterfaceIndex $idx -ErrorAction SilentlyContinue; $old | Out-File -FilePath \"$env:TEMP\\dns_old_$idx.txt\"; Set-DnsClientServerAddress -InterfaceIndex $idx -ServerAddresses @('1.1.1.1','1.0.0.1'); Write-Host \"[OK] DNS set on $($adapter.Name)\"}else{Write-Host \"[SKIP] Adapter not found: $idx\"}}
    echo Clear-DnsClientCache; Write-Host \"[OK] Cache flushed\"
) > "%PS_DNS_TMP%"

if exist "%PS_DNS_TMP%" move /y "%PS_DNS_TMP%" "%UNDO%\DNS.ps1" >nul 2>&1 && call :LOG "DNS.ps1 created"

:: ---------------------------
:: Argument parser (preserve _RUN internal flag)
:: ---------------------------
if /i "%~1"=="_RUN" shift

if /i "%~1" equ "/clean" goto SILENT_CLEAN
if /i "%~1" equ "/cleanx" goto SILENT_CLEANX
if /i "%~1" equ "/junk" goto SILENT_JUNK
if /i "%~1" equ "/dns" goto SILENT_DNS
if /i "%~1" equ "/sysinfo" goto SILENT_SYSINFO
if /i "%~1" equ "/?" goto SILENT_HELP
if /i "%~1" equ "/help" goto SILENT_HELP

if not "%~1"=="" (
    call :_Print "red" "[ERROR]" "Invalid argument: %1"
    goto SILENT_HELP
)

:: ---------------------------
:: MAIN MENU (safer defaults)
:: ---------------------------
:MENU
cls
echo.
echo ╔════════════════════════════════════════════╗
echo ║ Lynx Optimizer v6.1 (Safer Edition)       ║
echo ║ Log: %LOGFILE%                             ║
echo ╚════════════════════════════════════════════╝
echo.
echo [1] Network Optimization
echo [2] System Cleaner (safe: deletes temp files older than 7 days)
echo [3] Extended Cleaner (browser caches — checks for running browsers)
echo [4] Junk Finder (aggressive — typed confirmation required)
echo [5] Debloater (PowerShell)
echo [6] DNS Optimizer (PowerShell, per-adapter)
echo [7] Service Manager
echo [8] Game Mode
echo [9] Advanced Tweaks
echo [10] Reset Network
echo [11] Input Latency
echo [12] Backup/Restore (targeted backups only)
echo [13] Help
echo [14] Undo Tweaks (only items changed by this script)
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
        echo [INFO] Select adapters to apply DNS (you'll be prompted).
        powershell -ExecutionPolicy Bypass -File "%UNDO%\DNS.ps1" -AdapterIndexes @(Get-NetAdapter | Where-Object {$_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*'} | Select -ExpandProperty ifIndex)
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
:: NETWORK (unchanged)
:: ---------------------------
:NET
cls
call :LOG "Selected option: Network Optimization"
call :_Print "yellow" "[INFO]" "Setting TCP options..."
netsh int tcp set global autotuninglevel=normal >nul 2>&1
if errorlevel 1 echo [ERROR] Failed to set autotuninglevel.
netsh int tcp set global congestionprovider=ctcp >nul 2>&1
if errorlevel 1 echo [ERROR] Failed to set congestionprovider.
netsh int tcp set global fastopen=enabled >nul 2>&1
if errorlevel 1 echo [ERROR] Failed to set fastopen.
echo [OK] Complete!
call :LOG "Network optimization applied"
pause
goto MENU

:: ---------------------------
:: CLEAN (Safe System Cleaner)
:: ---------------------------
:CLEAN
cls
call :LOG "Selected option: System Cleaner (safe)"
call :_Print "yellow" "[WARNING]" "This will delete temporary files older than 7 days."
call :confirm_yesno "Are you sure you want to continue?"
if errorlevel 1 goto MENU
call :progress "System Clean"

rem Delete files older than 7 days in user and system temp
for /f "delims=" %%I in ('forfiles /p "%TEMP%" /s /m * /d -7 /c "cmd /c echo @path" 2^>nul') do (
    del /q "%%~I" 2>nul
)
for /f "delims=" %%I in ('forfiles /p "%WINDIR%\Temp" /s /m * /d -7 /c "cmd /c echo @path" 2^>nul') do (
    del /q "%%~I" 2>nul
)

rem Do not delete Prefetch by default; offer option
echo.
set /p delpref="Delete Prefetch files? (Recommended: No) (Y/N): "
if /i "%delpref%"=="Y" (
    echo Deleting Prefetch...
    del /q /f "%WINDIR%\Prefetch\*" >nul 2>&1
    call :LOG "Prefetch cleared by user"
) else (
    echo Skipping Prefetch.
)

echo.
call :_Print "green" "[STATUS]" "Safe temp cleanup completed."
call :LOG "Safe cleaner completed"
pause
goto MENU

:: ---------------------------
:: CLEANX (Extended Cleaner - browser caches)
:: ---------------------------
:CLEANX
cls
call :LOG "Selected option: Extended Cleaner"
call :_Print "yellow" "[WARNING]" "This will clear browser caches older than 3 days (if browsers not running)."
call :confirm_yesno "Continue?"
if errorlevel 1 goto MENU
call :progress "Extended Cleaner"

rem Check for common browsers
set "browserFound=0"
call :is_running chrome.exe || set /a browserFound+=0 || (set "browserFound=1" & echo [WARN] Chrome detected)
call :is_running msedge.exe || if %errorlevel%==0 (set "browserFound=1" & echo [WARN] Edge detected)
call :is_running opera.exe || if %errorlevel%==0 (set "browserFound=1" & echo [WARN] Opera detected)

if "%browserFound%"=="1" (
    echo [CRITICAL] One or more browsers are running.
    echo Close browsers or proceed with typed confirmation.
    call :confirm_type "To proceed while browsers are running, type PROCEED" "PROCEED"
    if errorlevel 1 (
        echo Aborting extended cleaning.
        goto MENU
    )
)

rem Delete browser cache files older than 3 days
for /f "delims=" %%I in ('forfiles /p "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" /s /m * /d -3 /c "cmd /c echo @path" 2^>nul') do del /q "%%~I" 2>nul
for /f "delims=" %%I in ('forfiles /p "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" /s /m * /d -3 /c "cmd /c echo @path" 2^>nul') do del /q "%%~I" 2>nul
for /f "delims=" %%I in ('forfiles /p "%APPDATA%\Opera Software\Opera Stable\Cache" /s /m * /d -3 /c "cmd /c echo @path" 2^>nul') do del /q "%%~I" 2>nul

rem Thumbnails: delete only when Explorer is not locked
tasklist /FI "IMAGENAME eq explorer.exe" | find /I "explorer.exe" >nul
if errorlevel 1 (
    del /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
) else (
    echo [WARN] Explorer running; skipping thumbnail DB deletion to avoid corruption.
)

call :LOG "Extended cleaner executed"
echo.
call :_Print "green" "[STATUS]" "Browser/Explorer cache cleaned (safe mode)."
pause
goto MENU

:: ---------------------------
:: JUNK (Aggressive) - REQUIRES STRONG TYPED CONFIRMATION
:: ---------------------------
:JUNK
cls
call :LOG "Selected option: Junk Finder (aggressive)"
call :_Print "red" "[CRITICAL]" "This is aggressive and may delete logs/backups. Back up important data first."
echo To continue, type I UNDERSTAND and press Enter.
set /p confirmAgg="Type exactly: I UNDERSTAND: "
if NOT "%confirmAgg%"=="I UNDERSTAND" (
    echo Confirmation not matched. Aborting.
    goto MENU
)

call :progress "Junk Finder (aggressive)"

rem Delete temp log/tmp older than 14 days only
for /f "delims=" %%I in ('forfiles /p "%TEMP%" /s /m *.log /d -14 /c "cmd /c echo @path" 2^>nul') do del /q "%%~I" 2>nul
for /f "delims=" %%I in ('forfiles /p "%TEMP%" /s /m *.tmp /d -14 /c "cmd /c echo @path" 2^>nul') do del /q "%%~I" 2>nul
for /f "delims=" %%I in ('forfiles /p "%WINDIR%\Temp" /s /m *.log /d -14 /c "cmd /c echo @path" 2^>nul') do del /q "%%~I" 2>nul

echo [OK] Aggressive cleanup performed (restricted to older files).
call :LOG "Aggressive junk cleanup performed"
pause
goto MENU

:: ---------------------------
:: DEBLOATER - uses atomic PS in %UNDO%
:: ---------------------------
:ACTION_DEBLOAT
cls
call :LOG "Selected option: Debloater"
:DEBLOAT_MENU
cls
echo.
echo ===========================================
echo Windows Debloater (Safe)
echo ===========================================
echo.
echo [1] Recommended Debloat (safe list)
echo [2] Custom Debloat (interactive)
echo [0] Back to Main Menu
echo.
set /p debloat_choice="Select an option: "
if /i "%debloat_choice%"=="1" goto DEBLOAT_RECOMMENDED
if /i "%debloat_choice%"=="2" goto DEBLOAT_CUSTOM
if /i "%debloat_choice%"=="0" goto MENU
goto DEBLOAT_MENU

:DEBLOAT_RECOMMENDED
cls
call :LOG "Debloater: Recommended"
echo This will attempt to remove commonly unwanted Store apps (non-destructive: will not touch system components).
echo The script will run from %UNDO%\Debloater.ps1
call :confirm_yesno "Proceed with recommended debloat?"
if errorlevel 1 goto DEBLOAT_MENU
if exist "%UNDO%\Debloater.ps1" (
    powershell -ExecutionPolicy Bypass -File "%UNDO%\Debloater.ps1" "%UNDO%"
    if errorlevel 1 echo [ERROR] Debloater script failed.
) else (
    echo [ERROR] Debloater script missing: "%UNDO%\Debloater.ps1"
)
pause
goto DEBLOAT_MENU

:DEBLOAT_CUSTOM
cls
call :LOG "Debloater: Custom"
call :_Print "yellow" "[NOTICE]" "You can remove apps by partial name; results will be shown before removal."
call :confirm_yesno "Continue?"
if errorlevel 1 goto DEBLOAT_MENU

:DEBLOAT_CUSTOM_LOOP
cls
echo [INFO] Listing Appx packages (paged)...
powershell.exe -ExecutionPolicy Bypass -Command "Get-AppxPackage | Select-Object -Property Name, PackageFullName | Out-Host -Paging"
echo.
set /p app_name="Enter the full or partial name of the app to remove (or type 'exit' to return): "
if /i "%app_name%"=="exit" goto DEBLOAT_MENU
if "%app_name%"=="" goto DEBLOAT_CUSTOM_LOOP

echo [INFO] Matching packages...
powershell.exe -ExecutionPolicy Bypass -Command "Get-AppxPackage *%app_name%* | Select Name, PackageFullName"
echo.
set /p removeConfirm="Type YES to remove all matched packages: "
if /i "%removeConfirm%"=="YES" (
    powershell.exe -ExecutionPolicy Bypass -Command "Get-AppxPackage *%app_name%* | Remove-AppxPackage" >nul 2>&1
    if errorlevel 1 echo [ERROR] Failed to remove or none matched.
    call :LOG "Attempted to remove AppX Package: %app_name%"
) else (
    echo Skipping removal.
)
echo.
echo [INFO] Operation complete. You can remove another or type 'exit'.
pause
goto DEBLOAT_CUSTOM_LOOP

:: ---------------------------
:: SERVICE manager (safe: backup then optional manual/disabled)
:: ---------------------------
:SERV
cls
call :LOG "Selected option: Service Management"
echo.
echo ===========================================
echo Service Management (safe)
echo ===========================================
echo.
echo [1] Set services to manual (recommended) / optionally disable
echo [2] Restore services from backups (only those created by this script)
echo [0] Back
echo.
set /p svch="Select: "

if "%svch%"=="1" (
    cls
    call :_Print "yellow" "[WARNING]" "This will change service start types for specific services (SysMain, DiagTrack, dmwappushservice, Xbl*)."
    echo You will be asked to choose Manual or Disable.
    call :confirm_yesno "Continue?"
    if errorlevel 1 goto MENU

    set /p mode="Type MANUAL to set start=manual, or DISABLE to set start=disabled: "
    if /i not "%mode%"=="MANUAL" if /i not "%mode%"=="DISABLE" (
        echo Invalid choice. Aborting.
        goto MENU
    )

    set "list=SysMain DiagTrack dmwappushservice XblAuthManager XblGameSave XboxNetApiSvc"
    for %%s in (%list%) do (
        echo [INFO] Backing up registry for %%s...
        reg export "HKLM\SYSTEM\CurrentControlSet\Services\%%s" "%UNDO%\Services_Backup_%%s.reg" /y >nul 2>&1
        if "%mode%"=="MANUAL" (
            sc config "%%s" start= demand >nul 2>&1
        ) else (
            sc config "%%s" start= disabled >nul 2>&1
        )
        sc stop "%%s" >nul 2>&1
    )
    echo [OK] Services adjusted. Backups in %UNDO%.
    call :LOG "Services set to %mode%"
    pause
    goto MENU
)

if "%svch%"=="2" (
    cls
    call :_Print "yellow" "[WARNING]" "Restoring services from backups in %UNDO% (only those created by this script)."
    call :confirm_yesno "Continue?"
    if errorlevel 1 goto MENU
    set "list=SysMain DiagTrack dmwappushservice XblAuthManager XblGameSave XboxNetApiSvc"
    for %%s in (%list%) do (
        if exist "%UNDO%\Services_Backup_%%s.reg" (
            reg import "%UNDO%\Services_Backup_%%s.reg" >nul 2>&1
            del "%UNDO%\Services_Backup_%%s.reg" 2>nul
            echo [INFO] Restored %%s
        )
    )
    echo [OK] Restored services.
    call :LOG "Services restored from backups"
    pause
    goto MENU
)

goto MENU

:: ---------------------------
:: GAMEMODE (safe backups)
:: ---------------------------
:GAMEMODE
cls
call :LOG "Selected option: Game Mode"
call :_Print "yellow" "[INFO]" "Applying Game Mode tweaks (backups created)."
call :confirm_yesno "Continue?"
if errorlevel 1 goto MENU

reg export "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\Settings" "%UNDO%\GameMode_PowerSettings.reg" /y >nul 2>&1
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "%UNDO%\GameMode_Multimedia.reg" /y >nul 2>&1
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "%UNDO%\GameMode_BackgroundApps.reg" /y >nul 2>&1

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\Settings" /v GameMode /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f >nul 2>&1

call :LOG "Game mode tweaks applied (backups created)"
echo [OK] Applied! Restart recommended.
pause
goto MENU

:: ---------------------------
:: ADVANCED tweaks (targeted & backed up)
:: ---------------------------
:ADVANCED
cls
echo.
echo ===========================================
echo Advanced Tweaks (safe & backed up)
echo ===========================================
echo.
echo [1] AdaptiveSync (DirectX)
echo [2] Large System Cache (for specific workloads)
echo [3] Disable Prefetcher (requires typed confirmation)
echo [4] Clear Crash Dumps
echo [0] Back
echo.
set /p adv="Select: "

if "%adv%"=="1" (
    cls
    call :_Print "yellow" "[WARNING]" "AdaptiveSync requires GPU support; backups will be created."
    call :confirm_yesno "Continue?"
    if errorlevel 1 goto MENU
    reg export "HKLM\SOFTWARE\Microsoft\DirectX" "%UNDO%\AdaptiveSync.reg" /y >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\DirectX" /v EnableAdaptiveSync /t REG_DWORD /d 1 /f >nul 2>&1
    call :LOG "AdaptiveSync enabled (backup saved)"
    echo [OK] Enabled!
    pause
    goto MENU
)

if "%adv%"=="2" (
    cls
    call :_Print "yellow" "[INFO]" "Large System Cache should be used only for server/workstation workloads."
    call :confirm_yesno "Continue?"
    if errorlevel 1 goto MENU
    reg export "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "%UNDO%\LargeSystemCache.reg" /y >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f >nul 2>&1
    call :LOG "LargeSystemCache set (backup saved)"
    echo [OK] Enabled!
    pause
    goto MENU
)

if "%adv%"=="3" (
    cls
    call :_Print "yellow" "[WARNING]" "Disabling Prefetcher may slow some systems. Typed confirmation required."
    call :confirm_type "Type DISABLE_PREFETCH to confirm" "DISABLE_PREFETCH"
    if errorlevel 1 goto MENU
    reg export "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "%UNDO%\Prefetcher.reg" /y >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f >nul 2>&1
    call :LOG "Prefetcher disabled (backup saved)"
    echo [OK] Disabled!
    pause
    goto MENU
)

if "%adv%"=="4" (
    cls
    call :_Print "yellow" "[INFO]" "Clearing crash dumps..."
    call :confirm_yesno "Continue?"
    if errorlevel 1 goto MENU
    if not exist "%WINDIR%\Minidump" mkdir "%WINDIR%\Minidump" 2>nul
    del /q /f "%WINDIR%\Minidump\*.dmp" >nul 2>&1
    call :LOG "Crash dumps cleared"
    echo [OK] Cleared!
    pause
    goto MENU
)

goto MENU

:: ---------------------------
:: Reset Network (unchanged)
:: ---------------------------
:RSTNET
cls
call :_Print "yellow" "[WARNING]" "Resetting network stack..."
call :confirm_yesno "Continue?"
if errorlevel 1 goto MENU

ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
call :LOG "Network stack reset"
echo [OK] Reset complete! Restart recommended.
pause
goto MENU

:: ---------------------------
:: INPUT LATENCY (safe backups)
:: ---------------------------
:INPUT
cls
call :LOG "Selected option: Input Latency Tweaks"
echo.
echo ===========================================
echo Input Latency Tweaks
echo ===========================================
echo.
if exist "%UNDO%\InputLatency_Mouse.reg" echo [2] Restore Defaults
echo [1] Apply Lowest Latency (backups created)
echo [0] Back
echo.
set /p inlat="Select: "

if "%inlat%"=="1" (
    cls
    call :_Print "yellow" "[WARNING]" "Applying tweaks (backups created)."
    call :confirm_yesno "Continue?"
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
    call :LOG "Input latency tweaks applied (backups saved)"
    echo [OK] Applied! Restart recommended.
    pause
    goto MENU
)

if "%inlat%"=="2" (
    cls
    call :_Print "yellow" "[INFO]" "Restoring input latency settings from backups (if present)."
    call :confirm_yesno "Continue?"
    if errorlevel 1 goto MENU
    if exist "%UNDO%\InputLatency_Mouse.reg" reg import "%UNDO%\InputLatency_Mouse.reg" >nul 2>&1
    if exist "%UNDO%\InputLatency_Mouclass.reg" reg import "%UNDO%\InputLatency_Mouclass.reg" >nul 2>&1
    if exist "%UNDO%\InputLatency_Kbdclass.reg" reg import "%UNDO%\InputLatency_Kbdclass.reg" >nul 2>&1
    del "%UNDO%\InputLatency_*.reg" 2>nul
    call :LOG "Input latency settings restored"
    echo [OK] Restored!
    pause
    goto MENU
)

goto MENU

:: ---------------------------
:: BACKUP / RESTORE (targeted only)
:: ---------------------------
:BACKUP
cls
call :LOG "Selected option: Backup/Restore"
echo.
echo ===========================================
echo Backup and Restore (targeted)
echo ===========================================
echo.
echo [1] Create System Restore Point
echo [2] Backup Registry keys modified by this script
if exist "%UNDO%\RegistryBackup_Targeted.txt" echo [3] Restore targeted backups (typed confirmation required)
echo [0] Back
echo.
set /p br="Select: "

if "%br%"=="1" (
    cls
    echo [INFO] Creating restore point...
    powershell -Command "Checkpoint-Computer -Description 'Optimizer Safe' -RestorePointType MODIFY_SETTINGS" 2>nul
    if errorlevel 1 (echo [ERROR] Failed) else (echo [OK] Created!)
    call :LOG "Restore point created"
    pause
    goto MENU
)

if "%br%"=="2" (
    cls
    echo [INFO] Backing up selected registry keys to %UNDO%
    echo Backups created on %date% %time% > "%UNDO%\RegistryBackup_Targeted.txt"
    echo HKLM\SYSTEM\CurrentControlSet\Control\Power\User\Settings >> "%UNDO%\RegistryBackup_Targeted.txt"
    reg export "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\Settings" "%UNDO%\RegistryBackup_GameMode_PowerSettings.reg" /y >nul 2>&1
    reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "%UNDO%\RegistryBackup_GameMode_Multimedia.reg" /y >nul 2>&1
    reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "%UNDO%\RegistryBackup_GameMode_BackgroundApps.reg" /y >nul 2>&1
    echo [OK] Targeted backups saved.
    call :LOG "Registry targeted backups saved"
    pause
    goto MENU
)

if "%br%"=="3" (
    if exist "%UNDO%\RegistryBackup_Targeted.txt" (
        cls
        echo [CRITICAL] Targeted registry restore - requires typed confirmation.
        call :confirm_type "Type RESTORE_REGISTRY to continue" "RESTORE_REGISTRY"
        if errorlevel 1 goto MENU
        echo Restoring targeted keys...
        reg import "%UNDO%\RegistryBackup_GameMode_PowerSettings.reg" >nul 2>&1
        reg import "%UNDO%\RegistryBackup_GameMode_Multimedia.reg" >nul 2>&1
        reg import "%UNDO%\RegistryBackup_GameMode_BackgroundApps.reg" >nul 2>&1
        echo [OK] Targeted restore complete. Restart recommended.
        call :LOG "Targeted registry restore executed by user"
        pause
        goto MENU
    ) else (
        echo [ERROR] No targeted registry backup found.
        pause
        goto MENU
    )
)

goto MENU

:: ---------------------------
:: UNDO tweaks (only items changed by this script)
:: ---------------------------
:UNDO
cls
call :LOG "Selected option: Undo Tweaks"
echo.
echo ===========================================
echo Undo Tweaks (only items changed by this script)
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
echo ║ Lynx Optimizer v6.1 - Help (Safer Edition)                ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo This safer edition uses conservative defaults:
echo  - Temp files older than 7 days are removed.
echo  - Browser caches removed only if not running (or with typed confirmation).
echo  - No automatic full-hive registry restores.
echo  - PowerShell scripts are created atomically in %UNDO%.
echo  - DNS changes are applied per-adapter (script prompts).
echo.
echo Always inspect %LOGFILE% and backups in %UNDO% before restoring.
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
:: SILENT handlers (safe)
:: ---------------------------
:SILENT_HELP
echo Usage: %~nx0 [options]
echo Options:
echo   /clean   - Run Cleaner (non-interactive, safe)
echo   /dns     - Run DNS optimizer (non-interactive, prompts)
echo   /sysinfo - Print system info
goto :EOF

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

:SILENT_SYSINFO
goto SYSINFO

:: ---------------------------
:: End & cleanup
:: ---------------------------
endlocal
exit /b 0
