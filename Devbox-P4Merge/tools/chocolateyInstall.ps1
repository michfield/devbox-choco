$pkg = "Devbox-P4Merge"
$url32 = "http://www.perforce.com/downloads/perforce/r13.1/bin.ntx86/p4vinst.exe"
$url64 = "http://www.perforce.com/downloads/perforce/r13.1/bin.ntx64/p4vinst64.exe"

# Refresh environment from registry
Update-SessionEnvironment

# Installed already?
Stop-OnAppIsInstalled -pkg "$pkg" -match "Perforce Visual Components" -force $force

try {

    # Using InstallShield with MSI inside. You can see basic
    # InstallShield parameters by typing `p4vinst.exe /?`.
    #
    # In short, you can pass parameters to the underlying MSI by using
    # switch /V, like this:
    #   p4vinst.exe /v"/qn ADDLOCAL=P4MERGE"
    #
    Install-ChocolateyPackage "$pkg" "exe" "/v`"/qn ADDLOCAL=P4MERGE`"" "$url32" "$url64" -validExitCodes @(0)
    Write-ChocolateySuccess "$pkg"
}
catch
{
    Write-ChocolateyFailure "$pkg" "$($_.Exception.Message)"
    throw
}



