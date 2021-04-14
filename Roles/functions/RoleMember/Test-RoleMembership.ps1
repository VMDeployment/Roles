function Test-RoleMembership {
	[OutputType([bool])]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PsfArgumentCompleter('Roles.RoleMember')]
		[string]
		$Role,
		
		[switch]
		$Local,
		
		[PsfArgumentCompleter('Roles.System')]
		[string]
		$System = $script:selectedSystem
	)
	
	begin {
		Assert-RoleSystem -System $System -Cmdlet $PSCmdlet
		Assert-RoleRole -System $System -Role $Role -Cmdlet $PSCmdlet
		
		#region Utility Functions
		function Get-MemberSID {
			[CmdletBinding()]
			param (
				[string]
				$Role,
				
				[string]
				$System
			)
			
			$roleObject = Get-Role -System $System -Name $Role
			$roleObject.ADMembers.SID
			foreach ($roleMember in $roleObject.RoleMembers) {
				Get-MemberSID -Role $roleMember -System $System
			}
		}
		#endregion Utility Functions
		
	}
	process {
		
		$memberSID = Get-MemberSID -Role $Role -System $System
		
		$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
		if ($PSSenderInfo -and -not $Local) { $identity = $PSSenderInfo.UserInfo.WindowsIdentity }
		
		foreach ($sid in $memberSID) {
			if ($identity.Groups.Value -contains $sid) { return $true }
			if ($identity.User.Value -eq $sid) { return $true }
		}
		
		return $false
	}
}
