function Get-AdcObjectCategory {
	<#
	.SYNOPSIS
		Returns registered object category objects.
	
	.DESCRIPTION
		Returns registered object category objects.
		See description on Register-DMObjectCategory for details on object categories in general.
	
	.PARAMETER Name
		The name to filter by.4
	
	.EXAMPLE
		PS C:\> Get-AdcObjectCategory

		Returns all registered object categories.
	#>
	[Alias('Get-DMObjectCategory')]
	[CmdletBinding()]
	param (
		[string]
		$Name = '*'
	)
	
	process {
		($script:objectCategories.Values | Where-Object Name -Like $Name)
	}
}
