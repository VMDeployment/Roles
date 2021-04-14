function Set-Role {
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true)]
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
		$systemPath = Get-RolePath -Role $Name -System $System
		if (-not (Test-Path -Path $systemPath)) {
			Stop-PSFFunction -String 'Set-Role.Role.NotFound' -StringValues $Name -EnableException $true -Category ObjectNotFound -Cmdlet $PSCmdlet
		}
		
		Invoke-PSFProtectedCommand -ActionString 'Set-Role.Updating' -ActionStringValues $Name -ScriptBlock {
			Invoke-MutexCommand -Name "PS.Roles.$System.$Name" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
				$datum = Get-Content -Path $systemPath -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
				$datum.Description = $Description
				$datum | ConvertTo-Json -Depth 99 -ErrorAction Stop | Set-Content -Path $systemPath -Encoding UTF8 -ErrorAction Stop
			}
		} -Target $Name -EnableException $true -PSCmdlet $PSCmdlet
	}
}