function Get-RoleMember {
<#
	.SYNOPSIS
		Get the role members of the specified role.
	
	.DESCRIPTION
		Get the role members of the specified role.
	
	.PARAMETER Role
		Name of the role to get the members of.
	
	.PARAMETER System
		The role system to work with.
		Use "Select-RoleSystem" to pick a default role.
	
	.EXAMPLE
		PS C:\> Get-RoleMember -Role 'VMManagement'
	
		Get all members of the role 'VMManagement'
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfArgumentCompleter('Roles.Role')]
		[Alias('Name')]
		[string]
		$Role,
		
		[PsfArgumentCompleter('Roles.System')]
		[string]
		$System = $script:selectedSystem
	)
	
	begin {
		Assert-RoleSystem -System $System -Cmdlet $PSCmdlet
	}
	process {
		Assert-RoleRole -System $System -Role $Role -Cmdlet $PSCmdlet
		$rolePath = Get-RolePath -Role $Role -System $System
		
		try {
			$roleData = Invoke-MutexCommand -Name "PS.Roles.$System.$Role" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
				Get-Content -Path $rolePath -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
			}
		}
		catch { throw }
		foreach ($roleMember in $roleData.RoleMembers) {
			[PSCustomObject]@{
				PSTypeName = 'Roles.RoleMember'
				Type	   = "Role"
				Role	   = $Role
				Name	   = $roleMember
				SID	       = $null
				Domain	   = $null
			}
		}
		foreach ($adMember in $roleData.ADMembers) {
			[PSCustomObject]@{
				PSTypeName = 'Roles.RoleMember'
				Type	   = "ADIdentity"
				Role	   = $Role
				Name	   = $adMember.Name
				SID	       = $adMember.SID
				Domain	   = $adMember.Domain
			}
		}
	}
}