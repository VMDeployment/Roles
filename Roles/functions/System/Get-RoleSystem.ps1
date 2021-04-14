function Get-RoleSystem {
<#
	.SYNOPSIS
		Get a list of available role systems.
	
	.DESCRIPTION
		Get a list of available role systems.
	
	.PARAMETER Name
		Name of the systems to filter by.
		Defaults to '*'
	
	.EXAMPLE
		PS C:\> Get-RoleSystem
	
		Get a list of all available role systems.
#>
	[CmdletBinding()]
	param (
		[PsfArgumentCompleter('Roles.System')]
		[string]
		$Name = '*'
	)
	
	process {
		if (-not (Test-Path $script:roleSystemPath)) { return }
		
		foreach ($folder in Get-ChildItem -Path $script:roleSystemPath -Directory) {
			$systemName = $folder.Name | ConvertFrom-Base64 -ErrorAction Ignore
			if (-not $systemName) {
				Write-PSFMessage -Level Warning -String 'Get-RoleSystem.BadFolderName' -StringValues $folder.Name -Once "Roles.System.$($folder.Name)"
				continue
			}
			if ($systemName -notlike $Name) { continue }
			
			[pscustomobject]@{
				Name  = $systemName
				Roles = (Get-ChildItem -Path $folder.FullName -File | Microsoft.PowerShell.Utility\Select-Object -ExpandProperty BaseName | ConvertFrom-Base64 -ErrorAction Ignore | Measure-Object).Count
				CreatedOn = $folder.CreationTime
				Modified = (Get-ChildItem -Path $folder.FullName -File | Sort-Object LastWriteTime -Descending | Microsoft.PowerShell.Utility\Select-Object -First 1).LastWriteTime
			}
		}
	}
}
