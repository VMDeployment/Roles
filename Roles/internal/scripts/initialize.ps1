if (-not (Test-Path -Path $script:roleSystemPath)) {
	$null = New-Item -Path $script:roleSystemPath -ItemType Directory -Force -ErrorAction Ignore
}

Set-PSFTaskEngineCache -Module Roles -Name DomainCache -Lifetime 24h -Collector {
	$roles = Get-Module Roles
	if (-not $roles) {
		Import-Module Roles
		$roles = Get-Module Roles
	}
	& $roles {
		$forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
		$partitions = $forest.Schema.Name -replace '^CN=Schema', 'CN=Partitions'
		Get-LdapObject -SearchRoot $partitions -LdapFilter '(netBiosName=*)'
	}
}