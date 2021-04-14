function New-RoleSystem {
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
		
		Invoke-PSFProtectedCommand -ActionString 'New-RoleSystem.Creating' -Target $Name -ScriptBlock {
			$null = New-Item -Path $systemFolder -ItemType Directory -Force -ErrorAction Stop
		} -EnableException $true -PSCmdlet $PSCmdlet
	}
}
