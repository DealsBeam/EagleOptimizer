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
echo    [1] Optimize Network        - Lower ping, stability
echo    [2] System Cleaner          - TEMP/cache/update
echo    [3] Extended Cleaner        - Browsers/Explorer cache
echo    [4] Junk Finder             - Deep log/dump removal
echo    [5] Optimize DNS            - Cloudflare + flush
echo    [6] Manage Services         - SysMain, Telemetry, Xbox
echo    [7] Game Mode + GPU Priority- Optimizes for gaming
echo    [8] Advanced Windows Tweaks - Prefetch, RAM, DirectX
echo    [9] Reset Network Adapter
echo    [10] Input Latency Tweaks
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
netsh int tcp set global chimney=enabled
netsh int tcp set global congestionprovider=ctcp
netsh int tcp set heuristics disabled
netsh int tcp set global rss=enabled
netsh int tcp set global fastopen=enabled
netsh interface tcp set global timestamps=disabled
echo.
echo [STATUS] Network optimization complete!
pause
goto MENU

:ANIM_CLEAN
cls
call :progress "System Clean"
del /q /f /s %TEMP%\* 2>nul
del /q /f /s C:\Windows\Temp\* 2>nul
del /q /f /s C:\Windows\Prefetch\* 2>nul
cleanmgr /sagerun:1
net stop wuauserv 2>nul
del /q /f /s C:\Windows\SoftwareDistribution\Download\* 2>nul
net start wuauserv 2>nul
echo.
echo [STATUS] Junk cleaned.
pause
goto MENU

:ANIM_CLEANX
cls
call :progress "Extended Cleaner"
del /q /f /s "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*" 2>nul
del /q /f /s "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*" 2>nul
del /q /f /s "%APPDATA%\Opera Software\Opera Stable\Cache\*" 2>nul
del /q /f /s "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" 2>nul
echo.
echo [STATUS] Browser/Explorer cache cleaned.
pause
goto MENU

:ANIM_JUNK
cls
call :progress "Junk Finder"
del /q /f /s "%SYSTEMDRIVE%\*.log" 2>nul
del /q /f /s "%SYSTEMDRIVE%\*.dmp" 2>nul
del /q /f /s "%SYSTEMDRIVE%\*.bak" 2>nul
del /q /f /s "%SYSTEMDRIVE%\*.old" 2>nul
del /q /f /s "%USERPROFILE%\Downloads\*.tmp" 2>nul
echo.
echo [STATUS] Deep junk removed.
pause
goto MENU

:ANIM_DNS
cls
call :progress "Optimizing DNS"
netsh interface ip set dns "Ethernet" static 1.1.1.1 primary
netsh interface ip add dns "Ethernet" 1.0.0.1 index=2
netsh interface ip set dns "Wi-Fi" static 1.1.1.1 primary
netsh interface ip add dns "Wi-Fi" 1.0.0.1 index=2
ipconfig /flushdns
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
    sc config "SysMain" start=disabled & sc stop "SysMain"
    sc config "DiagTrack" start=disabled & sc stop "DiagTrack"
    sc config "dmwappushservice" start=disabled & sc stop "dmwappushservice"
    sc config "XblAuthManager" start=disabled & sc stop "XblAuthManager"
    sc config "XblGameSave" start=disabled & sc stop "XblGameSave"
    sc config "XboxNetApiSvc" start=disabled & sc stop "XboxNetApiSvc"
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
    echo.
    echo [STATUS] Services disabled. Restart recommended!
    pause
    goto MENU
)
if "%svch%"=="2" (
    sc config "SysMain" start=auto & sc start "SysMain"
    sc config "DiagTrack" start=auto & sc start "DiagTrack"
    sc config "dmwappushservice" start=manual
    sc config "XblAuthManager" start=demand
    sc config "XblGameSave" start=demand
    sc config "XboxNetApiSvc" start=demand
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /f 2>nul
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /f 2>nul
    echo.
    echo [STATUS] Services restored.
    pause
    goto MENU
)
goto MENU

:GAMEMODE
cls
call :progress "Gaming Optimization"
:: Enable game mode (if applicable)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\Settings" /v GameMode /t REG_DWORD /d 1 /f
:: Boost GPU/CPU/RAM priority for games
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f
:: Disable background apps for performance
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f
:: Set power plan to "High performance"
powercfg /setactive SCHEME_MIN
echo.
echo [STATUS] Game Mode, GPU/CPU priority and background apps optimized.
pause
goto MENU

:ADVANCED_TWEAKS
cls
call :progress "Advanced Tweaks"
:: DirectX/VRAM tweaks, prefetch, priority optimization
reg add "HKLM\SOFTWARE\Microsoft\DirectX" /v EnableAdaptiveSync /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f
:: Disable prefetch/superfetch for SSD performance
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f
:: Automatically clear crash dumps
del /q /f /s "%SystemDrive%\Windows\Minidump\*" 2>nul
echo.
echo [STATUS] Advanced Windows tweaks applied.
pause
goto MENU

:ANIM_RSTNET
cls
call :progress "Network Reset"
ipconfig /release
ipconfig /renew
ipconfig /flushdns
netsh winsock reset
netsh int ip reset
netsh interface ipv4 reset
netsh interface ipv6 reset
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
    reg add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d 10 /f
    reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v MouseDataQueueSize /t REG_DWORD /d 20 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v KeyboardDataQueueSize /t REG_DWORD /d 20 /f
    echo.
    echo [STATUS] Input latency tweaks applied. Restart!
    pause
    goto MENU
)
if "%inlat%"=="2" (
    reg delete "HKCU\Control Panel\Mouse" /v MouseSensitivity /f 2>nul
    reg delete "HKCU\Control Panel\Mouse" /v MouseSpeed /f 2>nul
    reg delete "HKCU\Control Panel\Mouse" /v MouseThreshold1 /f 2>nul
    reg delete "HKCU\Control Panel\Mouse" /v MouseThreshold2 /f 2>nul
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v MouseDataQueueSize /f 2>nul
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v KeyboardDataQueueSize /f 2>nul
    echo.
    echo [STATUS] Input latency values restored.
    pause
    goto MENU
)
goto MENU

:EXIT
cls
echo.
echo                        [ Thank you for using! ]
echo      If you tweaked settings, please restart your computer.
echo.
pause
exit
