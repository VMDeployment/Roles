function Assert-Elevation
{
<#
	.SYNOPSIS
		Asserts that the current PowerShell process runs with elevation.
	
	.DESCRIPTION
		Asserts that the current PowerShell process runs with elevation.
		Will always succeed on non-windows computers.
	
	.PARAMETER Cmdlet
		The $PSCmdlet variable of the calling command, used to throw the exception in the context of the caller.
	
	.EXAMPLE
		PS C:\> Assert-Elevation -Cmdlet $PSCmdlet
	
		Asserts that the current PowerShell process runs with elevation.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Cmdlet
	)
	
	process
	{
		if (Test-PSFPowerShell -Elevated) { return }
		if (Get-PSFConfigValue -FullName 'Roles.Validation.SkipElevationTest') { return }
		
		$exception = [System.Security.SecurityException]::new("Insufficient access, elevation required! This operation requires running PowerShell 'As Administrator'")
		$record = [System.Management.Automation.ErrorRecord]::new($exception, "NotElevated", [System.Management.Automation.ErrorCategory]::SecurityError, $null)
		$Cmdlet.ThrowTerminatingError($record)
	}
}