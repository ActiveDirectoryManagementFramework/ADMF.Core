function Test-Identity {
	<#
	.SYNOPSIS
		Verifies, whether the provided identity reference exists.
		
	.DESCRIPTION
		Verifies, whether the provided identity reference exists.
		Used in the AccessRule component helper tools.
	
	.PARAMETER Identity
		The Identity to resolve.
	
	.PARAMETER ADParameters
		AD connection parameters.
		Offer a hashtable containing server or credentials in any combination.
	
	.EXAMPLE
		PS C:\> Test-Identity -Identity Max.Mustermann -Parameters $param

		Verifies whether the account with SamAccountName "Max.Mustermann" exists
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Identity,

		[hashtable]
		$Parameters = @{}
	)
	process {
		try {
			$null = Resolve-Principal -Name (Convert-BuiltInToSID -Identity $Identity) -OutputType SID @Parameters -ErrorAction Stop -WarningAction SilentlyContinue
			$true
		}
		catch { $false }
	}
}