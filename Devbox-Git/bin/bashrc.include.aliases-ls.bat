@echo off
:: echo Included filename "%~f0"
::
:: Common DOS aliases, using `ls` command from `Git\bin`
::
doskey l=ls -CF --color=auto $*
doskey la=ls -A --color=auto $*
doskey ll=ls -alF --color=auto $*
doskey ls=ls --color=auto $*
