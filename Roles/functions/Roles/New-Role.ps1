function New-Role {
<#
	.SYNOPSIS
		Create a new role.
	
	.DESCRIPTION
		Create a new role.
		Roles can be granted permission upon and membership to.
		
		Note: Requires elevation unless overridden using the 'Roles.Validation.SkipElevationTest' configuration.
	
	.PARAMETER Name
		Name of the role to create.
	
	.PARAMETER Description
		Description of the role being created.
	
	.PARAMETER Force
		Recreate a role if it has already been created.
		Recreating a role will remove all previously assigned memberships.
		By default, this command fails if the role specified already exists.
	
	.PARAMETER System
		The role system to work with.
		Use "Select-RoleSystem" to pick a default role.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.EXAMPLE
		PS C:\> New-Role -Name 'admins' -Description 'administrative access over the configuration deployment system'
	
		Create a new role named "admins".
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true)]
		[string]
		$Description,
		
		[switch]
		$Force,
		
		[PsfArgumentCompleter('Roles.System')]
		[string]
		$System = $script:selectedSystem
	)
	
	begin {
		Assert-Elevation -Cmdlet $PSCmdlet
		Assert-RoleSystem -System $System -Cmdlet $PSCmdlet
	}
	process {
		$rolePath = Get-RolePath -Role $Name -System $System
		if (-not $Force -and (Test-Path -Path $rolePath)) {
			Stop-PSFFunction -String 'New-Role.ExistsAlready' -StringValues $Name, $System -EnableException $true -Category InvalidArgument -Cmdlet $PSCmdlet
		}
		
		$roleData = [pscustomobject]@{
			Name	    = $Name
			Description = $Description
			System	    = $System
			RoleMembers = @()
			ADMembers   = @()
		}
		Invoke-PSFProtectedCommand -ActionString 'New-Role.Create' -ActionStringValues $Name, $System -ScriptBlock {
			Invoke-MutexCommand -Name "PS.Roles.$System.$Name" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
				$roleData | ConvertTo-Json -Depth 3 | Set-Content $rolePath -Encoding UTF8 -ErrorAction Stop
			}
		} -Target $Name -EnableException $true -PSCmdlet $PSCmdlet
	}
}