$pkg = "Devbox-GitFlow"

# Refresh environment from registry
Update-SessionEnvironment

# Find any version
$apps = @(Show-AppUninstallInfo -match "Git version [0-9\.]+-preview\d*")

try
{
    if ($apps.Length -gt 0)
    {
        $app = $apps[0]
        $gitDir = $app["InstallLocation"]

        Write-Host "`nUninstalling Git-Flow from detected Git location: $gitDir`n" -foregroundcolor yellow

        # By analyzing msysgit-install.cmd from Git-Flow, I found out exactly
        # what is new in Git folder:
        #   Git\bin: git-flow, git-flow*, gitflow-*, gitflow-shFlags
        #   Git\gitflow: the whole directory from GitHub
        #
        # They are deleting it with removing recursively
        # Git\git-flow* and Git\gitflow-*, so I will do the same.
        #
        Start-ChocolateyProcessAsAdmin "Get-ChildItem -path '$gitDir' -include 'git-flow*','gitflow-*','gitflow*' -recurse -force | Remove-Item -recurse -force" -minimized
    }

    Write-ChocolateySuccess "$pkg"
}
catch
{
    Write-ChocolateyFailure "$pkg" "$($_.Exception.Message)"
    throw
}



