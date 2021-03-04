# This is where the strings go, that are written by
# Write-PSFMessage, Stop-PSFFunction or the PSFramework validation scriptblocks
@{
	'Get-LdapObject.SearchError'			 = 'Failed to execute ldap request.' # 
	'Get-LdapObject.Searchfilter'		     = 'Searching with filter: {0}' # $LdapFilter
	'Get-LdapObject.SearchRoot'			     = 'Searching {0} in {1}' # $SearchScope, $searcher.SearchRoot.Path
	
	'Sync-AdcObject.ConnectError'		     = 'Failed to connect to {0}' # $errorObject.TargetObject
	
	'Sync-LdapObject.DestinationAccessError' = 'Failed to connect to destination server {0} | {1}' # $Target, $_
	'Sync-LdapObject.PerformingReplication'  = 'Performing replication from {0} to {1}' # $Server, $Target
	'Sync-LdapObject.SourceAccessError'	     = 'Failed to connect to source server {0} | {1}' # $Server, $_
}