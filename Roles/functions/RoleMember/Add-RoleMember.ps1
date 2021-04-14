function Add-RoleMember {
<#
	.SYNOPSIS
		Adds a role or a principal to the target role.
	
	.DESCRIPTION
		Adds a role or an Active Directory principal to the target role.
	
		Note: Requires elevation unless overridden using the 'Roles.Validation.SkipElevationTest' configuration.
	
	.PARAMETER Role
		The role to add a member to.
	
	.PARAMETER RoleMember
		The other role to include.
		Role must exist, circular membership is not checked for at this time.
	
	.PARAMETER ADMember
		The Active Directory member to include.
		Accepts UPN, DistinguishedName, SamAccountName, SID, NT Account or SamAccountName.
		Everything but SID is resolved first, identifiers that do not clarify domain will first resolve local domain, then the rest of the forest starting at the root.
		Use SID to specify builtin identities or users from foreign forests.
	
	.PARAMETER System
		The role system to work with.
		Use "Select-RoleSystem" to pick a default role.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.EXAMPLE
		PS C:\> Add-RoleMember -Role 'VMManagement' -RoleMember 'admins'
	
		Adds the role "admins" as member in role "VMManagement"
	
	.EXAMPLE
		PS C:\> Add-RoleMember -Role VMManagement -ADMember contoso\r-s-vm-management
	
		Adds the principal (presumably a group) "r-s-vm-management" from the domain "contoso" to the role "VMManagement"
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfArgumentCompleter('Roles.Role')]
		[Alias('Name')]
		[string]
		$Role,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'role')]
		[PsfArgumentCompleter('Roles.Role')]
		[string[]]
		$RoleMember,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'ad')]
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
		$mainRolePath = Get-RolePath -Role $Role -System $System
		
		#region Adding by Rolename
		foreach ($roleName in $RoleMember) {
			$rolePath = Get-RolePath -Role $roleName -System $System
			if (Test-Path -Path $rolePath) {
				Invoke-PSFProtectedCommand -ActionString 'Add-RoleMember.Adding.Role' -ActionStringValues $Role, $roleName -Target $Role -Tag add, role -ScriptBlock {
					Invoke-MutexCommand -Name "PS.Roles.$System.$Role" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
						$roleData = Get-Content -Path $mainRolePath -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
						if ($roleData.RoleMembers -notcontains $roleName) {
							$roleData.RoleMembers = @($roleData.RoleMembers) + @($roleName)
							$roleData | ConvertTo-Json -Depth 99 | Set-Content $mainRolePath -Encoding UTF8 -ErrorAction Stop
						}
					}
				} -Continue -EnableException $true -PSCmdlet $PSCmdlet
			}
			else {
				Write-PSFMessage -Level Warning -String 'Add-RoleMember.Unknown.MemberRole' -StringValues $Role, $System, $roleName
				Write-Error ($script:strings.'Add-RoleMember.Unknown.MemberRole' -f $Role, $System, $roleName)
			}
		}
		#endregion Adding by Rolename
		
		#region Adding Active Directory Entities
		foreach ($adEntity in $ADMember) {
			try { $resolvedIdentity = Resolve-ADEntity -Name $adEntity }
			catch {
				Write-PSFMessage -Level Warning -String 'Add-RoleMember.ADIdentity.Unknown' -StringValues $adEntity -ErrorRecord $_ -EnableException $true -PSCmdlet $PSCmdlet
				continue
			}
			Invoke-PSFProtectedCommand -ActionString 'Add-RoleMember.Adding.ADEntity' -ActionStringValues $Role, $resolvedIdentity.SamAccountName, $resolvedIdentity.SID -Target $Role -Tag add, adentity -ScriptBlock {
				Invoke-MutexCommand -Name "PS.Roles.$System.$Role" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
					$roleData = Get-Content -Path $mainRolePath -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
					if ($roleData.ADMembers.SID -notcontains $resolvedIdentity.SID) {
						$roleData.ADMembers = @($roleData.ADMembers) + @($resolvedIdentity)
						$roleData | ConvertTo-Json -Depth 99 | Set-Content $mainRolePath -Encoding UTF8 -ErrorAction Stop
					}
				}
			} -Continue -EnableException $true -PSCmdlet $PSCmdlet
		}
		#endregion Adding Active Directory Entities
	}
}
