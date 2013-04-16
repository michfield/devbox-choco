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

    Write-ChocolateySuccess "$pkgName"
}
catch
{
    Write-ChocolateyFailure "$pkgName" "$($_.Exception.Message)"
    throw
}
