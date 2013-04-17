$packageName = "Devbox-Vagrant"

Update-SessionEnvironment

# Uninstall any version of Vagrant
#
$arrMatch = Show-AppUninstallInfo -match "Vagrant"

try
{
    $arrMatch = [array] $arrMatch
    if ($arrMatch.Length -gt 0) {

        $appInfo = $arrMatch[0]
        $softwareName = $appInfo["DisplayName"]
        $cmdUninstall = $appInfo["UninstallString"]
        $appGUID      = $appInfo["RegistryKeyName"]

        Write-Host "`nUninstalling $softwareName version $($appInfo["DisplayVersion"])...`n" -foregroundcolor yellow

        # Silent uninstall
        #
        Uninstall-ChocolateyPackage "$packageName" "msi" "$appGUID" -validExitCodes @(0)
    }

    Write-ChocolateySuccess "$packageName"
}
catch
{
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}

