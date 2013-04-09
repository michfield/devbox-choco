#
# Query Installed Applications information
#
# Returns information about one or all installed packages that match
# naming pattern. Do it by analyzing registry, so it's not only showing
# Windows Instaler MSI packages.
#
# Usage:
#
#   QueryAppInfo -match "micro" -first $false
#
# Author:
#   Colovic Vladan, cvladan@gmail.com
#

function QueryAppInfo([string] $matchPattern = '', [bool] $firstOnly = $false)
{
    # Any error at this point should be terminating
    #
    $ErrorActionPreference = "Stop"

    # Array of hashes/ Using hash similar to an object to hold our
    # application information
    #
    $appArray = @()
    $app = @{}

    # This is the real magic of the script.  We use Get-ChildItem to
    # get all of the subkeys that contain application info.
    #
    $keys  = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall -Recurse
    $keys += Get-ChildItem HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall -Recurse

    # On 64-bit systems, get extra info from the Wow6432Node
    #
    if ((Get-WmiObject Win32_ComputerSystem).SystemType -like "x64*")
    {
        $keys += Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall -Recurse
        # $keys += Get-ChildItem HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall -Recurse
    }

    # Silently ignore errors
    # $ErrorActionPreference = "SilentlyContinue"

    # Build out each InstalledApplication object
    #
    foreach ($key in $keys)
    {
        # Only query data for apps with a name
        #
        if ($packageName = $key.GetValue("DisplayName"))
        {
            $packageName = $packageName.Trim()

            if (($packageName.Length -eq 0) -or ($matchPattern -and ($packageName -notmatch $matchPattern)))
            {
                # Move on if not match regular expression.
                # It's case-insensitive comparison.
                #
                continue
            }

            # Convert estimated size to megabytes
            #
            $tmpSize = '{0:N2}' -f ($key.GetValue("EstimatedSize") / 1MB)

            # Populate our object
            #
            $app["DisplayName"]            = $packageName                              # Name / InnoSetup: yes, MSI: yes
            $app["DisplayVersion"]         = $key.GetValue("DisplayVersion")
            $app["Publisher"]              = $key.GetValue("Publisher")                # Company / InnoSetup: yes, MSI: yes
            $app["InstallLocation"]        = $key.GetValue("InstallLocation")          # / InnoSetup: yes, MSI: sometimes empty
            $app["InstallDate"]            = $key.GetValue("InstallDate")              # yyyymmdd / InnoSetup: yes, MSI: yes
            $app["UninstallString"]        = $key.GetValue("UninstallString")          # / InnoSetup: yes, MSI: yes
            $app["QuietUninstallString"]   = $key.GetValue("QuietUninstallString")     # / InnoSetup: yes, MSI: no
            $app["EstimatedSizeMB"]        = $tmpSize                                  # / InnoSetup: yes, MSI: yes

            $app["RegistryPath"]           = $key.name
            $app["RegistryKeyName"]        = $key.pschildname

            # If it has keys that start with `Inno Setup:`, like `Inno
            # Setup: App Path` or `Inno Setup: Selected Tasks`, then we have
            # a lot of extra information and know the installer
            #
            # Inno Setup almost always has `QuietUninstallString` set, which
            # is usually normal one appended with ` /SILENT`. And
            # you can discover silent installation arguments by analyzing
            # keys with `Tasks` and `Components`

            # MSI
            # [Uninstall Registry Key](http://msdn.microsoft.com/en-us/library/windows/desktop/aa372105(v=vs.85).aspx)

            $appArray += $app

            if ($matchPattern -and $firstOnly)
            {
                # If pattern was defined and we want only the first
                # result, it means we found out first app. I think we
                # can exit now - I don't need multiple list for that.

                break
            }
        }
    }

    # Reset error action preference
    $ErrorActionPreference = "Continue"

    return $appArray
}

#
# Throws a fatal error if a software with the same name pattern has been
# found already installed. Used in install scripts, as a first check.
# Returns nothing. Just breaks script execution, if needed.
#
# Usage:
#
#   FailOnAlreadyInstalledSoftware $packageName, "Oracle VM VirtualBox"
#
function FailOnAlreadyInstalledSoftware([string] $pkgName, [string] $pattern)
{
  # If set `-force` option on installation, query nothing - just
  # continue with installation procedure
  #
  if ($force -eq $false) {
    return
  }

  $arrMatch = QueryAppInfo($pattern)
  $arrMatch = [array] $arrMatch

  if ($arrMatch.Length -gt 0) {

    $appInfo = $arrMatch[0]
    $softwareName=$appInfo["DisplayName"]
    $cmdUninstall=$appInfo["UninstallString"]

    Write-Host ""
    Write-Host "$softwareName version $($appInfo["DisplayVersion"]) is already installed." -foregroundcolor yellow

    if ($arrMatch.Length -gt 1) {
      Write-Host ""
      Write-Host "CAUTION:" -foregroundcolor red
      Write-Host "  I found multiple installed software with `'$pattern`' in its name." -foregroundcolor red
      Write-Host "  So software is installed, only multiple times. And that can be a problem." -foregroundcolor red
    }

    Write-Host ""
    Write-Host "Looks like `'$softwareName`' is installed separately by another Chocolatey package or not " -nonewline
    Write-Host "using Chocolatey at all. Please uninstall `'$softwareName`' by removing that " -nonewline
    Write-Host "other package or more often - you must uninstall `'$softwareName`' using standard " -nonewline
    Write-Host "Windows uninstaller, the familiar `'Add/Remove Programs`' procedure."
    Write-Host ""
    Write-Host "If you decided to use standard Windows uninstall procedure, I'm trying to help you by " -nonewline
    Write-Host "detecting a valid removal command. Here it is for you to try:"
    Write-Host ""
    Write-Host "$cmdUninstall" -foregroundcolor yellow
    Write-Host ""
    Write-Host "If you think that some other Chocolatey package installed `'$softwareName`', you can try " -nonewline -foregroundcolor darkgray
    Write-Host "to analyze installed Chocolatey packages. However, be aware that most of current Chocolatey " -nonewline -foregroundcolor darkgray
    Write-Host "packages don't provide you with a way to do uninstall." -foregroundcolor darkgray
    Write-Host ""
    Write-Host "» Find package containing `'$pattern`' in a name:" -foregroundcolor darkgray
    Write-Host "  clist $pattern"
    Write-Host "» Check if found Chocolatey package is currently installed:" -foregroundcolor darkgray
    Write-Host "  cver pkgname -lo"
    Write-Host "» If package is installed, uninstall it by typing:" -foregroundcolor darkgray
    Write-Host "  cuninst pkgname"
    Write-Host ""

    Write-ChocolateyFailure "$pkgName" "Already installed"
    throw
  }
}