# Variables that should be reset on configuration reload

#----------------------------------------------------------------------------#
#                               Configuration                                #
#----------------------------------------------------------------------------#

# Configured Access Rule processing Modes
$script:accessRuleMode = @{ }

# Configured Object Categories
$script:objectCategories = @{ }

#----------------------------------------------------------------------------#
#                                Cached Data                                 #
#----------------------------------------------------------------------------#

# More principal caching, used by Convert-AdcPrincipal. Mapping to SID or NT Account
$script:cache_PrincipalToSID = @{ }
$script:cache_PrincipalToNT = @{ }

# Cached security principals, used by Get-AdcPrincipal. Mapping to AD Objects
$script:resolvedPrincipals = @{ }

$script:privilegedGroupSets = @{
	DomainAdmins   = @{}
	DomainAdminsEx = @{}
}