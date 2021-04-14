function Select-RoleSystem {
<#
	.SYNOPSIS
		Select the default role system to use.
	
	.DESCRIPTION
		Select the default role system to use.
	
	.PARAMETER Name
		The name of the system to use.
	
	.EXAMPLE
		PS C:\> Select-RoleSystem -Name 'VMDeployment'
	
		Selects the 'VMDeployment' roles system as the default system.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfArgumentCompleter('Roles.System')]
		[string]
		$Name
	)
	
	process {
		$system = Get-RoleSystem | Where-Object Name -EQ $Name
		if (-not $system) {
			Stop-PSFFunction -String 'Select-RoleSystem.NotFound' -StringValues $Name -EnableException $true -Category ObjectNotFound -Cmdlet $PSCmdlet
		}
		
		$script:selectedSystem = $system.Name
	}
}
