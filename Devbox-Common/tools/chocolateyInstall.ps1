# Exact package name. Filename-safe - directory will be created
# in choco\lib based on this value
#
$pkgName = 'Devbox-Common'

try
{
    # Helper function that updates current environment based on settings
    # in registry, thus avoiding a need for session restart
    #
    Update-SessionEnvironment

    $chocoBinRoot = 'chocolatey_bin_root'

    # Set variable only if not set
    #
    if (-not (Test-Path Env:\$chocoBinRoot)) {

        $binrootPath = Join-Path $Env:SystemDrive '\Tools'
        Install-ChocolateyEnvironmentVariable $chocoBinRoot $binrootPath
    }

    # Setting HOME variable only if not set
    #
    if (-not (Test-Path Env:\Home)) {
        $homePath = Join-Path $Env:HomeDrive $Env:HomePath
        Install-ChocolateyEnvironmentVariable "Home" $homePath
    }

    # Setup auto-run system of `~\.bashrc.bat` and includes
    #
    $srcDir = $(Get-Item $(Split-Path -parent $MyInvocation.MyCommand.Definition)).parent.FullName | Join-Path -ChildPath "bin"
    $homeDir = $Env:UserProfile

    # Note the leading dot. I like it that way.
    foreach ($fn in @("bashrc.bat", "bashrc.include.aliases-common.bat")) {
        Copy-Item $(Join-Path $srcDir "$fn" ) $(Join-Path $homeDir ".$fn" ) -Force
    }

    $bashrc = ".bashrc.bat"
    $bashrcFullPath = "$(join-path $homeDir $bashrc)"

    $regKeyPath = "HKCU:\Software\Microsoft\Command Processor"
    $regKeyProperty = "AutoRun"
    $oldReg = (Get-ItemProperty $regKeyPath).$regKeyProperty
    $newReg = ""

    # Check if empty
    if ($oldReg)
    {
        # Check for multiple values separated with `&&`
        if ($oldReg.Contains('&&'))
        {
            $oldRegParts = $oldReg.Split('&&')

            # Check each value for our file
            ForEach ($part in $oldRegParts)
            {
                $part = $part.Trim()

                if (!$part.ToLower().Contains($bashrc) -and ![string]::IsNullOrEmpty($part))
                {
                    $newReg += "$part `&`& "
                }
            }
            $newReg += "`"$bashrcFullPath`""
        }
        else
        {
            if ($oldReg.ToLower().Contains($bashrc))
            {
                $newReg = "`"$bashrcFullPath`""
            }
            else
            {
                $newReg = "$oldReg `&`& `"$bashrcFullPath`""
            }
        }
    }
    else
    {
        $newReg = "`"$bashrcFullPath`""
    }

    Set-ItemProperty -Path "$regKeyPath" -Name "$regKeyProperty" -Value "$newReg" -Type string

    # Last step - copy setenv.bat to chocolatey bin directory.
    #
    Copy-Item $(Join-Path $srcDir "setenv.bat" ) "$(Join-Path $Env:ChocolateyInstall "bin")" -Force

    Write-ChocolateySuccess "$pkgName"
}
catch
{
    Write-ChocolateyFailure "$pkgName" "$($_.Exception.Message)"
    throw
}
