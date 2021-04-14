function Add-RoleMember {
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfArgumentCompleter('Roles.Role')]
		[string]
		$Name,
		
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
		Assert-RoleRole -System $System -Role $Name -Cmdlet $PSCmdlet
		$mainRolePath = Get-RolePath -Role $Name -System $System
		
		#region Adding by Rolename
		foreach ($roleName in $RoleMember) {
			$rolePath = Get-RolePath -Role $roleName -System $System
			if (Test-Path -Path $rolePath) {
				Invoke-PSFProtectedCommand -ActionString 'Add-RoleMember.Adding.Role' -ActionStringValues $Name, $roleName -Target $Name -Tag add, role -ScriptBlock {
					Invoke-MutexCommand -Name "PS.Roles.$System.$Name" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
						$roleData = Get-Content -Path $mainRolePath -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
						if ($roleData.RoleMembers -notcontains $roleName) {
							$roleData.RoleMembers = @($roleData.RoleMembers) + @($roleName)
							$roleData | ConvertTo-Json -Depth 99 | Set-Content $mainRolePath -Encoding UTF8 -ErrorAction Stop
						}
					}
				} -Continue -EnableException $true -PSCmdlet $PSCmdlet
			}
			else {
				Write-PSFMessage -Level Warning -String 'Add-RoleMember.Unknown.MemberRole' -StringValues $Name, $System, $roleName
				Write-Error ($script:strings.'Add-RoleMember.Unknown.MemberRole' -f $Name, $System, $roleName)
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
			Invoke-PSFProtectedCommand -ActionString 'Add-RoleMember.Adding.ADEntity' -ActionStringValues $Name, $resolvedIdentity.SamAccountName, $resolvedIdentity.SID -Target $Name -Tag add, adentity -ScriptBlock {
				Invoke-MutexCommand -Name "PS.Roles.$System.$Name" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
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
