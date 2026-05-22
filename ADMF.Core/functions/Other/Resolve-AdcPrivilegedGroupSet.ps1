function Resolve-AdcPrivilegedGroupSet {
	<#
	.SYNOPSIS
		Resolves a Privileged Group Set for a specified domain.
	
	.DESCRIPTION
		Resolves a Privileged Group Set for a specified domain.
		Results are cached for any given domain the first time, subsequent requests return cached data.
		Cache is cleared when resetting configuration.

		For more details on designing a Privileged Group Set, see the documentation on Register-AdcPrivilegedGroupSet.
	
	.PARAMETER Type
		What Type / Name to resolve the PGS for.
	
	.PARAMETER Server
		The server to resolve the PGS for.
		Alaways resolves to the domain the server is member of, when specifying a specific hostname.
	
	.PARAMETER Credential
		The Credentials to use for the operation
	
	.EXAMPLE
		PS C:\> Resolve-AdcPrivilegedGroupSet -Type DomainAdminsEx -Server contoso.com

		Resolves the DomainAdminsEx PGS for the forest containing contoso.com.
		(The builtin DomainAdminsEx PGS resolves to all Domain Admins of all member Domains as well as the Enterprise Admins)
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Type,

		[Parameter(Mandatory = $true)]
		[string]
		$Server,

		[PSCredential]
		$Credential
	)
	process {
		if ($script:privilegedGroupSets.Keys -notcontains $Type) {
			Stop-PSFFunction -String 'Resolve-AdcPrivilegedGroupSet.Error.UnknownPGS' -StringValues $Type, ($script:privilegedGroupSets.Keys -join ", ") -EnableException $true -Cmdlet $PSCmdlet -Category InvalidArgument
		}
		$parameters = $PSBoundParameters | ConvertTo-PSFHashtable -Include Server, Credential

		$domain = Get-AdcDomain @parameters
		if ($script:privilegedGroupSets[$Type][$domain.DnsRoot]) {
			return $script:privilegedGroupSets[$Type][$domain.DnsRoot]
		}

		Invoke-PSFProtectedCommand -ActionString 'Resolve-AdcPrivilegedGroupSet.Resolving' -ActionStringValues $Type, $domain.DnsRoot -Target $domain.DnsRoot -ScriptBlock {
			$data = & $script:privilegedGroupSetCalculators[$Type].Code $parameters $domain
		} -EnableException $true -PSCmdlet $PSCmdlet

		$sids = foreach ($sid in $data.SIDs) {
			if ($sid -as [System.Security.Principal.SecurityIdentifier]) {
				"$sid"
			}
		}
		if (-not $sids) {
			Stop-PSFFunction -String 'Resolve-AdcPrivilegedGroupSet.Error.NoSids' -StringValues $Type, $domain.DnsRoot -EnableException $true -Cmdlet $PSCmdlet -Category ObjectNotFound -Target $data
		}
		if (-not ($data.DefaultSID -as [System.Security.Principal.SecurityIdentifier])) {
			Stop-PSFFunction -String 'Resolve-AdcPrivilegedGroupSet.Error.NoDefaultSid' -StringValues $Type, $domain.DnsRoot -EnableException $true -Cmdlet $PSCmdlet -Category ObjectNotFound -Target $data
		}

		$newData = @{
			SIDs       = $sids
			DefaultSID = $data.DefaultSID -as [string]
		}

		$script:privilegedGroupSets[$Type][$domain.DnsRoot] = $newData
		$newData
	}
}