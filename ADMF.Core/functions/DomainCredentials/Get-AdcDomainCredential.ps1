function Get-AdcDomainCredential {
	<#
	.SYNOPSIS
		Retrieve credentials stored for accessing the targeted domain.
	
	.DESCRIPTION
		Retrieve credentials stored for accessing the targeted domain.
		Returns nothing when no credentials were stored.
		This is NOT used by the main commands, but internally for retrieving data regarding foreign principals in one-way trusts.
		Generally, these credentials should never have more than reading access to the target domain.
	
	.PARAMETER Domain
		The domain to retrieve credentials for.
		Does NOT accept wildcards.
	
	.EXAMPLE
		PS C:\> Get-AdcDomainCredential -Domain contoso.com

		Returns the credentials for accessing contoso.com, as long as those have previously been stored.
	#>
	[Alias('Get-DMDomainCredential')]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Domain
	)
	
	process {
		if (-not $script:domainCredentialCache) { return }
		$script:domainCredentialCache[$Domain]
	}
}
