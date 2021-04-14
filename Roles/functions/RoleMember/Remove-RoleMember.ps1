function Remove-RoleMember {
<#
	.SYNOPSIS
		Removes a member from a role.
	
	.DESCRIPTION
		Removes a member from a role.
		Members can be both active directory entities or other roles.
	
		Note: Requires elevation unless overridden using the 'Roles.Validation.SkipElevationTest' configuration.
	
	.PARAMETER Role
		The role to remove from.
	
	.PARAMETER RoleMember
		Name of another role that should have its membership in -Role revoked.
	
	.PARAMETER ADMember
		SID of an active directory principal that should have its membership in -Role revoked.
	
	.PARAMETER System
		The role system to work with.
		Use "Select-RoleSystem" to pick a default role.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.EXAMPLE
		PS C:\> Get-RoleMember -Role VMManagement | Remove-RoleMember
	
		Clears all members from the role VMManagement.
	
	.EXAMPLE
		PS C:\> Remove-RoleMember -Role VMManagement -RoleMember admins
	
		Removes the role "admins" from the role "VMManagement"
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfArgumentCompleter('Roles.Role')]
		[string]
		$Role,
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[PsfArgumentCompleter('Roles.RoleMember')]
		[Alias('Name')]
		[string[]]
		$RoleMember,
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[PsfArgumentCompleter('Roles.ADMember')]
		[AllowEmptyString()]
		[AllowNull()]
		[Alias('SID')]
		[string[]]
		$ADMember,
		
		[PsfArgumentCompleter('Roles.System')]
		[string]
		$System = $script:selectedSystem
	)
	
	begin {
		Assert-Elevation -Cmdlet $PSCmdlet
		Assert-RoleSystem -System $System -Cmdlet $PSCmdlet
	}
	process {
		Assert-RoleRole -System $System -Role $Role -Cmdlet $PSCmdlet
		$allMembers = Get-RoleMember -Role $Role -System $System
		$mainRolePath = Get-RolePath -Role $Role -System $System
		
		foreach ($roleName in $RoleMember) {
			if (($allMembers | Where-Object Type -EQ Role).Name -notcontains $roleName) { continue }
			
			Invoke-PSFProtectedCommand -ActionString 'Remove-RoleMember.Removing.Role' -ActionStringValues $Role, $System, $roleName -Target $Role -Tag remove, role -ScriptBlock {
				Invoke-MutexCommand -Name "PS.Roles.$System.$Role" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
					$roleData = Get-Content -Path $mainRolePath -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
					$roleData.RoleMembers = $roleData.RoleMembers | Where-Object { $_ -ne $roleName }
					$roleData | ConvertTo-Json -Depth 99 | Set-Content $mainRolePath -Encoding UTF8 -ErrorAction Stop
				}
			} -Continue -EnableException $true -PSCmdlet $PSCmdlet
		}
		foreach ($adIdentifier in $ADMember) {
			if (-not $adIdentifier) { continue }
			if (($allMembers | Where-Object Type -EQ ADIdentity).SID -notcontains $adIdentifier) { continue }
			
			$memberObject = $allMembers | Where-Object Type -EQ ADIdentity | Where-Object SID -EQ $adIdentifier
			Invoke-PSFProtectedCommand -ActionString 'Remove-RoleMember.Removing.ADIdentity' -ActionStringValues $Role, $System, $memberObject.Name, $memberObject.Domain, $memberObject.SID -Target $Role -Tag remove, role -ScriptBlock {
				Invoke-MutexCommand -Name "PS.Roles.$System.$Role" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
					$roleData = Get-Content -Path $mainRolePath -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
					$roleData.ADMembers = $roleData.ADMembers | Where-Object SID -NE $adIdentifier
					$roleData | ConvertTo-Json -Depth 99 | Set-Content $mainRolePath -Encoding UTF8 -ErrorAction Stop
				}
			} -Continue -EnableException $true -PSCmdlet $PSCmdlet
		}
	}
}
