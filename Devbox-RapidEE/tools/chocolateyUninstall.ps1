$packageName = "Devbox-RapidEE"

Update-SessionEnvironment

# Search for any version
$arrMatch = Show-AppUninstallInfo -match "Rapid Environment Editor"

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
    }

    # Delete any existing batch files from an earlier install,
    # and ignore errors.
    #
    $binPath = Join-Path $Env:ChocolateyInstall "bin"
    foreach ($alias in @("rapidee", "ree")) {
        $bat = Join-Path $binPath "$alias.bat"
        if (Test-Path "$bat") {
            Remove-Item "$bat" -ErrorAction SilentlyContinue
        }
    }

    Write-ChocolateySuccess "$packageName"
}
catch
{
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}



