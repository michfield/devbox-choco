$pkg = "Devbox-Notepad2"
$url32 = 'http://www.flos-freeware.ch/zip/Notepad2_4.2.25_x86.exe'
$url64 = 'http://www.flos-freeware.ch/zip/Notepad2_4.2.25_x64.exe'

# Refresh environment from registry
Update-SessionEnvironment

# Installed already?
Stop-OnAppIsInstalled -pkg "$pkg" -match "Notepad2" -force $force

try {

    Install-ChocolateyPackage "$pkg" "exe" "/silent" "$url32" "$url64" -validExitCodes @(0)
    Write-ChocolateySuccess "$pkg"
}
catch
{
    Write-ChocolateyFailure "$pkg" "$($_.Exception.Message)"
    throw
}



