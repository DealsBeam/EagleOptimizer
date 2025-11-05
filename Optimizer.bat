@echo off
chcp 65001 >nul
mode con: cols=80 lines=33

:: PRE-LOADER ANIMATION
set "spinner=|/-\"
cls
echo.
echo                                ╭─────────────────────────────╮
echo                                │  Windows 11 PC Optimizer   │
echo                                ╰─────────────────────────────╯
echo.
set msg=Initializing...
call :spinner "%msg%"
echo                              [ OK ] Initialization Finished!
timeout /t 1 >nul

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo =========================================================
    echo                ADMINISTRATOR RIGHTS REQUIRED            
    echo  Run as administrator! Right-click -> "Run as administrator"
    echo =========================================================
    pause
    exit
)

:: MAIN MENU LOOP
:MENU
cls
echo.
echo            ╭────────────────────────────────────────────╮
echo            │    WINDOWS 11 PC OPTIMIZER v3.2            │
echo            ╰────────────────────────────────────────────╯
echo.
echo    [1] Optimize Network        - Improves network stability and lowers ping.
echo    [2] System Cleaner          - Cleans temporary files, cache, and update leftovers.
echo    [3] Extended Cleaner        - Cleans browser and Explorer cache.
echo    [4] Junk Finder             - Removes deep logs and dumps.
echo    [5] Optimize DNS            - Switches to Cloudflare DNS for faster and more private browsing.
echo    [6] Manage Services         - Disables unnecessary services like SysMain, Telemetry, and Xbox.
echo    [7] Game Mode + GPU Priority- Optimizes system for gaming.
echo    [8] Advanced Windows Tweaks - Applies advanced tweaks for Prefetch, RAM, and DirectX.
echo    [9] Reset Network Adapter   - Resets the network adapter to default settings.
echo    [10] Input Latency Tweaks   - Reduces input latency for a more responsive experience.
echo    [11] Backup and Restore     - Creates a system restore point and backs up the registry.
echo    [12] Help / Information     - Provides a detailed overview of the script's functionality.
echo    [0] Exit
echo.
set /p choice="          Select an option: "
if /i "%choice%"=="1" goto ANIM_NET
if /i "%choice%"=="2" goto ANIM_CLEAN
if /i "%choice%"=="3" goto ANIM_CLEANX
if /i "%choice%"=="4" goto ANIM_JUNK
if /i "%choice%"=="5" goto ANIM_DNS
if /i "%choice%"=="6" goto ANIM_SERV
if /i "%choice%"=="7" goto GAMEMODE
if /i "%choice%"=="8" goto ADVANCED_TWEAKS
if /i "%choice%"=="9" goto ANIM_RSTNET
if /i "%choice%"=="10" goto ANIM_INPUT
if /i "%choice%"=="11" goto BACKUP_RESTORE
if /i "%choice%"=="12" goto HELP
if /i "%choice%"=="0" goto EXIT
goto MENU

:: -------- Spinner Animation
:spinner
setlocal enabledelayedexpansion
set "msg=%~1"
for /L %%i in (1,1,30) do (
    set /a idx=%%i %% 4
    set "spinchar=!spinner:~%idx%,1!"
    <nul set /p="                           !msg! !spinchar!`r"
    ping -n 1 127.0.0.1 >nul
)
endlocal
echo.
exit /b

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
    ping -n 1 127.0.0.1 >nul
)
echo.
endlocal
exit /b

:ANIM_NET
cls
call :progress "Optimizing Network"
netsh int tcp set global autotuninglevel=normal
if %errorlevel% neq 0 echo [ERROR] Failed to set autotuninglevel.
netsh int tcp set global chimney=enabled
if %errorlevel% neq 0 echo [ERROR] Failed to set chimney.
netsh int tcp set global congestionprovider=ctcp
if %errorlevel% neq 0 echo [ERROR] Failed to set congestionprovider.
netsh int tcp set heuristics disabled
if %errorlevel% neq 0 echo [ERROR] Failed to disable heuristics.
netsh int tcp set global rss=enabled
if %errorlevel% neq 0 echo [ERROR] Failed to enable rss.
netsh int tcp set global fastopen=enabled
if %errorlevel% neq 0 echo [ERROR] Failed to enable fastopen.
netsh interface tcp set global timestamps=disabled
if %errorlevel% neq 0 echo [ERROR] Failed to disable timestamps.
echo.
echo [STATUS] Network optimization complete!
pause
goto MENU

