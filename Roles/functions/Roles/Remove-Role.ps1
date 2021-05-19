function Remove-Role {
<#
	.SYNOPSIS
		Remove a defined role.
	
	.DESCRIPTION
		Remove a defined role.
		Will silently continue if the specified role does not exist.
	
		Note: Requires elevation unless overridden using the 'Roles.Validation.SkipElevationTest' configuration.
	
	.PARAMETER Name
		Name of the role to remove.
	
	.PARAMETER System
		The role system to work with.
		Use "Select-RoleSystem" to pick a default role.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.EXAMPLE
		PS C:\> Remove-Role -Name 'admins'
	
		Removes the "admins" role
	
	.EXAMPLE
		PS C:\> Get-Role | Remove-Role
	
		Removes all roles of the current system
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfArgumentCompleter('Roles.Name')]
		[string[]]
		$Name,
		
		[PsfArgumentCompleter('Roles.System')]
		[string]
		$System = $script:selectedSystem
	)
	
	begin {
		Assert-Elevation -Cmdlet $PSCmdlet
		Assert-RoleSystem -System $System -Cmdlet $PSCmdlet
	}
	process {
		foreach ($nameEntry in $Name) {
			$systemPath = Get-RolePath -Role $nameEntry -System $System
			if (-not (Test-Path -Path $systemPath)) { continue }
			
			Invoke-PSFProtectedCommand -ActionString 'Remove-Role.Removing' -ActionStringValues $nameEntry, $System -ScriptBlock {
				Invoke-MutexCommand -Name "PS.Roles.$System.$nameEntry" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
					Remove-Item -Path $systemPath -Force -ErrorAction Stop
				} -ErrorAction Stop
			} -Target $nameEntry -EnableException $true -PSCmdlet $PSCmdlet
		}
	}
}