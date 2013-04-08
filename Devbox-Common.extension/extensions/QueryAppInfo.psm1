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

            # Convert the date from yyyymmdd to system format (to display)
            #
            if ($tmpDate = $key.GetValue("InstallDate"))
            {
                $tmpDate = $tmpDate.SubString(4,2) + "/" + $tmpDate.SubString(6,2) + "/" + $tmpDate.SubString(0,4)
            }

            # [ref]$ParsedInstallDate = Get-Date
            # If ([DateTime]::TryParseExact($SubKey.GetValue("InstallDate"),"yyyyMMdd",$Null,[System.Globalization.DateTimeStyles]::None,$ParsedInstallDate)){
            # $Entry.InstallDate = $ParsedInstallDate.Value
            # }

            # Convert estimated size to megabytes
            #
            $tmpSize = '{0:N2}' -f ($key.GetValue("EstimatedSize") / 1MB)

            # Populate our object
            #
            $app["DisplayName"]            = $packageName                              # Name / InnoSetup: yes, MSI: yes
            $app["DisplayVersion"]         = $key.GetValue("DisplayVersion")
            $app["Publisher"]              = $key.GetValue("Publisher")                # Company / InnoSetup: yes, MSI: yes
            $app["InstallLocation"]        = $key.GetValue("InstallLocation")          # / InnoSetup: yes, MSI: sometimes empty
            $app["InstallDate"]            = $tmpDate                                  # yyyymmdd / InnoSetup: yes, MSI: yes
            $app["UninstallString"]        = $key.GetValue("UninstallString")          # / InnoSetup: yes, MSI: yes
            $app["QuietUninstallString"]   = $key.GetValue("QuietUninstallString")     # / InnoSetup: yes, MSI: no
            $app["EstimatedSizeMB"]        = $tmpSize                                  # / InnoSetup: yes, MSI: yes

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