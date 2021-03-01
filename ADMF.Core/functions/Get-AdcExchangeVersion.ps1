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
	
	begin {
		$selectAliases = @(
			'SchemaVersion as RangeUpper'
			'ConfigurationVersion as ObjectVersionConfig'
			'DomainVersion as ObjectVersionDomain'
		)
	}
	process
	{
		if ($Binding) { return $script:exchangeVersionMapping[$Binding] | Select-PSFObject -KeepInputObject -Alias $selectAliases -TypeName 'ADMF.Core.ExchangeVersion' }
		$script:exchangeVersionMapping.Values | Where-Object Name -Like $Name | Sort-Object @(
			{ $_.Name -replace '^Exchange (\d+).+$','$1'}
			'SchemaVersion'
			'ConfigurationVersion'
			'DomainVersion'
			{ $_.Name -replace '^.+?(\d+)$','$1' -as [int] }
			'Name'
		) | Select-PSFObject -KeepInputObject -Alias $selectAliases -TypeName 'ADMF.Core.ExchangeVersion'
	}
}