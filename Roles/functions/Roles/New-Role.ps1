function New-Role {
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
		Invoke-PSFProtectedCommand -ActionString 'New-Role.Create' -ActionStringValues $Name -ScriptBlock {
			Invoke-MutexCommand -Name "PS.Roles.$System.$Name" -ErrorMessage "Failed to acquire file access lock" -ScriptBlock {
				$roleData | ConvertTo-Json -Depth 3 | Set-Content $rolePath -Encoding UTF8 -ErrorAction Stop
			}
		} -Target $Name -EnableException $true -PSCmdlet $PSCmdlet
	}
}