:ANIM_CLEAN
cls
echo [WARNING] This will delete temporary files.
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto MENU
call :progress "System Clean"
del /q /f /s %TEMP%\*
if %errorlevel% neq 0 echo [ERROR] Failed to delete files in %TEMP%.
del /q /f /s C:\Windows\Temp\*
if %errorlevel% neq 0 echo [ERROR] Failed to delete files in C:\Windows\Temp.
del /q /f /s C:\Windows\Prefetch\*
if %errorlevel% neq 0 echo [ERROR] Failed to delete files in C:\Windows\Prefetch.
cleanmgr /sagerun:1
if %errorlevel% neq 0 echo [ERROR] Failed to run cleanmgr.
net stop wuauserv
if %errorlevel% neq 0 echo [ERROR] Failed to stop wuauserv.
del /q /f /s C:\Windows\SoftwareDistribution\Download\*
if %errorlevel% neq 0 echo [ERROR] Failed to delete files in C:\Windows\SoftwareDistribution\Download.
net start wuauserv
if %errorlevel% neq 0 echo [ERROR] Failed to start wuauserv.
echo.
echo [STATUS] Junk cleaned.
pause
goto MENU

:ANIM_CLEANX
cls
echo [WARNING] This will delete browser and Explorer cache files.
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto MENU
call :progress "Extended Cleaner"
del /q /f /s "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*"
if %errorlevel% neq 0 echo [ERROR] Failed to delete Chrome cache.
del /q /f /s "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*"
if %errorlevel% neq 0 echo [ERROR] Failed to delete Edge cache.
del /q /f /s "%APPDATA%\Opera Software\Opera Stable\Cache\*"
if %errorlevel% neq 0 echo [ERROR] Failed to delete Opera cache.
del /q /f /s "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db"
if %errorlevel% neq 0 echo [ERROR] Failed to delete Explorer thumbcache.
echo.
echo [STATUS] Browser/Explorer cache cleaned.
pause
goto MENU

:ANIM_JUNK
cls
echo [WARNING] This will delete log, dump, bak, old, and tmp files.
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto MENU
call :progress "Junk Finder"
del /q /f /s "%SYSTEMDRIVE%\*.log"
if %errorlevel% neq 0 echo [ERROR] Failed to delete log files.
del /q /f /s "%SYSTEMDRIVE%\*.dmp"
if %errorlevel% neq 0 echo [ERROR] Failed to delete dmp files.
del /q /f /s "%SYSTEMDRIVE%\*.bak"
if %errorlevel% neq 0 echo [ERROR] Failed to delete bak files.
del /q /f /s "%SYSTEMDRIVE%\*.old"
if %errorlevel% neq 0 echo [ERROR] Failed to delete old files.
del /q /f /s "%USERPROFILE%\Downloads\*.tmp"
if %errorlevel% neq 0 echo [ERROR] Failed to delete tmp files in Downloads.
echo.
echo [STATUS] Deep junk removed.
pause
goto MENU

:ANIM_DNS
cls
call :progress "Optimizing DNS"
netsh interface ip set dns "Ethernet" static 1.1.1.1 primary
if %errorlevel% neq 0 echo [ERROR] Failed to set primary DNS for Ethernet.
netsh interface ip add dns "Ethernet" 1.0.0.1 index=2
if %errorlevel% neq 0 echo [ERROR] Failed to set secondary DNS for Ethernet.
netsh interface ip set dns "Wi-Fi" static 1.1.1.1 primary
if %errorlevel% neq 0 echo [ERROR] Failed to set primary DNS for Wi-Fi.
netsh interface ip add dns "Wi-Fi" 1.0.0.1 index=2
if %errorlevel% neq 0 echo [ERROR] Failed to set secondary DNS for Wi-Fi.
ipconfig /flushdns
if %errorlevel% neq 0 echo [ERROR] Failed to flush DNS.
echo.
echo [STATUS] DNS optimization done.
pause
goto MENU

