@echo off
:: echo Included filename "%~f0"
::
:: This history alias is assuming you are using
:: clink with default clink profile location
::
doskey history=type "%LOCALAPPDATA%\clink\.history" $*
