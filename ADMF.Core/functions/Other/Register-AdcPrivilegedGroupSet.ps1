function Register-AdcPrivilegedGroupSet {
	<#
	.SYNOPSIS
		Register a Privileged Group Set for use during ownership assignments.
	
	.DESCRIPTION
		Register a Privileged Group Set for use during ownership assignments.
		They can be used to assign a group of identities as owners - any one of which is a viable owner for the assignment.
		They also provide a default SID in case none of them are assigned.

		The data is calculated per-domain, cached on the first application.
		Cache is cleared when resetting configuration (e.g. loading a new context combination).

		The SIDs resolved can be from one or multiple domains.

		To test your Privileged Group Set use "Resolve-AdcPrivilegedGroupSet".
		To assign it as an owner, wrap its name in two underscores on each side when assigning it as owner in the config:
		If the Privileged Group Set is named "DomainAdmins", assign it as owner by setting the owner to "__DomainAdmins__".

		The scriptblock doing the calculation receives two parameters:
		- Parameters <Hashtable>: The server/credential pair used for the current execution.
		- Domain <ADDomain>: The domain object targeted - as returned by Get-ADDomain
		
		The scriptblock should return a hashtable or custom object that has two entries/properties:
		- SIDs <string[]>: The list of SIDs that are matched. Must be at least one valid sid.
		- DefaultSID <string>: The SID to use for the change if the target is none of the permitted SIDs. This SID should ALSO be included in "SIDs".
	
	.PARAMETER Name
		The name of the Privileged Group Set.
	
	.PARAMETER Description
		A description explaining the Privileged Group Set.
	
	.PARAMETER Code
		The code that calculates the data on demand.
		See the Description section for details on what parameters it receives and what output it should produce.
	
	.EXAMPLE
		PS C:\> Register-AdcPrivilegedGroupSet -Name PKIServer -Description $description -Code $code
		
		Registers the Privileged Group Set "PKI Server" with the provided code.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,

		[string]
		$Description,

		[Scriptblock]
		$Code
	)
	process {
		$script:privilegedGroupSetCalculators[$Name] = [PSCustomObject]@{
			PSTypeName  = 'ADMF.Core.PrivilegedGroupSet'
			Name        = $Name
			Description = $Description
			Code        = $Code
		}
	}
}