function Assert-RoleRole
{
<#
	.SYNOPSIS
		Asserts that the specified role is part of the specified system.
	
	.DESCRIPTION
		Asserts that the specified role is part of the specified system.
	
	.PARAMETER System
		The system to ensure exists.
		May be an empty string (in which case it is guaranteed to fail).
	
	.PARAMETER Role
		The role that should be part of the current system.
		May be an empty string (in which case it is guaranteed to fail).
	
	.PARAMETER Cmdlet
		The $PSCmdlet variable of the calling command.
	
	.EXAMPLE
		PS C:\> Assert-RoleRole -System $System -Role $Name -Cmdlet $PSCmdlet
	
		Asserts that the specified role is part of the specified system.
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true)]
		[AllowEmptyString()]
		[string]
		$System,
		
		[Parameter(Mandatory = $true)]
		[AllowEmptyString()]
		[string]
		$Role,
		
		[Parameter(Mandatory = $true)]
		$Cmdlet
	)
	
	process
	{
		if ($System -and $Role) {
			$systemPath = Get-RolePath -System $System -Role $Role
			if (Test-Path -Path $systemPath) { return }
		}
		
		$exception = [System.ArgumentException]::new("Bad Role / System combination. Make sure the selected role '$Role' exists in '$System'", "Role")
		$record = [System.Management.Automation.ErrorRecord]::new($exception, "UnknownRole", [System.Management.Automation.ErrorCategory]::InvalidArgument, $null)
		$Cmdlet.ThrowTerminatingError($record)
	}
}