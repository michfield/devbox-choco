$pkg = "Devbox-GitFlow"
$giturl = "git://github.com/nvie/gitflow.git"

# Refresh environment from registry
Update-SessionEnvironment

# Detect Git
$apps = @(Show-AppUninstallInfo -match "Git version [0-9\.]+-preview\d*")

try
{
    if ($apps.Length -eq 0)
    {
        throw "Could not detect a valid Git installation"
    }

    $app = $apps[0]
    $gitDir = $app["InstallLocation"]

    if (-not (Test-Path "$gitDir"))
    {
        throw "Local Git installation is detected, but directories are not accessible or have been removed"
    }

    # Copy executables provided in \bin dir of this package...
    #
    # These files are extracted from:
    #   http://downloads.sourceforge.net/gnuwin32/util-linux-ng-2.14.1-bin.zip
    #   http://downloads.sourceforge.net/gnuwin32/util-linux-ng-2.14.1-dep.zip
    #
    # Projects are very seldomly updated, so I decided to distribute
    # these files included with package.
    #
    $gitBin = Join-Path "$gitDir" "bin"
    $srcDir = $(Get-Item $(Split-Path -parent $MyInvocation.MyCommand.Definition)).parent.FullName | Join-Path -ChildPath "bin"

    Copy-Item $(Join-Path $srcDir "getopt.exe"  ) "$gitBin" -Force
    Copy-Item $(Join-Path $srcDir "libintl3.dll") "$gitBin" -Force

    # Now clone the repository. Git executable could not be in PATH
    # so we are using absolute filenames. Everything must be executed
    # with elevated privileges
    #
    $gitflowDir = Join-Path "$gitDir" "gitflow"
    $exeGit = Join-Path "$gitBin" "git.exe"
    $exeInstallGitFlow = Join-Path "$gitflowDir" "contrib\msysgit-install.cmd"

    if (Test-Path $(Join-Path "$gitBin" "git-flow"))
    {
        Write-Host "`nFound existing Git-Flow. Removing directory: $gitflowDir ...`n"  -foregroundcolor yellow
        Start-ChocolateyProcessAsAdmin "Get-ChildItem -path '$gitDir' -include 'git-flow*','gitflow-*','gitflow*' -recurse -force | Remove-Item -recurse -force" -minimized
    }

    Write-Host "`nGit-Flow: Cloning repository from GitHub and installing Git-Flow ...`n"  -foregroundcolor yellow

    Start-ChocolateyProcessAsAdmin "/c `"`"$exeGit`" clone --recursive `"$giturl`" `"$gitflowDir`"`"" -exe "$env:comspec" -minimized
    Start-ChocolateyProcessAsAdmin "/c `"`"$exeInstallGitFlow`" `"$gitDir`"`"" -exe "$env:comspec" -minimized

    Write-ChocolateySuccess "$pkg"
}
catch
{
    Write-ChocolateyFailure "$pkg" "$($_.Exception.Message)"
    throw
}