:ANIM_SERV
cls
call :progress "Service Tuning"
echo [1] Disable unnecessary services (SysMain, Telemetry, Xbox)
echo [2] Restore default state
set /p svch="Choose 1/2 or [Enter] to back: "
if "%svch%"=="1" (
    echo [WARNING] This will disable several Windows services.
    set /p confirm="Are you sure you want to continue? (Y/N): "
    if /i not "%confirm%"=="Y" goto MENU
    sc config "SysMain" start=disabled & sc stop "SysMain"
    if !errorlevel! neq 0 echo [ERROR] Failed to disable SysMain.
    sc config "DiagTrack" start=disabled & sc stop "DiagTrack"
    if !errorlevel! neq 0 echo [ERROR] Failed to disable DiagTrack.
    sc config "dmwappushservice" start=disabled & sc stop "dmwappushservice"
    if !errorlevel! neq 0 echo [ERROR] Failed to disable dmwappushservice.
    sc config "XblAuthManager" start=disabled & sc stop "XblAuthManager"
    if !errorlevel! neq 0 echo [ERROR] Failed to disable XblAuthManager.
    sc config "XblGameSave" start=disabled & sc stop "XblGameSave"
    if !errorlevel! neq 0 echo [ERROR] Failed to disable XblGameSave.
    sc config "XboxNetApiSvc" start=disabled & sc stop "XboxNetApiSvc"
    if !errorlevel! neq 0 echo [ERROR] Failed to disable XboxNetApiSvc.
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
    if !errorlevel! neq 0 echo [ERROR] Failed to set AllowTelemetry policy.
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
    if !errorlevel! neq 0 echo [ERROR] Failed to set AllowTelemetry policy.
    echo.
    echo [STATUS] Services disabled. Restart recommended!
    pause
    goto MENU
)
if "%svch%"=="2" (
    echo [WARNING] This will restore default service configurations.
    set /p confirm="Are you sure you want to continue? (Y/N): "
    if /i not "%confirm%"=="Y" goto MENU
    sc config "SysMain" start=auto & sc start "SysMain"
    if !errorlevel! neq 0 echo [ERROR] Failed to restore SysMain.
    sc config "DiagTrack" start=auto & sc start "DiagTrack"
    if !errorlevel! neq 0 echo [ERROR] Failed to restore DiagTrack.
    sc config "dmwappushservice" start=manual
    if !errorlevel! neq 0 echo [ERROR] Failed to restore dmwappushservice.
    sc config "XblAuthManager" start=demand
    if !errorlevel! neq 0 echo [ERROR] Failed to restore XblAuthManager.
    sc config "XblGameSave" start=demand
    if !errorlevel! neq 0 echo [ERROR] Failed to restore XblGameSave.
    sc config "XboxNetApiSvc" start=demand
    if !errorlevel! neq 0 echo [ERROR] Failed to restore XboxNetApiSvc.
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /f
    if !errorlevel! neq 0 echo [ERROR] Failed to delete AllowTelemetry policy.
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /f
    if !errorlevel! neq 0 echo [ERROR] Failed to delete AllowTelemetry policy.
    echo.
    echo [STATUS] Services restored.
    pause
    goto MENU
)
goto MENU

:GAMEMODE
cls
echo [WARNING] This will modify system settings for gaming optimization.
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto MENU
call :progress "Gaming Optimization"
:: Enable game mode (if applicable)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\Settings" /v GameMode /t REG_DWORD /d 1 /f
if %errorlevel% neq 0 echo [ERROR] Failed to enable Game Mode.
:: Boost GPU/CPU/RAM priority for games
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f
if %errorlevel% neq 0 echo [ERROR] Failed to set GPU Priority.
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f
if %errorlevel% neq 0 echo [ERROR] Failed to set Priority.
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f
if %errorlevel% neq 0 echo [ERROR] Failed to set Scheduling Category.
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f
if %errorlevel% neq 0 echo [ERROR] Failed to set SFIO Priority.
:: Disable background apps for performance
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f
if %errorlevel% neq 0 echo [ERROR] Failed to disable background apps.
:: Set power plan to "High performance"
powercfg /setactive SCHEME_MIN
if %errorlevel% neq 0 echo [ERROR] Failed to set power plan.
echo.
echo [STATUS] Game Mode, GPU/CPU priority and background apps optimized.
pause
goto MENU

