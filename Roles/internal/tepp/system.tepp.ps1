Register-PSFTeppScriptblock -Name 'Roles.System' -ScriptBlock {
	(Get-RoleSystem).Name
}