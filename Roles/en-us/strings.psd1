# This is where the strings go, that are written by
# Write-PSFMessage, Stop-PSFFunction or the PSFramework validation scriptblocks
@{
	'Add-RoleMember.Adding.ADEntity'	    = 'Adding Principal {1} ({2}) to {0}' # $Role, $resolvedIdentity.SamAccountName, $resolvedIdentity.SID
	'Add-RoleMember.Adding.Role'		    = 'Adding role {1} to role {0}' # $Role, $roleName
	'Add-RoleMember.ADIdentity.Unknown'	    = 'Unable to identify AD principal: {0}' # $adEntity
	'Add-RoleMember.Unknown.MemberRole'	    = 'Unable to role-member to {0}. The role {2} was not found in the role system {1}' # $Role, $System, $roleName
	
	'Get-LdapObject.SearchError'		    = 'Error executing LDAP query' # 
	'Get-LdapObject.Searchfilter'		    = 'Resolved LDAP filter: {0}' # $LdapFilter
	'Get-LdapObject.SearchRoot'			    = 'Searching {0} in {1}' # $SearchScope, $searcher.SearchRoot.Path
	
	'Get-Role.BadFileName'				    = 'Unable to process file {0} in system {1}. Invalid name as a role.' # $file.Name, $System
	'Get-Role.File.AccessError'			    = 'Error accessing the file backing role {0} in system {2}: {1}' # $systemName, $file.FullName, $System
	
	'Get-RoleSystem.BadFolderName'		    = 'Unable to process folder as role system: {0}. Invalid name.' # $folder.Name
	
	'New-Role.Create'					    = 'Creating new role {0} in role system {1}' # $Name, $System
	'New-Role.ExistsAlready'			    = 'Role {0} already exists in role system {1}' # $Name, $System
	
	'New-RoleSystem.ClearingPrevious'	    = 'Purging previous role system {0} in preparation to creating it anew.' # $Name
	'New-RoleSystem.Creating'			    = 'Creating new role system: {0}' # $Name
	'New-RoleSystem.ExistsAlready'		    = 'Role system already exists: {0}. Use -Force to overwrite it (deleting all roles and role assignments)' # $Name
	
	'Remove-Role.Removing'				    = 'Removing role: {0} from role system {1}' # $nameEntry, $System
	
	'Remove-RoleMember.Removing.ADIdentity' = 'Removing AD Principal member from role {0} ({1}): {2} ({3}; {4})' # $Role, $System, $memberObject.Name, $memberObject.Domain, $memberObject.SID
	'Remove-RoleMember.Removing.Role'	    = 'Removing Role member from role {0} ({1}): {2}' # $Role, $roleName
	
	'Remove-RoleSystem.Removing'		    = 'Removing role system {0}, deleting all its content.' # $systemName
	
	'Select-RoleSystem.NotFound'		    = 'Unable to find role system {0}' # $Name
	
	'Set-Role.Role.NotFound'			    = 'Unable to find role {0} in role system {1}' # $Name, $System
	'Set-Role.Updating'					    = 'Updating role {0} in role system {1}' # $Name, $System
}