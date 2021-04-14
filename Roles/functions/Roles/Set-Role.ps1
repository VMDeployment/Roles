function Set-Role {
<#
	.SYNOPSIS
		Update the description of an existing role.
	
	.DESCRIPTION
		Update the description of an existing role.
	
		Note: Requires elevation unless overridden using the 'Roles.Validation.SkipElevationTest' configuration.
	
	.PARAMETER Name
		Name of the role to update.
	
	.PARAMETER Description
		Description to apply.
	
	.PARAMETER System
		The role system to work with.
		Use "Select-RoleSystem" to pick a default role.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.EXAMPLE
		PS C:\> Set-Role -Name 'VMOperators' -Description 'Operators allowed to manage Virtual Machine state'
	
		Updates the description of the VMOperators role
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('Role')]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[string]
		$Description,
		
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
		$systemPath = Get-RolePath -Role $Name -System $System
		if (-not (Test-Path -Path $systemPath)) {
			Stop-PSFFunction -String 'Set-Role.Role.NotFound' -StringValues $Name, $System -EnableException $true -Category ObjectNotFound -Cmdlet $PSCmdlet
		}
		
		Invoke-PSFProtectedCommand -ActionString 'Set-Role.Updating' -ActionStringValues $Name, $System -ScriptBlock {
			Invoke-MutexCommand -Name "PS.Roles.$System.$Name" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
				$datum = Get-Content -Path $systemPath -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
				$datum.Description = $Description
				$datum | ConvertTo-Json -Depth 99 -ErrorAction Stop | Set-Content -Path $systemPath -Encoding UTF8 -ErrorAction Stop
			}
		} -Target $Name -EnableException $true -PSCmdlet $PSCmdlet
	}
}