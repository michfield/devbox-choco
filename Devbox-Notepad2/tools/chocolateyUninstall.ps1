$pkg = "Devbox-Notepad2"

# Refresh environment from registry
Update-SessionEnvironment

# Find any version
$apps = @(Show-AppUninstallInfo -match "Notepad2")

try
{
    if ($apps.Length -gt 0)
    {
        $app = $apps[0]

        Write-Host "`nUninstalling $($app["DisplayName"]) version $($app["DisplayVersion"])...`n" -foregroundcolor yellow

        # Uninstall string is very complicated but working.
        #
        Start-ChocolateyProcessAsAdmin "/c $($app["UninstallString"])" -exe "$env:comspec" -minimized
    }

    Write-ChocolateySuccess "$pkg"
}
catch
{
    Write-ChocolateyFailure "$pkg" "$($_.Exception.Message)"
    throw
}
