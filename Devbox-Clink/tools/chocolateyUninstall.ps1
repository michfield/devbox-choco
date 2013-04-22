$packageName = "Devbox-Clink"

Update-SessionEnvironment

# Search for any version
$arrMatch = Show-AppUninstallInfo -match "clink"

try
{
    $arrMatch = [array] $arrMatch
    if ($arrMatch.Length -gt 0) {

        $appInfo = $arrMatch[0]
        $softwareName = $appInfo["DisplayName"]
        $uninstallExe = $appInfo["UninstallString"]
        $appGUID      = $appInfo["RegistryKeyName"]

        Write-Host "`nUninstalling $softwareName version $($appInfo["DisplayVersion"])...`n" -foregroundcolor yellow

        # Silent uninstall. Variable from registry is just a path to an
        # uninstaller, without any switches.
        #
        Uninstall-ChocolateyPackage -package "$packageName" -silent "/S" -file "$uninstallExe" -validExitCodes @(0)

        # Delete leftover from auto-run system - see Devbox-Common
        foreach ($fn in @(".bashrc.include.clink.bat"))
        {
            $bat = Join-Path $env:UserProfile $fn
            if (Test-Path "$bat") { Remove-Item "$bat" -ErrorAction SilentlyContinue }
        }
    }

    Write-ChocolateySuccess "$packageName"
}
catch
{
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}



