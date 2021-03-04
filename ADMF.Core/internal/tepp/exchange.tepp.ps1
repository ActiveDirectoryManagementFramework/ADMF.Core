<#
# Example:
Register-PSFTeppScriptblock -Name "ADMF.Core.alcohol" -ScriptBlock { 'Beer','Mead','Whiskey','Wine','Vodka','Rum (3y)', 'Rum (5y)', 'Rum (7y)' }
#>

Register-PSFTeppScriptblock -Name 'ADMF.Core.ExchangeVersion' -ScriptBlock {
	& (Get-Module ADMF.Core) {
		$script:exchangeVersionMapping.Keys
	}
}