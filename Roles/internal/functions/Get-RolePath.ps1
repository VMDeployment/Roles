function Get-RolePath {
<#
	.SYNOPSIS
		Resolve the path of the specified role.
	
	.DESCRIPTION
		Resolve the path of the specified role.
	
	.PARAMETER Role
		Name of the role to resolve.
	
	.PARAMETER System
		System in which the role is included.
	
	.EXAMPLE
		PS C:\> Get-RolePath -Role $Role -System $System
	
		Returns the path to the role $Role
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Role,
		
		[Parameter(Mandatory = $true)]
		[string]
		$System
	)
	
	process {
		Join-Path -Path (Get-RoleSystemPath -System $System) -ChildPath ($Role.ToLower() | ConvertTo-Base64)
	}
}