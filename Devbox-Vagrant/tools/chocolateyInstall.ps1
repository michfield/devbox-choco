$packageName = "Devbox-Vagrant"
$installerType = "msi"
$url = "http://files.vagrantup.com/packages/7e400d00a3c5a0fdf2809c8b5001a035415a607b/Vagrant_1.2.2.msi"
$url64 = $url
$validExitCodes = @(0)

Update-SessionEnvironment

# Exit if software is already installed, except if forced
#
Stop-OnAppIsInstalled -pkg $packageName -match "Vagrant" -force $force

try {

    $installPath = join-path $(Get-RootPath) "Vagrant"
    $silentArgs = "/passive VAGRANTAPPDIR=`"$installPath`""

    # Install package.
    # Vagrant should add itself to the PATH
    #
    Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" "$url64"  -validExitCodes $validExitCodes

    # Vagrant will restart system so nothing in here will be executed

    # Success
    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}
