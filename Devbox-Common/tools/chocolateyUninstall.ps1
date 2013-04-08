$pkgName = 'Devbox-Common'

try
{
  $varName = 'chocolatey_bin_root'

  Update-SessionEnvironment

  # Remove variable if not empty
  #
  $varValue = Get-Item Env:$varName -ErrorAction SilentlyContinue | Select -ExpandProperty Value -First 1

  if ($varValue)
  {
    [Environment]::SetEnvironmentVariable($varName, $null, 'User')
    Remove-Item Env:\$varName

    Write-Host "Removed environment variable: $varName, value was: $varValue"
  }

  Write-ChocolateySuccess "$pkgName"
}
catch
{
  Write-ChocolateyFailure "$pkgName" "$($_.Exception.Message)"
  throw
}



