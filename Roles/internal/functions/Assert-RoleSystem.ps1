function Assert-RoleSystem
{
<#
	.SYNOPSIS
		Assert that the selected Role System is valid.
	
	.DESCRIPTION
		Assert that the selected Role System is valid.
	
	.PARAMETER System
		The system to ensure exists.
		May be an empty string (in which case it is guaranteed to fail).
	
	.PARAMETER Cmdlet
		The $PSCmdlet variable of the calling command.
	
	.EXAMPLE
		PS C:\> Assert-System -System $System -Cmdlet $PSCmdlet
	
		Asserts that the Role System provided in $System exists
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[AllowEmptyString()]
		[string]
		$System,
		
		[Parameter(Mandatory = $true)]
		$Cmdlet
	)
	
	process{
		if ($System) {
			$systemBase64 = $System.ToLower() | ConvertTo-Base64
			$systemPath = Join-Path -Path $script:roleSystemPath -ChildPath $systemBase64
			if (Test-Path -Path $systemPath) { return }
		}
		
		$exception = [System.ArgumentException]::new("Bad Role System. Be sure to specify a valid system or execute Select-RoleSystem to select a system to use!", "System")
		$record = [System.Management.Automation.ErrorRecord]::new($exception, "UnknownSystem", [System.Management.Automation.ErrorCategory]::InvalidArgument, $null)
		$Cmdlet.ThrowTerminatingError($record)
	}
}