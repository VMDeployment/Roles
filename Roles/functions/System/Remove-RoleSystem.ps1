function Remove-RoleSystem {
<#
	.SYNOPSIS
		Remove an existing role system.
	
	.DESCRIPTION
		Remove an existing role system.
		Will silently terminate if system is unknown.
	
		Note: Requires elevation unless overridden using the 'Roles.Validation.SkipElevationTest' configuration.
	
	.PARAMETER Name
		Name of the role system to delete.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.EXAMPLE
		PS C:\> Remove-RoleSystem -Name 'VMDeployment'
	
		Removes the role system "VMDeployment"
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfArgumentCompleter('Roles.System')]
		[string[]]
		$Name
	)
	
	begin {
		Assert-Elevation -Cmdlet $PSCmdlet
	}
	process {
		if (-not (Test-Path $script:roleSystemPath)) { return }
		
		foreach ($systemName in $Name) {
			$systemPath = Get-RoleSystemPath -System $systemName
			
			if (-not (Test-Path -Path $systemPath)) { continue }
			
			Invoke-PSFProtectedCommand -ActionString 'Remove-RoleSystem.Removing' -ActionStringValues $systemName -ScriptBlock {
				Remove-Item -Path $systemPath -Force -Recurse -ErrorAction Stop
			} -Target $systemName -EnableException $true -PSCmdlet $PSCmdlet
		}
	}
}
