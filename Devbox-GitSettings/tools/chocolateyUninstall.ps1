$pkg = "Devbox-GitSettings"

try
{
    Write-Host ""
    Write-Host "This package didn't overwrite any Git property that had any value. Therefore, there is really nothing to uninstall. This uninstall could just unset all Git settings that have been changed, but we decided to leave that up to you."
    Write-Host ""
    Write-Host "We suggest you to manually edit .gitconfig and remove obsolete values. Likewise, you can completely reset your Git configuration by simply deleting .gitconfig file."
    Write-Host ""
    Write-Host "Location of .gitconfig file: " -nonewline
    Write-Host "$ENV:USERPROFILE\.gitconfig"  -foregroundcolor yellow
    Write-Host ""
    Write-ChocolateySuccess "$pkg"
}
catch
{
    Write-ChocolateyFailure "$pkg" "$($_.Exception.Message)"
    throw
}
