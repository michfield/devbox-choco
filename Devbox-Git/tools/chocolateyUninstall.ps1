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

    # Removing TERM environment variable is not critical - maybe it's
    # even useful for other apps, so I will just leave it hanging in
    # environment

    # Leftover from auto-run system - see Devbox-Common
    foreach ($fn in @(".bashrc.include.aliases-ls.bat",".bashrc.include.aliases-git.bat"))
    {
        $bat = Join-Path $env:UserProfile $fn
        if (Test-Path "$bat") { Remove-Item "$bat" -ErrorAction SilentlyContinue }
    }

    Write-ChocolateySuccess "$pkg"
}
catch
{
    Write-ChocolateyFailure "$pkg" "$($_.Exception.Message)"
    throw
}
