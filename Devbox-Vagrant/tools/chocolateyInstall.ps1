$packageName = "Devbox-Vagrant"
$installerType = "msi"
$url = "http://files.vagrantup.com/packages/a7853fe7b7f08dbedbc934eb9230d33be6bf746f/Vagrant_1.2.1.msi"
$url64 = $url
$validExitCodes = @(0)

Update-SessionEnvironment

# Exit if software is already installed, except if forced
#
Stop-OnAppIsInstalled -pkg $packageName -match "Vagrant" -force $force

try {

    $installPath = join-path $(Get-RootPath) "Vagrant"
    $silentArgs = "/passive INSTALLDIR=`"$installPath`""

    # Install package.
    # Vagrant should add itself to the PATH
    #
    Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" "$url64"  -validExitCodes $validExitCodes

    # Success
    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}
