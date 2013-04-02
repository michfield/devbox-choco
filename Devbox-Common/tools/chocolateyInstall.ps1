# Exact package name. Directory will be created
# in choco\lib based on this value
#
$pkgName = 'Devbox-Common'

try
{
  $varName = 'chocolatey_bin_root'

  # Helper function that updates current environment based on settings
  # in registry, thus avoiding a need for session restart
  #
  Update-SessionEnvironment

  # Set variable only if empty
  #
  $varValue = Get-Item Env:$varName -ErrorAction SilentlyContinue | Select -ExpandProperty Value -First 1

  if ($varValue)
  {
    Write-Host "Doing nothing. Environment variable is already set: $varName = $varValue"
  }
  else {

    $varValue = Join-Path $Env:SystemDrive '\Tools'

    [Environment]::SetEnvironmentVariable($varName, $varValue, 'User')
    Set-Content Env:\$varName $varValue

    Write-Host "Configured environment variable: $varName = $varValue"
  }

  Write-ChocolateySuccess "$pkgName"
}
catch
{
  Write-ChocolateyFailure "$pkgName" "$($_.Exception.Message)"
  throw
}
