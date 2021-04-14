function ConvertFrom-Base64 {
<#
	.SYNOPSIS
		Convert a string from Base64.
	
	.DESCRIPTION
		Convert a string from Base64.
	
	.PARAMETER Text
		The base64 text to convert
	
	.EXAMPLE
		PS C:\> $role | ConvertTo-Base64
	
		Convert the string stored in $role to base 64.
#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[AllowEmptyString()]
		[string[]]
		$Text
	)
	
	process {
		foreach ($textItem in $Text) {
			try {
				$bytes = [System.Convert]::FromBase64String($textItem)
				[System.Text.Encoding]::UTF8.GetString($bytes)
			}
			catch { Write-Error $_ }
		}
	}
}