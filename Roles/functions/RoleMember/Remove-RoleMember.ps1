function Remove-RoleMember {
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
		$allMembers = Get-RoleMember -Name $Role -System $System
		$mainRolePath = Get-RolePath -Role $Role -System $System
		
		foreach ($roleName in $RoleMember) {
			if (($allMembers | Where-Object Type -EQ Role).Name -notcontains $roleName) { continue }
			
			Invoke-PSFProtectedCommand -ActionString 'Remove-RoleMember.Removing.Role' -ActionStringValues $Role, $roleName -Target $Role -Tag remove, role -ScriptBlock {
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
			Invoke-PSFProtectedCommand -ActionString 'Remove-RoleMember.Removing.ADIdentity' -ActionStringValues $Role, $memberObject.Name, $memberObject.Domain, $memberObject.SID -Target $Role -Tag remove, role -ScriptBlock {
				Invoke-MutexCommand -Name "PS.Roles.$System.$Role" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
					$roleData = Get-Content -Path $mainRolePath -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
					$roleData.ADMembers = $roleData.ADMembers | Where-Object SID -NE $adIdentifier
					$roleData | ConvertTo-Json -Depth 99 | Set-Content $mainRolePath -Encoding UTF8 -ErrorAction Stop
				}
			} -Continue -EnableException $true -PSCmdlet $PSCmdlet
		}
	}
}
