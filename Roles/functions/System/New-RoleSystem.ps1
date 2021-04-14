function New-RoleSystem {
<#
	.SYNOPSIS
		Create a new role system.
	
	.DESCRIPTION
		Create a new role system.
		A role system is a container for roles and rule assignments.
		
		Note: Requires elevation unless overridden using the 'Roles.Validation.SkipElevationTest' configuration.
	
	.PARAMETER Name
		Name of the role system to create.
	
	.PARAMETER Force
		Overwrite existing role systems.
		By default, this command will fail if a role system of the specified name already exists.
		Overwriting an existing role system will remove all previously existing content (roles & role memberships)
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.EXAMPLE
		PS C:\> New-RoleSystem -Name 'VMDeployment'
	
		Create a new role system named "VMDeployment"
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[switch]
		$Force
	)
	
	begin {
		Assert-Elevation -Cmdlet $PSCmdlet
	}
	process {
		$systemFolder = Get-RoleSystemPath -System $Name
		if (Test-Path -Path $systemFolder) {
			if ($Force) {
				Invoke-PSFProtectedCommand -ActionString 'New-RoleSystem.ClearingPrevious' -ActionStringValues $Name -ScriptBlock {
					Remove-Item -Path $systemFolder -Force -Recurse -ErrorAction Stop
				} -Target $Name -EnableException $true -PSCmdlet $PSCmdlet
			}
			else {
				Stop-PSFFunction -String 'New-RoleSystem.ExistsAlready' -StringValues $Name -EnableException $true -Cmdlet $PSCmdlet -Category InvalidArgument
			}
		}
		
		Invoke-PSFProtectedCommand -ActionString 'New-RoleSystem.Creating' -ActionStringValues $Name -Target $Name -ScriptBlock {
			$null = New-Item -Path $systemFolder -ItemType Directory -Force -ErrorAction Stop
		} -EnableException $true -PSCmdlet $PSCmdlet
	}
}
