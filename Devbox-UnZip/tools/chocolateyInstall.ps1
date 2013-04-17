$packageName = "Devbox-UnZip"
$installerType = "exe"
$url = "http://gnuwin32.sourceforge.net/downlinks/unzip.php"
$url64 = $url
$validExitCodes = @(0)

Update-SessionEnvironment

# Exit if software is already installed, except if forced
Stop-OnAppIsInstalled -pkg $packageName -match "GnuWin32: UnZip" -force $force

try {

    $installPath = Join-Path $Env:ProgramFiles "Tools"
    $silentArgs = "/silent /dir=`"$installPath`" /noicons /components=`"bin`" /tasks=`"`""

    # Install package. It won't add itself to the PATH
    Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" "$url64" -validExitCodes $validExitCodes

    # Generate shortcut. There are a lot of executables, but I'll be
    # making a shortcut for only one, unzip.exe. Other executables are:
    # funzip.exe, unzipsfx.exe, uzexampl.exe, zipinfo.exe
    #
    $exe = Find-FileInPath "unzip.exe" "$(Join-Path "$installPath" "bin")"
    if ($exe) {
        Generate-BinFile "unzip" "$exe"
    }

    # Success
    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}




