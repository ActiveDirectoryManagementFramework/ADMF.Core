function Set-AdcDomainCredential {
	<#
	.SYNOPSIS
		Stores credentials stored for accessing the targeted domain.
	
	.DESCRIPTION
		Stores credentials stored for accessing the targeted domain.
		This is NOT used by the main commands, but internally for retrieving data regarding foreign principals in one-way trusts.
		Generally, these credentials should never have more than reading access to the target domain.
	
	.PARAMETER Domain
		The domain to store credentials for.
		Does NOT accept wildcards.

	.PARAMETER Credential
		The credentials to store.
	
	.EXAMPLE
		PS C:\> Set-AdcDomainCredential -Domain contoso.com -Credential $cred

		Stores the credentials for accessing contoso.com.
	#>
	[Alias('Set-DMDomainCredential')]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Domain,

		[Parameter(Mandatory = $true)]
		[PSCredential]
		$Credential
	)
	
	process {
		if (-not $script:domainCredentialCache) {
			$script:domainCredentialCache = @{ }
		}

		$script:domainCredentialCache[$Domain] = $Credential
	}
}
