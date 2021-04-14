function Remove-RoleSystem {
	[CmdletBinding()]
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
