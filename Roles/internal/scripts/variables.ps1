# Path to central folder managing roles
$script:roleSystemPath = Join-Path -Path ([System.Environment]::GetFolderPath("CommonApplicationData")) -ChildPath 'PowerShell/Roles'

# Selected system - used as default for all role and rolemember commands
$script:selectedSystem = ''

# Localized Strings for Write-Error calls
$script:strings = Get-PSFLocalizedString -Module Roles

# Used in the module for capital-casing LDAP properties. Consumed by Get-LdapObject
$script:culture = Get-Culture