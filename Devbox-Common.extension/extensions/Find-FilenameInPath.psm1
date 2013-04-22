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
function Show-FilesInPath {
param(
    [string] $fileName,
    [string] $multiPath
)
    $multiPath.Split(';')  | Select-Object -unique | ?{!([System.String]::IsNullOrEmpty($_))} | %{
        if (Test-Path $_) {
            ls $_ | ?{ $_.Name -like $fileName } | Select-Object -ExpandProperty Fullname
        }
    }
}

# Returns only the first file found
#
function Find-FileInPath {
param(
    [string] $fileName,
    [string] $multiPath
)
    Show-FilesInPath "$fileName" "$multiPath" | Select -first 1
}

# Searches for paths that are part of PATH variable, and returns full
# file-path of a found file specified by wildcard or empty if none has
# been found.
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


