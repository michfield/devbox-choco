#
# Returns the BinRoot value
#
# Set a custom installation path. Some packages use the
# chocolatey_bin_root environment variable. If this variable does not
# exist, the packages will be installed directly under the system root
# (ex. C:\ruby193). To change this behaviour, you can set chocolatey_bin_root
# to an existing subfolder of your system partition (leaving out the drive letter).
# Packages that use the environment variable, will then be installed in
# the given subfolder, ex. C:\ChocoPackages\ruby193
#
# Usage:
#   Get-RootPath
#
# Author:
#   Colovic Vladan, cvladan@gmail.com
#

function Get-RootPath {

    # Calculate $binPath, which should be set in $env:chocolatey_bin_root
    # as a full, not relative path.
    #
    # My chocolatey_bin_root is C:\Common\bin, but looking at other
    # packages, not everyone assumes chocolatey_bin_root is prefixed
    # with a drive letter.
    #
    if ($env:chocolatey_bin_root -eq $null) {
        $binPath = join-path $env:systemdrive "\"
    }
    elseIf (-not ($env:chocolatey_bin_root -imatch "^\w:")) {
        # Add drive letter
        $binPath = join-path $env:systemdrive $env:chocolatey_bin_root
    }
    else {
        $binPath = $env:chocolatey_bin_root
    }

    return $binPath
}
