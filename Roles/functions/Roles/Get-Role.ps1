function Get-Role {
	[CmdletBinding()]
	param (
		[PsfArgumentCompleter('Roles.Name')]
		[string]
		$Name = '*',
		
		[PsfArgumentCompleter('Roles.System')]
		[string]
		$System = $script:selectedSystem
	)
	
	begin {
		Assert-RoleSystem -System $System -Cmdlet $PSCmdlet
	}
	process {
		$systemPath = Get-RoleSystemPath -System $System
		foreach ($file in Get-ChildItem -Path $systemPath -File) {
			$systemName = $file.Name | ConvertFrom-Base64 -ErrorAction Ignore
			if (-not $systemName) {
				Write-PSFMessage -Level Warning -String 'Get-Role.BadFileName' -StringValues $file.Name, $System -Once "Roles.Role.$($file.Name)"
				continue
			}
			if ($systemName -notlike $Name) { continue }
			
			try {
				Invoke-MutexCommand -Name "PS.Roles.$System.$Name" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
					Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
				}
			}
			catch {
				Write-PSFMessage -String 'Get-Role.File.AccessError' -StringValues $systemName, $file.FullName, $System -EnableException $true -ErrorRecord $_ -PSCmdlet $PSCmdlet
				continue
			}
		}
	}
}