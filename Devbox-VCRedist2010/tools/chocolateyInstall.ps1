$packageName = "Devbox-VCRedist2010"
$installerType = "exe"
$url32 = "http://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe"
$url64 = "http://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe"
$silentArgs = "/Q"
$validExitCodes = @(0)

# Latest Supported Visual C++ Downloads:
#   http://support.microsoft.com/kb/2019667
#
# Detect whether I need to install VCRedist?
#   http://stackoverflow.com/a/8552775/1579985
#

Update-SessionEnvironment

try {

    # Detect x86-x64 operating system - not processor type:
    # http://blogs.msdn.com/b/david.wang/archive/2006/03/26/howto-detect-process-bitness.aspx
    #
    $x64 = $false
    if ($ENV:Processor_Architecture -eq "AMD64" -or ($ENV:Processor_Architecture -eq "x86" -and (Test-Path env:\PROCESSOR_ARCHITEW6432)))
    {
        # 64-bit operating system or 32-bit process on a 64-bit OS
        $x64 = $true
    }

    # Always install 32-bit package and 64-bit only on x64
    Install-ChocolateyPackage "${packageName}_x86" "$installerType" "$silentArgs" "$url32" "$url32" -validExitCodes $validExitCodes

    if ($x64) {
        Install-ChocolateyPackage "${packageName}_x64" "$installerType" "$silentArgs" "$url64" "$url64" -validExitCodes $validExitCodes
    }

    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}
