function Remove-Role {
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
			
			Invoke-PSFProtectedCommand -ActionString 'Remove-Role.Removing' -ActionStringValues $nameEntry -ScriptBlock {
				Invoke-MutexCommand -Name "PS.Roles.$System.$nameEntry" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
					Remove-Item -Path $systemPath -Force -ErrorAction Stop
				}
			} -Target $nameEntry -EnableException $true -PSCmdlet $PSCmdlet
		}
	}
}