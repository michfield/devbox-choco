$packageName = "Devbox-Clink"
$installerType = "exe"
$url = "https://clink.googlecode.com/files/clink_0.3.1_setup.exe"
$url64 = $url
$silentArgs = "/S"
$validExitCodes = @(0)

Update-SessionEnvironment

# Exit if software is already installed, except if forced
Stop-OnAppIsInstalled -pkg $packageName -match "clink" -force $force

try {
    Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" "$url64" -validExitCodes $validExitCodes
    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}
