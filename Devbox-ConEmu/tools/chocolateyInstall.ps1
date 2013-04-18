$pkg = "Devbox-ConEmu"

# Refresh environment from registry
Update-SessionEnvironment

# Installed already?
Stop-OnAppIsInstalled -pkg $pkg -match "ConEmu" -force $force

try {

    # If having problems with untrusted cetrificates on HTTPS, use
    # solution: http://stackoverflow.com/a/561242/1579985
    #
    $html = (New-Object Net.WebClient).DownloadString("https://code.google.com/p/conemu-maximus5/downloads/list")
    $regexp = "<a href=`"//conemu-maximus5.googlecode.com/files/ConEmuSetup\.([0-9]+)\.exe`" onclick=`""

    if ($html -notmatch $regexp)
    {
        throw "Could not detect latest application version to download"
    }

    $url = "https://conemu-maximus5.googlecode.com/files/ConEmuSetup.$($matches[1]).exe"

    # Detect OS
    $os = if ($ENV:Processor_Architecture -eq "AMD64" -or ($ENV:Processor_Architecture -eq "x86" -and (Test-Path env:\PROCESSOR_ARCHITEW6432))) { "x64" } else { "x86" }

    # MSI installer, but packed inside wrapper to select x86 or x64
    # version. Therefore, treat it as EXE type.
    #
    Install-ChocolateyPackage "$pkg" "exe" "/p:$os /passive" "$url" -validExitCodes @(0)
    Write-ChocolateySuccess "$pkg"
}
catch
{
    Write-ChocolateyFailure "$pkg" "$($_.Exception.Message)"
    throw
}
