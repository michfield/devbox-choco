#
# Checks if filename is somewhere in a PATH environment variable paths
#
# Usage:
#   Find-FileInEnvPath "vbox*.*"
#
# Author:
#   Colovic Vladan, cvladan@gmail.com
#

# multiPath is a list of paths, joined with semicolon
#
function Find-FileInPath {
param(
    [string] $fileName,
    [string] $multiPath
)
    $multiPath.Split(';') | ?{!([System.String]::IsNullOrEmpty($_))} | %{
        if (Test-Path $_) {
            ls $_ | ?{ $_.Name -like $fileName } | Select-Object -ExpandProperty Fullname -first 1
        }
    }
}

# Searches for paths that are part of PATH variable, and returns full
# file-path of a found file specified by wildcard or empty if none has
# been found.
#
# Returns an object, with fields: .FullName, .Name, .Directory
#
function Find-FileInEnvPath {
param(
    [string] $fileName
)
    Write-Debug "Running 'Find-FilenameInEnvPath' with wild-card filename:`'$fileName`'"
    Find-FileInPath "$fileName" "$env:PATH"
}

function Test-FileInEnvPath {
param(
    [string] $fileName
)
    $isFound = $false
    Find-FilenameInPath $fileName | %{ $isFound = $true }
    return $isFound
}