:ADVANCED_TWEAKS
cls
echo [WARNING] This will apply advanced Windows tweaks.
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto MENU
call :progress "Advanced Tweaks"
:: DirectX/VRAM tweaks, prefetch, priority optimization
reg add "HKLM\SOFTWARE\Microsoft\DirectX" /v EnableAdaptiveSync /t REG_DWORD /d 1 /f
if %errorlevel% neq 0 echo [ERROR] Failed to enable AdaptiveSync.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f
if %errorlevel% neq 0 echo [ERROR] Failed to enable LargeSystemCache.
:: Disable prefetch/superfetch for SSD performance
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f
if %errorlevel% neq 0 echo [ERROR] Failed to disable Prefetcher.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f
if %errorlevel% neq 0 echo [ERROR] Failed to disable Superfetch.
:: Automatically clear crash dumps
del /q /f /s "%SystemDrive%\Windows\Minidump\*"
if %errorlevel% neq 0 echo [ERROR] Failed to delete minidump files.
echo.
echo [STATUS] Advanced Windows tweaks applied.
pause
goto MENU

:ANIM_RSTNET
cls
echo [WARNING] This will reset your network adapter.
set /p confirm="Are you sure you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" goto MENU
call :progress "Network Reset"
ipconfig /release
if %errorlevel% neq 0 echo [ERROR] Failed to release IP address.
ipconfig /renew
if %errorlevel% neq 0 echo [ERROR] Failed to renew IP address.
ipconfig /flushdns
if %errorlevel% neq 0 echo [ERROR] Failed to flush DNS.
netsh winsock reset
if %errorlevel% neq 0 echo [ERROR] Failed to reset winsock.
netsh int ip reset
if %errorlevel% neq 0 echo [ERROR] Failed to reset IP.
netsh interface ipv4 reset
if %errorlevel% neq 0 echo [ERROR] Failed to reset IPv4.
netsh interface ipv6 reset
if %errorlevel% neq 0 echo [ERROR] Failed to reset IPv6.
echo.
echo [STATUS] Network reset done.
pause
goto MENU

:ANIM_INPUT
cls
call :progress "Input Latency"
echo [1] Apply lowest latency
echo [2] Restore defaults
set /p inlat="Choose 1/2 [Enter]-menu: "
if "%inlat%"=="1" (
    echo [WARNING] This will modify mouse and keyboard settings.
    set /p confirm="Are you sure you want to continue? (Y/N): "
    if /i not "%confirm%"=="Y" goto MENU
    reg add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d 10 /f
    if %errorlevel% neq 0 echo [ERROR] Failed to set MouseSensitivity.
    reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
    if %errorlevel% neq 0 echo [ERROR] Failed to set MouseSpeed.
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
    if %errorlevel% neq 0 echo [ERROR] Failed to set MouseThreshold1.
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f
    if %errorlevel% neq 0 echo [ERROR] Failed to set MouseThreshold2.
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v MouseDataQueueSize /t REG_DWORD /d 20 /f
    if %errorlevel% neq 0 echo [ERROR] Failed to set MouseDataQueueSize.
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v KeyboardDataQueueSize /t REG_DWORD /d 20 /f
    if %errorlevel% neq 0 echo [ERROR] Failed to set KeyboardDataQueueSize.
    echo.
    echo [STATUS] Input latency tweaks applied. Restart!
    pause
    goto MENU
)
if "%inlat%"=="2" (
    echo [WARNING] This will restore default mouse and keyboard settings.
    set /p confirm="Are you sure you want to continue? (Y/N): "
    if /i not "%confirm%"=="Y" goto MENU
    reg delete "HKCU\Control Panel\Mouse" /v MouseSensitivity /f
    if %errorlevel% neq 0 echo [ERROR] Failed to delete MouseSensitivity.
    reg delete "HKCU\Control Panel\Mouse" /v MouseSpeed /f
    if %errorlevel% neq 0 echo [ERROR] Failed to delete MouseSpeed.
    reg delete "HKCU\Control Panel\Mouse" /v MouseThreshold1 /f
    if %errorlevel% neq 0 echo [ERROR] Failed to delete MouseThreshold1.
    reg delete "HKCU\Control Panel\Mouse" /v MouseThreshold2 /f
    if %errorlevel% neq 0 echo [ERROR] Failed to delete MouseThreshold2.
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v MouseDataQueueSize /f
    if %errorlevel% neq 0 echo [ERROR] Failed to delete MouseDataQueueSize.
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v KeyboardDataQueueSize /f
    if %errorlevel% neq 0 echo [ERROR] Failed to delete KeyboardDataQueueSize.
    echo.
    echo [STATUS] Input latency values restored.
    pause
    goto MENU
)
goto MENU

