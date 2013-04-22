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

    # Setting TERM variable only if not set
    #
    # There is a strange message saying `WARNING: terminal is not
    # fully functional` warning when starting Git log or diff
    # commands. The solution is to set environment variable `TERM`
    # to any valid value. If not set, on Windows it defaults to
    # `winansi`, and that's the one that Git doesn't like. So I must
    # set to anything else - any of the following: `cygwin`,
    # `vt100`, `msys`, `linux`.
    #
    if (-not (Test-Path Env:\Term)) {
        Install-ChocolateyEnvironmentVariable "TERM" "linux"
    }

    # Auto-run system supported - see Devbox-Common package
    $srcDir = $(Get-Item $(Split-Path -parent $MyInvocation.MyCommand.Definition)).parent.FullName | Join-Path -ChildPath "bin"
    foreach ($fn in @("bashrc.include.aliases-ls.bat","bashrc.include.aliases-git.bat"))
    {
        Copy-Item $(Join-Path $srcDir "$fn" ) $(Join-Path $Env:UserProfile ".$fn" ) -Force
    }

    Write-ChocolateySuccess "$pkg"
}
catch
{
    Write-ChocolateyFailure "$pkg" "$($_.Exception.Message)"
    throw
}
