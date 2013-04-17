$packageName = "Devbox-VCRedist2010"

Update-SessionEnvironment

# Search for both x86 and x64 versions
$arrMatch = Show-AppUninstallInfo -match "Microsoft Visual C\+\+ 2010\s+(x86|x64) Redistributable"

try
{
    $arrMatch = [array] $arrMatch

    if ($arrMatch.Length -gt 0) {
        foreach ($appInfo in $arrMatch)
        {
            $softwareName = $appInfo["DisplayName"]
            $cmdUninstall = $appInfo["UninstallString"]
            $appGUID      = $appInfo["RegistryKeyName"]

            Write-Host "`nUninstalling $softwareName version $($appInfo["DisplayVersion"])...`n" -foregroundcolor yellow
            Uninstall-ChocolateyPackage "$packageName" "msi" "$appGUID" -validExitCodes @(0)
        }
    }

    Write-ChocolateySuccess "$packageName"
}
catch
{
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}

