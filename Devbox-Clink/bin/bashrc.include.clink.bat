@echo off
:: echo Included filename "%~f0"
::
:: This history alias is assuming you are using
:: clink with default clink profile location
::
doskey history=cat "%LOCALAPPDATA%\clink\.history" $*
