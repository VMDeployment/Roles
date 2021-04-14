function Get-RoleMember {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfArgumentCompleter('Roles.Role')]
		[string]
		$Name,
		
		[PsfArgumentCompleter('Roles.System')]
		[string]
		$System = $script:selectedSystem
	)
	
	begin {
		Assert-RoleSystem -System $System -Cmdlet $PSCmdlet
	}
	process {
		Assert-RoleRole -System $System -Role $Name -Cmdlet $PSCmdlet
		$rolePath = Get-RolePath -Role $Name -System $System
		
		try {
			$roleData = Invoke-MutexCommand -Name "PS.Roles.$System.$Name" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
				Get-Content -Path $rolePath -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
			}
		}
		catch { throw }
		foreach ($roleMember in $roleData.RoleMembers) {
			[PSCustomObject]@{
				PSTypeName = 'Roles.RoleMember'
				Type	   = "Role"
				Role	   = $Name
				Name	   = $roleMember
				SID	       = $null
				Domain	   = $null
			}
		}
		foreach ($adMember in $roleData.ADMembers) {
			[PSCustomObject]@{
				PSTypeName = 'Roles.RoleMember'
				Type	   = "ADIdentity"
				Role	   = $Name
				Name	   = $adMember.Name
				SID	       = $adMember.SID
				Domain	   = $adMember.Domain
			}
		}
	}
}