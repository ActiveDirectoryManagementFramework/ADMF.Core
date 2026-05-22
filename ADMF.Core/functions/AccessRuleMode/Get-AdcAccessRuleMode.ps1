function Get-AdcAccessRuleMode {
	<#
	.SYNOPSIS
		Retrieve registered AccessRule processing modes.
	
	.DESCRIPTION
		Retrieve registered AccessRule processing modes.
		These are used to define, how AccessRules will be processed.
	
	.PARAMETER Path
		Filter by the path the AccessRule processing mode applies to.
	
	.PARAMETER ObjectCategory
		Filter by the object category the AccessRule processing mode applies to.
	
	.EXAMPLE
		PS C:\> Get-AdcAccessRuleMode

		List all registered AccessRule processing modes.
	#>
	[CmdletBinding()]
	param (
		[string]
		$Path = '*',

		[string]
		$ObjectCategory = '*'
	)
	
	process {
		$script:accessRuleMode.Values | Where-Object Path -Like $Path | Where-Object ObjectCategory -Like $ObjectCategory
	}
}
