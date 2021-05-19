function ConvertTo-Base64
{
<#
	.SYNOPSIS
		Convert a string to Base64.
	
	.DESCRIPTION
		Convert a string to Base64.
	
	.PARAMETER Text
		The text to convert
	
	.EXAMPLE
		PS C:\> $role | ConvertTo-Base64
	
		Convert the string stored in $role to base 64.
#>
    [OutputType([string])]
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[AllowEmptyString()]
		[string[]]
		$Text
	)
	
	process
	{
		foreach ($textItem in $Text) {
			try {
				$bytes = [System.Text.Encoding]::UTF8.GetBytes($textItem)
				[Convert]::ToBase64String($bytes)
			}
			catch { Write-Error $_ }
		}
	}
}