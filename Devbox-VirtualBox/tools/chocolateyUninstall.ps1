$pkgName = "Devbox-VirtualBox"
$appPattern = "Oracle VM VirtualBox"

# GUID's
#   v4.2.10 / {E28F112D-4784-4466-AE4B-07B3630C857F}

# Strange: full application name (Oracle VM VirtualBox 4.2.10) contains
# both the name and version. Maybe app is updated through normal way,
# by update, I will just look for name without version.

try
{
  # Uninstall any version of VirtualBox
  #
  $arrMatch = QueryAppInfo($appPattern)
  $arrMatch = [array] $arrMatch

  if ($arrMatch.Length -gt 0) {
    $appInfo = $arrMatch[0]

    $softwareName = $appInfo["DisplayName"]
    $cmdUninstall = $appInfo["UninstallString"]
    $appGUID      = $appInfo["RegistryKeyName"]

    Uninstall-ChocolateyPackage "$pkgName" "msi" "$appGUID" -validExitCodes @(0)
  }

  Write-ChocolateySuccess "$pkgName"
}
catch
{
  Write-ChocolateyFailure "$pkgName" "$($_.Exception.Message)"
  throw
}

