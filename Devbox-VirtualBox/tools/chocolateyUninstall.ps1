# Reasoning explained:
#
#   If I have this Choco package, I will assume that VirtualBox has been
#   installed with it. I can't just check for GUID because there is a
#   possibility that user updated VirtualBox manually. I could also
#   check version of installed application, and remove it only if
#   it's after this one - but I won't do version check.
#
# Here is the logic:
#   If we have this package, let's assume we installed VirtualBox with
#   it, so, regardless of a version, remove any VirtualBox that you
#   find on this machine.

$packageName = "Devbox-VirtualBox"

# Note: Strangely, full application name in registry contains
# both the name and version (Oracle VM VirtualBox 4.2.12).
#
# GUID list:
#   * v4.2.10 -> {E28F112D-4784-4466-AE4B-07B3630C857F}
#   * v4.2.12 -> {unknown}
#
#
# Also, we can find ut a lot of information from this registry key:
#     HKEY_LOCAL_MACHINE\SOFTWARE\Oracle\VirtualBox

# Uninstall any version of VirtualBox
# Note: must be outside catch block
#
$arrMatch = Show-AppUninstallInfo -match "Oracle VM VirtualBox" -ignore "Oracle VM VirtualBox Guest Additions"

try
{
    # Remember environment value, we will need it for cleanup
    #
    $varEnv = $Env:VBOX_INSTALL_PATH

    $arrMatch = [array] $arrMatch
    if ($arrMatch.Length -gt 0) {

        $appInfo = $arrMatch[0]
        $softwareName = $appInfo["DisplayName"]
        $cmdUninstall = $appInfo["UninstallString"]
        $appGUID      = $appInfo["RegistryKeyName"]

        Write-Host "`nUninstalling $softwareName version $($appInfo["DisplayVersion"])...`n" -foregroundcolor yellow

        # Silent uninstall:
        # msiexec.exe /qn /norestart /x{E28F112D-4784-4466-AE4B-07B3630C857F}
        #
        Uninstall-ChocolateyPackage "$packageName" "msi" "$appGUID" -validExitCodes @(0)
    }

    # Remove environment VBOX_INSTALL_PATH variable,
    # and remove it's value from PATH
    #
    Remove-EnvironmentVariable "VBOX_INSTALL_PATH"
    Remove-Path $varEnv

    Write-ChocolateySuccess "$packageName"
}
catch
{
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}

