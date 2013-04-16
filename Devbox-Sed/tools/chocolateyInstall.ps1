$packageName = "Devbox-Sed"
$installerType = "exe"
$url = "http://gnuwin32.sourceforge.net/downlinks/sed.php"
$url64 = $url
$validExitCodes = @(0)

Update-SessionEnvironment

# Exit if software is already installed, except if forced
Stop-OnAppIsInstalled -pkg $packageName -match "GnuWin32: Sed" -force $force

try {

    $installPath = Join-Path $Env:ProgramFiles "Tools"
    $silentArgs = "/silent /dir=`"$installPath`" /noicons /components=`"bin`" /tasks=`"`""

    # Install package. It won't add itself to the PATH
    Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" "$url64" -validExitCodes $validExitCodes

    # Generate shortcut
    $exe = Find-FileInPath "sed.exe" "$(Join-Path "$installPath" "bin")"
    if ($exe) {
        Generate-BinFile "sed" "$exe"
    }

    # Success
    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}




