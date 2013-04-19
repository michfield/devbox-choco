$pkg = "Devbox-Git"

# Refresh environment from registry
Update-SessionEnvironment

# Find any version
$apps = @(Show-AppUninstallInfo -match "Git version [0-9\.]+-preview\d*")

try
{
    if ($apps.Length -gt 0)
    {
        $app = $apps[0]
        $gitDir = $app["InstallLocation"]

        Write-Host "`nUninstalling $($app["DisplayName"]) version $($app["DisplayVersion"])...`n" -foregroundcolor yellow

        # Silent EXE uninstall
        Uninstall-ChocolateyPackage -package "$pkg" -silent "/SILENT" -file "$($app["UninstallString"])" -validExitCodes @(0)

        # We will cleanup PATH - remove Git subdirectories. The only
        # good way to do it is to check and remove non-existent
        # directories. So, first check to be sure directories don't
        # exist anymore, and then remove from PATH.
        #
        if (-not (Test-Path "$gitDir"))
        {
            Remove-Path $(Join-Path "$gitDir" "bin")
            Remove-Path $(Join-Path "$gitDir" "cmd")
        }
    }

    Write-ChocolateySuccess "$pkg"
}
catch
{
    Write-ChocolateyFailure "$pkg" "$($_.Exception.Message)"
    throw
}
