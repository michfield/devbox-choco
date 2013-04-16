$packageName = "Devbox-Nano"

Update-SessionEnvironment

try
{
    # Delete complete install directory, only if it contanins nano.exe
    #
    $installPath = Join-Path "$(Get-RootPath)" "Nano"
    $exe = Join-Path "$installPath" "nano.exe"
    if (Test-Path "$exe") {
        Remove-Item $installPath -Force -Recurse -ErrorAction SilentlyContinue
    }

    # Remove shortcut
    $bat = Join-Path $Env:ChocolateyInstall "bin\nano.bat"
    if (Test-Path "$bat") {
        Remove-Item "$bat" -ErrorAction SilentlyContinue
    }

    Write-ChocolateySuccess "$packageName"
}
catch
{
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}



