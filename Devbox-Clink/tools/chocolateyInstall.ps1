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

    # Auto-run system supported - see Devbox-Common package
    $srcDir = $(Get-Item $(Split-Path -parent $MyInvocation.MyCommand.Definition)).parent.FullName | Join-Path -ChildPath "bin"
    foreach ($fn in @("bashrc.include.clink.bat"))
    {
        Copy-Item $(Join-Path $srcDir "$fn" ) $(Join-Path $Env:UserProfile ".$fn" ) -Force
    }

    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}
