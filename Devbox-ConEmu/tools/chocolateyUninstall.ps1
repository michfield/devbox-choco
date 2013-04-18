$pkg = "Devbox-ConEmu"

# Refresh environment from registry
Update-SessionEnvironment

# Find any version
$apps = @(Show-AppUninstallInfo -match "ConEmu")

try
{
    if ($apps.Length -gt 0)
    {
        $app = $apps[0]

        Write-Host "`nUninstalling $($app["DisplayName"]) version $($app["DisplayVersion"])...`n" -foregroundcolor yellow

        # Standard MSI uninstall by GUID
        Uninstall-ChocolateyPackage "$pkg" "msi" $app["RegistryKeyName"] -validExitCodes @(0)
    }

    Write-ChocolateySuccess "$pkg"
}
catch
{
    Write-ChocolateyFailure "$pkg" "$($_.Exception.Message)"
    throw
}
