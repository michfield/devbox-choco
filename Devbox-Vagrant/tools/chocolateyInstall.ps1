$packageName = "Devbox-Vagrant"
$installerType = "msi"
$url = "https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.1.msi"
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
