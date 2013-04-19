$pkg = "Devbox-Git"
$url = "https://msysgit.googlecode.com/files/Git-1.8.1.2-preview20130201.exe"

# Refresh environment from registry
Update-SessionEnvironment

# Installed already?
Stop-OnAppIsInstalled -pkg "$pkg" -match "Git version [0-9\.]+-preview\d*" -force $force

try {

    # Unattended installation arguments.
    #
    # I am forcing my preffered installation directory that is the same
    # as Git's default - but always the same, both for x86 and x64.
    #
    $silent = "/silent /dir=`"${env:ProgramFiles}\Git`" /components=`"ext,ext\cheetah`" /tasks=`"`""
    Install-ChocolateyPackage "$pkg" "exe" "$silent" "$url" -validExitCodes @(0)

    # Let's pretend we don't know where we installed Git. So we need to
    # detect where git.exe is located.
    #
    $dirs = Join-Path @("${env:ProgramFiles}","${env:ProgramFiles(x86)}") "Git\bin"
    $exe = Find-FileInPath "git.exe" $($dirs -join ";")

    $gitDir = if ($exe) { (Get-Item $(Split-Path "$exe" -parent)).parent.FullName } else { "" }

    if ($gitDir)
    {
        # Two things we must do manually, that is normally set by installer,
        # but not in the silent mode:
        # - Add Git (\cmd) and all tools (\bin) to PATH in User space
        # - Set Git config core.autocrlf to false
        #
        Install-ChocolateyPath $(Join-Path "$gitDir" "bin")
        Install-ChocolateyPath $(Join-Path "$gitDir" "cmd")

        # This will work, because new cmd.exe will reread environment
        # from registry, where we set a PATH properly
        #
        # Make GIT core.autocrlf false
        & "$env:comspec" '/c git config --global core.autocrlf false'
    }

    Write-ChocolateySuccess "$pkg"
}
catch
{
    Write-ChocolateyFailure "$pkg" "$($_.Exception.Message)"
    throw
}
