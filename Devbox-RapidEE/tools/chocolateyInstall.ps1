$packageName = "Devbox-RapidEE"
$installerType = "exe"
$url = "http://www.rapidee.com/download/RapidEE_setup.exe"
$url64 = $url
$validExitCodes = @(0)

Update-SessionEnvironment

# Exit if software is already installed, except if forced
Stop-OnAppIsInstalled -pkg $packageName -match "Rapid Environment Editor" -force $force

try {

    # Nullsoft Scriptable Install System
    #
    # /D sets the default installation directory. It must be the last
    # parameter used in line and must not contain quotes, even if the
    # path contains spaces. Only absolute paths are supported.
    #
    # But, this installer is ignoring that switch. So, it will install
    # a software in default x64 path - `Program Files (x86)`. Maybe in
    # the future the installer will work as expected.
    #
    $installPath = Join-Path $Env:ProgramFiles "Rapid Environment Editor"
    $silentArgs = "/S /D=$installPath"

    # Install package. It won't add itself to the PATH
    Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" "$url64" -validExitCodes $validExitCodes

    # Generate .bat shortcuts.
    # Due the bad installer, I have to search for an executable.
    #
    $dirs = Join-Path @("${env:ProgramFiles}","${env:ProgramFiles(x86)}") "Rapid Environment Editor"
    $exe = Find-FileInPath "rapidee.exe" $($dirs -join ";")

    if ($exe) {
        foreach ($alias in @("rapidee", "ree")) {
            Generate-BinFile "$alias" "$exe"
        }
    }

    # Success
    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}




