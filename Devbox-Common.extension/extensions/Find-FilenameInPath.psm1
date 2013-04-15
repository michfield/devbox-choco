#
# Checks if filename is somewhere in a PATH environment variable paths
#
# Usage:
#   Find-FileInPath "vbox*.*"
#
# Author:
#   Colovic Vladan, cvladan@gmail.com
#

# Searches for paths that are part of PATH variable, and returns full
# file-path of a found file specified by wildcard or empty if none has
# been found.
#
# Returns an object, with fields: .FullName, .Name, .Directory
#
function Find-FilenameInPath {
param(
    [string] $fileName
)
    Write-Debug "Running 'Find-FileInPath' with wild-card filename:`'$fileName`'"

    $env:PATH.Split(';') | ?{!([System.String]::IsNullOrEmpty($_))} | %{
        if(Test-Path $_) {
            ls $_ | ?{ $_.Name -like $fileName } | Select Fullname
        }
    }
}

function Test-FilenameInPath {
param(
    [string] $fileName
)
    $isFound = $false
    Find-FilenameInPath $fileName | %{$isFound = $true}
    return $isFound
}


