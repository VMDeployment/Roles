function Get-RolePath {
	[CmdletBinding()]
	param (
		[string]
		$Role,
		
		[string]
		$System
	)
	
	process {
		Join-Path -Path (Get-RoleSystemPath -System $System) -ChildPath ($Role.ToLower() | ConvertTo-Base64)
	}
}