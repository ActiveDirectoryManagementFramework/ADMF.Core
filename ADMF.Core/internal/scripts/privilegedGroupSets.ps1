$param = @{
	Name        = 'DomainAdmins'
	Description = 'Any domain admin group in the Forest. Defaults to the Domain Admins of the Forest Root Domain.'
	Code        = {
		param (
			$Parameters,
			$Domain
		)

		$forest = Get-ADForest @Parameters
		$domains = $forest | ForEach-Object Domains | Get-ADDomain @Parameters
		$rootDomain = $domains | Where-Object DnsRoot -EQ $forest.RootDomain
		@{
			SIDs       = $domains.DomainSID | Format-String '{0}-512'
			DefaultSID = '{0}-512' -f $rootDomain.DomainSID
		}
	}
}
Register-AdcPrivilegedGroupSet @param

$param = @{
	Name        = 'DomainAdminsEx'
	Description = 'Any domain admin group in the Forest or the Enterprise Admins group of the Forest Root Domain. Defaults to the Enterprise Admins of the Forest Root Domain.'
	Code        = {
		param (
			$Parameters,
			$Domain
		)

		$forest = Get-ADForest @Parameters
		$domains = $forest | ForEach-Object Domains | Get-ADDomain @Parameters
		$rootDomain = $domains | Where-Object DnsRoot -EQ $forest.RootDomain
		@{
			SIDs       = @($domains.DomainSID | Format-String '{0}-512') + "$($rootDomain.DomainSID)-519"
			DefaultSID = '{0}-519' -f $rootDomain.DomainSID
		}
	}
}
Register-AdcPrivilegedGroupSet @param