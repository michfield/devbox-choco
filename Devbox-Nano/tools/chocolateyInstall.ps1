$packageName = "Devbox-Nano"
$url = "http://www.nano-editor.org/dist/v2.2/NT/nano-2.2.6.zip"

Update-SessionEnvironment

try {

    # Install Zip package. Automatic shortcuts will NOT be created.
    #
    $installPath = Join-Path "$(Get-RootPath)" "Nano"
    Install-ChocolateyZipPackage "$packageName" "$url" "$installPath"

    # Generate shortcut
    if ($exe = Find-FileInPath "nano.exe" "$installPath") {
        Generate-BinFile "nano" "$exe"
    }

    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}
