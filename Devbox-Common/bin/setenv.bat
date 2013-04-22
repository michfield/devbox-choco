@echo off
::
:: setenv.bat
::
:: Batch file to read environment variables from registry and
:: set session variables to these values.
::
:: With this batch file, there should be no need to reload command
:: environment every time you want environment changes to propagate
::
:: Sources:
::  http://www.dostips.com/DtCodeBatchFiles.php#Batch.FindAndReplace
::

:: A strange trick to print without newline
echo | set /p dummy="Reading environment variables from registry. Please wait... "

:: These settings are default already - just to be sure
setlocal ENABLEEXTENSIONS DISABLEDELAYEDEXPANSION
goto main

:: Set one environment variable from registry key
:SetFromReg
    "%WinDir%\System32\Reg" QUERY "%~1" /v "%~2" > "%TEMP%\setenv.tmp"
    for /f "usebackq skip=2 tokens=2,*" %%A IN ("%TEMP%\setenv.tmp") do (
        call set %~3=%%B
    )
    goto :EOF

:: Get a list of environment variables from registry
:GetRegEnv
    "%WinDir%\System32\Reg" QUERY "%~1" > "%TEMP%\getenv.tmp"
    for /f "usebackq skip=2" %%A IN ("%TEMP%\getenv.tmp") do (
        if /I not "%%~A"=="Path" (
            call :SetFromReg "%~1" "%%~A" "%%~A"
        )
    )
    goto :EOF

:main
    call :GetRegEnv "HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
    call :GetRegEnv "HKCU\Environment"

    :: Delete tempoorary files that we made
    del /f /q "%TEMP%\setenv.tmp" 2>nul
    del /f /q "%TEMP%\getenv.tmp" 2>nul

    :: Special handling for Path - mix both User and System
    call :SetFromReg "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" Path Path
    setlocal
        set _vartmp=
        call :SetFromReg "HKCU\Environment" Path _vartmp
    endlocal & if not "%Path%"=="" if not "%u%"=="" set Path=%Path%;%u%

    echo | set /p dummy="Done."