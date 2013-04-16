$packageName = "Devbox-Wget"
$installerType = "exe"
$url = "http://downloads.sourceforge.net/gnuwin32/wget-1.11.4-1-setup.exe"
$url64 = $url
$validExitCodes = @(0)

Update-SessionEnvironment

# Exit if software is already installed, except if forced
Stop-OnAppIsInstalled -pkg $packageName -match "GnuWin32: Wget" -force $force

try {

    $installPath = Join-Path $Env:ProgramFiles "Tools"
    $silentArgs = "/silent /dir=`"$installPath`" /noicons /components=`"bin`" /tasks=`"`""

    # Install package. It won't add itself to the PATH
    Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" "$url64" -validExitCodes $validExitCodes

    # Generate shortcut
    $exe = Find-FileInPath "wget.exe" "$(Join-Path "$installPath" "bin")"
    if ($exe) {
        Generate-BinFile "wget" "$exe"
    }

    # Success
    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}




