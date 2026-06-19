function Get-AdcPrivilegedGroupSet {
	<#
	.SYNOPSIS
		List the registered Privileged Group Sets.
	
	.DESCRIPTION
		List the registered Privileged Group Sets.
		They can be used to assign ownership to a group of identities, any one of which will be considered valid.

		For more details, see Register-AdcPrivilegedGroupSet.
	
	.PARAMETER Name
		The name of the PGS to look for.
		Defaults to: *
	
	.EXAMPLE
		PS C:\> Get-AdcPrivilegedGroupSet

		List all registered Privileged Group Sets.
	#>
	[CmdletBinding()]
	param (
		[string]
		$Name = '*'
	)
	process {
		$($script:privilegedGroupSetCalculators.Values | Where-Object Name -Like $Name)
	}
}