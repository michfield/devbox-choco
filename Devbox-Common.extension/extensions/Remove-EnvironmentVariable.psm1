#
# Remove Environment Variable
#
# Deletes environment variable from Session, User & Machine environment.
#
# Usage:
#   Remove-EnvironmentVariable "VARIABLE_NAME"
#
# Author:
#   Colovic Vladan, cvladan@gmail.com
#

function Remove-EnvironmentVariable {
param(
    [string] $varName
)
    Write-Debug "Running 'Remove-EnvironmentVariable' with variable name: `'$varName`'"

    # Without detailed analysis, remove all the traces of environment
    # variable from current process and user / machine space
    #
    $envTypes = @("Process", "Machine", "User")

    foreach ($scope in $envTypes) {

        # Editing environment is time consuming, so first check if there
        # is variable with that name, at all
        #
        if ([Environment]::GetEnvironmentVariable($varName, $scope)) {

            # For Machine scope, we need elevated privileges
            #
            if ($scope -eq "Machine") {
                $ps = "[Environment]::SetEnvironmentVariable(`'$varName`', `$null, `'Machine`')"
                Start-ChocolateyProcessAsAdmin "$ps"
            }
            else
            {
                [Environment]::SetEnvironmentVariable($varName, $null, $scope)
            }
        }
    }
}
