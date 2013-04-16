#
# Remove part of a PATH environment variable
#
# Deletes part of a path from from User and Machine environment. It also
# cleans up PATH variable, removing trailing backslashes from its parts,
# removing duplicate entries, etc.
#
# Parameter, path to remove, can contain multiple values separated with
# semicolon.
#
# We could also remove entries in User environment that are already in
# Machine environment, but for now, we are not doing that.
#
# Usage:
#   Remove-Path "some\path\to"
#
# Author:
#   Colovic Vladan, cvladan@gmail.com
#

function Remove-Path {
param(
    [string] $path = ""
)
    Write-Debug "Running 'Remove-Path' with path to remove: `'$path`'"

    # Cleanup parameter
    #
    $listOfPathsToRemove = @()

    foreach ($item in $path -split ";")
    {
        $item = $item.ToLower().Trim().TrimEnd("\")
        if ($item.Length -gt 0) {
            $listOfPathsToRemove += $item
        }
    }

    # Begin
    #
    $envTypes = @("Machine", "User")

    foreach ($scope in $envTypes)
    {
        $listOfPaths = @()
        $envPath = [Environment]::GetEnvironmentVariable("PATH", $scope)

        foreach ($item in $envPath -split ";")
        {
            $item = $item.Trim().TrimEnd("\")
            if ($item.Length -gt 0 -and $listOfPathsToRemove -notcontains $item.ToLower()) {
                $listOfPaths += $item
            }
        }

        # Remove duplicates and combine
        $cleanedPath = ($listOfPaths | select -uniq) -join ";"

        # We have changes
        if ($cleanedPath -ne $envPath) {

            if ($scope -eq "Machine") {
                $ps = "[Environment]::SetEnvironmentVariable('PATH', `'$cleanedPath`', 'Machine')"
                Start-ChocolateyProcessAsAdmin "$ps"
            }
            else {
                [Environment]::SetEnvironmentVariable('PATH', $cleanedPath, 'User')
            }
        }
    }
}

# Cleanup PATH variable.
# Don't check the real existence of PATH part on disk
#
function Set-PathCleanup {
    Remove-Path
}
