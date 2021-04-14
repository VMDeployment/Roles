# Roles

A powershell module allowing to implement small roles modells.
This allows building and consuming a local permission model.

> This has been designed for use in JEA.
> In opposite to reconfiguring endpoints for permissions, roles allow dynamically assigning permissions without interrupting existing sessions.

## Installation

The module has been published to the PowerShell Gallery. To install it, run:

```powershell
Install-Module Roles
```

## Prerequisites

+ PowerShell 5.1 or later
+ Windows

## Use

Using this module consists of two phases:

+ Setting up a system of roles and role memberships
+ Querying against that system

### Setting up a simple role system

Setting up and configuring the role system usually requires running PowerShell "As Administrator", as the role data is persisted under ProgramData.

> Creating the role system

```powershell
# Set up the new system
New-RoleSystem -Name 'Bartender'
```

> Defining Roles and assigning membership

```powershell
# Make the newly created system the default system for this session
Select-RoleSystem -Name 'Bartender'

# Add content to the system
New-Role -Name Admins -Description 'Primary Bar Administrators'
Add-RoleMember -Role Admins -ADMember 'Domain Admins'

New-Role -Name Barkeepers -Description 'Barkeepers, can modify stock in bar section'
Add-RoleMember -Role Barkeepers -RoleMember Admins
Add-RoleMember -Role Barkeepers -ADMember 'r-Bar-Barkeepers'

New-Role -Name Storage -Description 'Storage access, can modify stock in the storage section'
Add-RoleMember -Role Storage -RoleMember Admins
Add-RoleMember -Role Storage -ADMember 'r-Bar-Storage'
```

### Querying membership

To test for membership, after the roles have been defined is simple enough.

First, we need to select the default role system if not yet done in the current PowerShell session:

```powershell
# Make the newly created system the default system for this session
Select-RoleSystem -Name 'Bartender'
```

Then, all we need to do the test is run `Test-RoleMembership`:

```powershell
# Returns $true if current user is in Role Barkeepers
Test-RoleMembership -Role Barkeepers
```

It will check the current user against the role membership definition.

> If executed in a remoting session, such as JEA, it will check against the user connected to that session, not the local account!
> This means even if you run under a gMSA or a local virtual admin account, you can still grant and validate role membership against the actual user.

## Dependencies

This module uses as dependency:

+ [PSFramework](https://psframework.org)
+ [Mutex](https://github.com/FriedrichWeinmann/Mutex)
