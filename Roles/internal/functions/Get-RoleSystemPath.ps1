function Get-RoleSystemPath {
<#
	.SYNOPSIS
		Return the path to the folder of the given Role System.
	
	.DESCRIPTION
		Return the path to the folder of the given Role System.
	
	.PARAMETER System
		The System for which to provide the path.
	
	.EXAMPLE
		PS C:\> Get-RoleSystemPath -System 'VMDeploy'
	
		Get the path to the Role System "VMDeploy"'s folder.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$System
	)
	process {
		Join-Path -Path $script:roleSystemPath -ChildPath ($System.ToLower() | ConvertTo-Base64)
	}
}