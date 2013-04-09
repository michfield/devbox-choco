$packageName = 'Devbox-VirtualBox' # filename-safe value
$installerType = 'exe'
$url = 'http://download.virtualbox.org/virtualbox/4.2.10/VirtualBox-4.2.10-84105-Win.exe'
$url64 = $url
$silentArgs = '-s'
$validExitCodes = @(0)

# Stop if software is already installed
FailOnAlreadyInstalledSoftware($packageName, "Oracle VM VirtualBox")

$absToolsDir="$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

try {

  # We must import the certificates before installing package itself to
  # avoid interactive prompt. Source: http://wpkg.org/Sun_xVM_VirtualBox
  #
  Start-ChocolateyProcessAsAdmin "certutil -addstore 'TrustedPublisher' '$absToolsDir\oracle.cer'" -validExitCodes $validExitCodes

  # Install package
  #
  Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" "$url64"  -validExitCodes $validExitCodes

  # VirtualBox will set VBOX_INSTALL_PATH environment variable.
  # Sometimes, it can contain multiple paths, as a leftover of old
  # installations and updates. These multiple paths are properly
  # seperated with semicolon, so it's safe simply all to append to a
  # path.
  #
  # Source: https://github.com/mitchellh/vagrant/issues/885
  #
  Update-SessionEnvironment
  $varValue = Get-Item Env:VBOX_INSTALL_PATH -ErrorAction SilentlyContinue | Select -ExpandProperty Value -First 1
  Write-Host "Environment variable is set: VBOX_INSTALL_PATH = $varValue"

  Install-ChocolateyPath $varValue
  Write-Host "And also appended to the users PATH variable."

  # Success
  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw
}
