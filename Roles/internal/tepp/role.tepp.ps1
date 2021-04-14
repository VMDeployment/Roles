Register-PSFTeppScriptblock -Name 'Roles.Role' -ScriptBlock {
	(Get-Role).Name
}
Register-PSFTeppScriptblock -Name 'Roles.RoleMember' -ScriptBlock {
	if (-not $fakeBoundParameters.Name) {
		return (Get-Role).Name
	}
	
	$localSystem = $script:selectedSystem
	if ($fakeBoundParameters.System) { $localSystem = $fakeBoundParameters.System }
	(Get-RoleMember -Name $fakeBoundParameters.Name -System $localSystem | Where-Object Type -EQ 'Role').Name
}
Register-PSFTeppScriptblock -Name 'Roles.ADMember' -ScriptBlock {
	if (-not $fakeBoundParameters.Name) { return }
	
	$localSystem = $script:selectedSystem
	if ($fakeBoundParameters.System) { $localSystem = $fakeBoundParameters.System }
	(Get-RoleMember -Name $fakeBoundParameters.Name -System $localSystem | Where-Object Type -EQ 'ADIdentity').Name
}