$pkgName = 'Devbox-Common'

try
{
    # Propagate environment to a current session
    Update-SessionEnvironment

    $chocoBinRoot = 'chocolatey_bin_root'

    # Remove variable if not empty
    #
    if (Test-Path Env:\$chocoBinRoot) {

        [Environment]::SetEnvironmentVariable($chocoBinRoot, $Null, 'User')
        Remove-Item Env:\$chocoBinRoot

        Write-Host "Removed environment variable `'$chocoBinRoot`'"
    }

    Write-ChocolateySuccess "$pkgName"
}
catch
{
    Write-ChocolateyFailure "$pkgName" "$($_.Exception.Message)"
    throw
}



