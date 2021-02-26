function Get-AdcExchangeVersion
{
<#
	.SYNOPSIS
		Return Exchange Version Information.
	
	.DESCRIPTION
		Return Exchange Version Information.
	
	.PARAMETER Binding
		The Binding to use.
	
	.PARAMETER Name
		The name to filter by.
	
	.EXAMPLE
		PS C:\> Get-AdcExchangeVersion
	
		Return a list of all Exchange Versions
#>
	[CmdletBinding()]
	param (
		[PsfArgumentCompleter('ADMF.Core.ExchangeVersion')]
		[string]
		$Binding,
		
		[string]
		$Name = '*'
	)
	
	process
	{
		if ($Binding) { return $script:exchangeVersionMapping[$Binding] }
		$script:exchangeVersionMapping.Values | Where-Object Name -Like $Name
	}
}