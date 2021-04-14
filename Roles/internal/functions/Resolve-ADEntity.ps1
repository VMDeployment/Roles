function Resolve-ADEntity {
<#
	.SYNOPSIS
		Resolve an active directory identity into SID.
	
	.DESCRIPTION
		Resolve an active directory identity into SID.
	
	.PARAMETER Name
		The name of the entity to resolve.
		Can be a distinguished name, SID, SamAccountName, NT Account or User Principal Name.
		AD entity can be anything that holds a SID / SamAccountName.
		
		Will try to resolve identities acress all domains in the forest if ambiguous.
		It will prefer the current domain over others.
	
	.EXAMPLE
		PS C:\> Resolve-ADEntity -Name max
	
		Resolves the user max as a SamAccountName
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name
	)
	
	begin {
		#region Utility Functions
		function ConvertFrom-Name {
			[CmdletBinding()]
			param (
				[string]
				$Name
			)
			
			$result = [PSCustomObject]@{
				Username = ""
				Type	 = "unknown"
				Domain   = ""
				SID	     = ""
				Input    = $Name
			}
			
			# Case: User Principal Name
			if ($Name -match '^[\d\w-_\.]+@[\d\w-_\.]+') {
				$result.Username = $Name
				$result.Type = 'UPN'
				$result.Domain = ($Name -split "@")[-1]
				return $result
			}
			
			# Case: Distinguished Name
			if ($Name -like "*,DC=*") {
				$result.Username = $Name
				$result.Type = 'DN'
				$result.Domain = ($Name -split ",DC=" | Select-Object -Skip 1) -join "."
				return $result
			}
			
			# Case: SID
			if ($Name -as [System.Security.Principal.SecurityIdentifier]) {
				$result.Username = $Name
				$result.SID = $Name
				$result.Type = 'SID'
				$result.Domain = ($Name -as [System.Security.Principal.SecurityIdentifier]).Domain.Value
				return $result
			}
			
			# Case: NT Account
			if ($Name -like "*\*") {
				$domain, $user = $Name -split '\\'
				$result.Username = $user
				$result.TypeNames = 'NT'
				$result.Domain = $domain
				return $result
			}
			
			# Case: SamAccountName
			$result.Username = $Name
			$result.Type = 'SAM'
			$result
		}
		
		function New-Entity {
			[CmdletBinding()]
			param (
				[string]
				$Name,
				
				[string]
				$SID,
				
				[string]
				$Domain
			)
			[PSCustomObject]@{
				Name   = $Name
				SID    = $SID
				Domain = $Domain
			}
		}
		#endregion Utility Functions
	}
	process {
		$resolvedName = ConvertFrom-Name -Name $Name
		if ($resolvedName.Type -eq 'SID') {
			New-Entity -Name $resolvedName.Username -SID $resolvedName.SID -Domain $resolvedName.Domain
			return
		}
		
		if ($resolvedName.Type -eq 'DN') {
			$adObject = Get-LdapObject -LdapFilter "(distinguishedName=$($resolvedName.Username))" -Server $resolvedName.Domain -Property ObjectSID, SamAccountName
		}
		else {
			$domains = Get-PSFTaskEngineCache -Module Roles -Name DomainCache | Sort-Object { $_.DNSRoot.Length }
			if ($resolvedName.Type -eq 'NT') { $domains = $domains | Where-Object NetBIOSName -EQ $resolvedName.Domain }
			if ($resolvedName.Type -eq 'UPN') {
				$domains = do {
					$domains | Where-Object DNSRoot -EQ $resolvedName.Domain
					$domains | Where-Object DNSRoot -Ne $resolvedName.Domain
				}
				while ($false)
			}
			if ($resolvedName.Type -eq 'SAM') {
				$domains = do {
					$domains | Where-Object DNSRoot -EQ $env:USERDNSDOMAIN
					$domains | Where-Object DNSRoot -Ne $env:USERDNSDOMAIN
				}
				while ($false)
			}
			$adObject = $null
			foreach ($domain in $domains) {
				$adObject = Get-LdapObject -LdapFilter "(samAccountName=$($resolvedName.Username))" -Server $domain.DNSRoot -Property ObjectSID, SamAccountName
				if ($adObject) {
					$resolvedName.Domain = $domain.DNSRoot
					break
				}
			}
		}
		if (-not $adObject) { throw "AD Object not found: $($Name)" }
		
		New-Entity -Name $adObject.SamAccountName -SID $adObject.ObjectSID -Domain $resolvedName.Domain
	}
}