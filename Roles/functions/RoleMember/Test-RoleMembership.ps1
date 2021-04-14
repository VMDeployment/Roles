function Test-RoleMembership {
<#
	.SYNOPSIS
		Test whether the current identity is in a given role.
	
	.DESCRIPTION
		Test whether the current identity is in a given role.
		Will either test the current user or the remote user if in a remoting session.
	
	.PARAMETER Role
		Name of the role to test against.
	
	.PARAMETER Local
		Do not use the remote identity.
		By default - unless overridden - this test will check the remote identity when used in PSRemoting session such as JEA.
		Override the defaults using the 'Roles.Roles.UseRemoteIdentity' configuration setting.
	
	.PARAMETER System
		The role system to work with.
		Use "Select-RoleSystem" to pick a default role.
	
	.EXAMPLE
		PS C:\> Test-RoleMembership -Role 'admins'
	
		Checks whether the current user is member of the admins role.
#>
	[OutputType([bool])]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PsfArgumentCompleter('Roles.RoleMember')]
		[Alias('Name')]
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
		
		$useRemote = Get-PSFConfigValue -FullName 'Roles.Roles.UseRemoteIdentity'
		if ($Local) { $useRemote = $false }
		if ($PSBoundParameters.ContainsKey('Local') -and -not $Local) { $useRemote = $true }
	}
	process {
		
		$memberSID = Get-MemberSID -Role $Role -System $System
		
		$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
		if ($PSSenderInfo -and $useRemote) { $identity = $PSSenderInfo.UserInfo.WindowsIdentity }
		
		foreach ($sid in $memberSID) {
			if ($identity.Groups.Value -contains $sid) { return $true }
			if ($identity.User.Value -eq $sid) { return $true }
		}
		
		return $false
	}
}
