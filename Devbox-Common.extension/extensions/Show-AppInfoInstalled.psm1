#
# Query Installed Applications information
#
# Returns information about one or all installed packages that match
# naming pattern. Do it by analyzing registry, so it's not only showing
# Windows Instaler MSI packages.
#
# Usage:
#
#   Show-AppUninstallInfo -match "micro" -first $false
#
# Author:
#   Colovic Vladan, cvladan@gmail.com
#

function Show-AppUninstallInfo {
param(
    [string] $matchPattern = '',
    [string] $ignorePattern = '',
    [bool] $firstOnly = $false
)

    Write-Debug "Querying registry keys for uninstall pattern: $matchPattern"

    if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {

        # In reality, it's possible, but not worth it...
        # How to query 64 bit Registry with 32 bit PowerShell...
        #
        # http://www.zerosignal.co.uk/2011/12/64-bit-registry-32-bit-powershell/
        # http://stackoverflow.com/questions/10533421/accessing-64-bit-registry-from-32-bit-application
        # http://poshcode.org/2470
        # http://stackoverflow.com/a/8588982/1579985
        #
        Write-Host ""
        Write-Host "CAUTION:" -foregroundcolor red
        Write-Host "  You are running 32-bit process on a 64-bit operating system," -foregroundcolor red
        Write-Host "  and in this environment it's not possible to reliably detect" -foregroundcolor red
        Write-Host "  all installed applications." -foregroundcolor red
        Write-Host ""
    }

    # Any error at this point should be terminating
    #
    $ErrorActionPreference = "Stop"

    # Array of hashes/ Using hash similar to an object to hold our
    # application information
    #
    $appArray = @()

    # This is the real magic of the script. We use Get-ChildItem to
    # get all of the sub-keys that contain application info.
    # Here, we MUST silently ignore errors
    #
    $ErrorActionPreference = "SilentlyContinue"

    $keys  = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse
    $keys += Get-ChildItem "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse
    $keys += Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse
    $keys += Get-ChildItem "HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse

    # On 64-bit systems, we get very important extra list from the
    # Wow6432Node nodes. But now I'm skipping OS detection that we
    # used before, as it turned out that it's really not very reliable.

    # Build out hash for every matched application
    #
    foreach ($key in $keys)
    {
        # Adding a try-catch around the statement will hide the error and
        # prevent it being caught in the main try / catch. And we are
        # already silnetly continuing on errors
        #
        try { $pkgName = $key.GetValue("DisplayName") } catch {}

        # Only query data for apps with a name
        #
        if ($pkgName)
        {
            $pkgName = $pkgName.Trim()

            if (($pkgName.Length -eq 0) -or `
                ($matchPattern -and ($pkgName -notmatch $matchPattern)) -or `
                ($ignorePattern -and ($pkgName -match $ignorePattern)))
            {
                # Move on if not match regular expression.
                # It's case-insensitive comparison.
                #
                continue
            }

            Write-Debug "* $pkgName"

            # Ignore every error
            #
            try {

                # Convert estimated size to megabytes
                #
                $tmpSize = '{0:N2}' -f ($key.GetValue("EstimatedSize") / 1MB)

                # Populate our object
                # We must initialize object here, not outside loop
                #
                $app = @{}
                $app["DisplayName"]            = $pkgName                                  # Name / InnoSetup: yes, MSI: yes
                $app["DisplayVersion"]         = $key.GetValue("DisplayVersion")
                $app["Publisher"]              = $key.GetValue("Publisher")                # Company / InnoSetup: yes, MSI: yes
                $app["InstallLocation"]        = $key.GetValue("InstallLocation")          # / InnoSetup: yes, MSI: sometimes empty
                $app["InstallDate"]            = $key.GetValue("InstallDate")              # yyyymmdd / InnoSetup: yes, MSI: yes
                $app["UninstallString"]        = $key.GetValue("UninstallString")          # / InnoSetup: yes, MSI: yes
                $app["QuietUninstallString"]   = $key.GetValue("QuietUninstallString")     # / InnoSetup: yes, MSI: no
                $app["EstimatedSizeMB"]        = $tmpSize                                  # / InnoSetup: yes, MSI: yes

            } catch {}

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
            #
            # Uninstall Registry Key for MSI installer:
            # http://msdn.microsoft.com/en-us/library/windows/desktop/aa372105(v=vs.85).aspx

            $appArray += $app

            if ($matchPattern -and $firstOnly)
            {
                # If pattern was defined and we want only the first
                # result, it means we found our first app. I think we
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
# Throws an error if a software with the same name pattern has been
# found already installed. Used in install scripts, as a first check.
# Returns nothing. Just breaks script execution, if needed.
#
# Usage:
#   Stop-OnAppIsInstalled $pkgName "Oracle VM VirtualBox"
#
function Stop-OnAppIsInstalled {
param(
    [string] $pkgName,
    [string] $match,
    [string] $ignore,
    [bool] $force = $false
)

    # If set `-force` option on installation, query nothing - just
    # continue with installation procedure, because it's forced
    #
    if ($force -eq $true) {
        Write-Debug "Force command line option specified - NOT looking for: $match"
        return
    }

    $arrMatch = Show-AppUninstallInfo -match $match -ignore $ignore
    $arrMatch = [array] $arrMatch

    if ($arrMatch.Length -gt 0) {

        $appInfo = $arrMatch[0]

        $softwareName=$appInfo["DisplayName"]
        $softwareVers=$appInfo["DisplayVersion"]
        $cmdUninstall=$appInfo["UninstallString"]

        Write-Host ""
        Write-Host "$softwareName version $softwareVers is already installed." -foregroundcolor yellow

        if ($arrMatch.Length -gt 1) {
            Write-Host ""
            Write-Host "CAUTION:" -foregroundcolor red
            Write-Host "  I found multiple installed software with `'$match`' in its name." -foregroundcolor red
            Write-Host "  So software is installed - multiple times - and that can be a problem." -foregroundcolor red
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
        Write-Host "* Find package containing `'$match`' in a name:" -foregroundcolor darkgray
        Write-Host "  clist $match"
        Write-Host "* Check if found Chocolatey package is currently installed:" -foregroundcolor darkgray
        Write-Host "  cver pkgname -lo"
        Write-Host "* If package is installed, uninstall it by typing:" -foregroundcolor darkgray
        Write-Host "  cuninst pkgname"
        Write-Host ""
        Write-Host "Also, you can execute preffered Chocolatey method, that will trigger silent uninstallation:"
        Write-Host ""
        Write-Host "cuninst $pkgName"  -foregroundcolor yellow
        Write-Host ""

        Write-ChocolateySuccess "$pkgName" "$softwareName is already installed, version $softwareVers. Please remove it."
        Exit
    }
}