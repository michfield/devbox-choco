@echo off
:: echo Included filename "%~f0"
::
:: Command prompt aliases focused on Git
:: See: http://gitimmersion.com/lab_11.html
::
doskey gs=git status $*
doskey ga=git add $*
doskey gb=git branch $*
doskey gc=git commit $*
doskey gd=git diff $*

:: The `go` abbreviation for `git checkout` is particularly nice.
:: It allows me to type:  `go <branch>` to checkout a particular branch.
::
doskey go=git checkout $*

:: If you mistype git as `get` or `got`
::
doskey got=git $*
doskey get=git $*

:: The most powerfull one
doskey g=git $*