:BACKUP_RESTORE
cls
echo.
echo            ╭────────────────────────────────────────────╮
echo            │             BACKUP AND RESTORE             │
echo            ╰────────────────────────────────────────────╯
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
    if exist "%~dp0RegistryBackup.reg" goto RESTORE_REGISTRY
)
if /i "%br_choice%"=="0" goto MENU
goto BACKUP_RESTORE

:CREATE_RESTORE_POINT
cls
call :progress "Creating System Restore Point"
powershell.exe -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description 'Optimizer Restore Point' -RestorePointType 'MODIFY_SETTINGS'"
echo.
echo [STATUS] System restore point created successfully.
pause
goto BACKUP_RESTORE

:BACKUP_REGISTRY
cls
call :progress "Backing up Registry"
reg export HKCU "%~dp0RegistryBackup_HKCU.reg" /y
reg export HKLM "%~dp0RegistryBackup_HKLM.reg" /y
echo.
echo [STATUS] Registry backup created successfully.
pause
goto BACKUP_RESTORE

:RESTORE_REGISTRY
cls
call :progress "Restoring Registry"
reg import "%~dp0RegistryBackup_HKCU.reg"
reg import "%~dp0RegistryBackup_HKLM.reg"
echo.
echo [STATUS] Registry restored successfully. Restart recommended!
pause
goto BACKUP_RESTORE

:HELP
cls
echo.
echo            ╭────────────────────────────────────────────╮
echo            │              HELP / INFORMATION            │
echo            ╰────────────────────────────────────────────╯
echo.
echo    [1] Optimize Network:
echo        - Sets TCP autotuning to normal, enables chimney offload, and uses CTCP congestion provider.
echo        - Disables heuristics, enables RSS, and fast open.
echo.
echo    [2] System Cleaner:
echo        - Deletes files from TEMP, C:\Windows\Temp, and Prefetch folders.
echo        - Runs the built-in Disk Cleanup utility.
echo        - Clears the Windows Update cache.
echo.
echo    [3] Extended Cleaner:
echo        - Deletes cache files from Chrome, Edge, and Opera.
echo        - Deletes Explorer's thumbnail cache.
echo.
echo    [4] Junk Finder:
echo        - Deletes .log, .dmp, .bak, .old, and .tmp files from the system drive and user's Downloads folder.
echo.
echo    [5] Optimize DNS:
echo        - Sets the DNS to Cloudflare's 1.1.1.1 and 1.0.0.1 for both Ethernet and Wi-Fi.
echo        - Flushes the DNS cache.
echo.
echo    [6] Manage Services:
echo        - Disables SysMain, DiagTrack, dmwappushservice, and Xbox services.
echo        - Disables telemetry through the registry.
echo.
echo    [7] Game Mode + GPU Priority:
echo        - Enables Game Mode, boosts GPU and CPU priority for games.
echo        - Disables background apps and sets the power plan to "High performance".
echo.
echo    [8] Advanced Windows Tweaks:
echo        - Enables AdaptiveSync for DirectX, enables LargeSystemCache.
echo        - Disables prefetcher and superfetch.
echo        - Clears minidump files.
echo.
echo    [9] Reset Network Adapter:
echo        - Releases and renews the IP address, flushes DNS, and resets Winsock and IP.
echo.
echo    [10] Input Latency Tweaks:
echo         - Adjusts mouse and keyboard settings to reduce input latency.
echo.
echo    [11] Backup and Restore:
echo         - Creates a system restore point and backs up the registry.
echo.
pause
goto MENU

:EXIT
cls
echo.
echo                        [ Thank you for using! ]
echo      If you tweaked settings, please restart your computer.
echo.
pause
exit
