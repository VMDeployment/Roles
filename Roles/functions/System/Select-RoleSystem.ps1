function Select-RoleSystem {
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
