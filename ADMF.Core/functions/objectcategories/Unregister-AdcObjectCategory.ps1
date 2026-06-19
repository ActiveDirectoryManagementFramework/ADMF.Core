function Unregister-AdcObjectCategory {
	<#
	.SYNOPSIS
		Removes an object category from the list of registered object categories.
	
	.DESCRIPTION
		Removes an object category from the list of registered object categories.
		See description on Register-DMObjectCategory for details on object categories in general.
	
	.PARAMETER Name
		The exact name of the object category to unregister.
	
	.EXAMPLE
		PS C:\> Get-AdcObjectCategory | Unregister-AdcObjectCategory

		Clears all registered object categories.
	#>
	[Alias('Unregister-DMObjectCategory')]
	[CmdletBinding()]
	param (
		[parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string[]]
		$Name
	)
	
	process {
		foreach ($nameItem in $Name) {
			$script:objectCategories.Remove($nameItem)
		}
	}
}
