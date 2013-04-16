$packageName = "Devbox-Sed"

Update-SessionEnvironment

# Search for any version
$arrMatch = Show-AppUninstallInfo -match "GnuWin32: Sed"

try
{
    $arrMatch = [array] $arrMatch
    if ($arrMatch.Length -gt 0) {

        $appInfo = $arrMatch[0]
        $softwareName = $appInfo["DisplayName"]
        $uninstallExe = $appInfo["UninstallString"]
        $appGUID      = $appInfo["RegistryKeyName"]

        Write-Host "`nUninstalling $softwareName version $($appInfo["DisplayVersion"])...`n" -foregroundcolor yellow

        # Silent uninstall. We could use `QuietUninstallString` but no
        # need for that. Btw. it's Inno Setup.
        #
        Uninstall-ChocolateyPackage -package "$packageName" -silent "/SILENT" -file "$uninstallExe" -validExitCodes @(0)
    }

    # Delete any existing batch files from an earlier install,
    # and ignore errors.
    #
    $bat = Join-Path $Env:ChocolateyInstall "bin\sed.bat"
    if (Test-Path "$bat") {
        Remove-Item "$bat" -ErrorAction SilentlyContinue
    }

    Write-ChocolateySuccess "$packageName"
}
catch
{
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}



