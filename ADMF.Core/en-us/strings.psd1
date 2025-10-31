# This is where the strings go, that are written by
# Write-PSFMessage, Stop-PSFFunction or the PSFramework validation scriptblocks
@{
	'Get-LdapObject.SearchError'             = 'Failed to execute ldap request.' # 
	'Get-LdapObject.Searchfilter'            = 'Searching with filter: {0}' # $LdapFilter
	'Get-LdapObject.SearchRoot'              = 'Searching {0} in {1}' # $SearchScope, $searcher.SearchRoot.Path

	'New-AdcPSSession.Connecting'            = 'Connecting via PS Remoting to {0}' # $ComputerName
	'New-AdcPSSession.Connecting.Config'     = 'Remoting Config used for {0} | Target: {1} | Options: {2} | SSH: {3} | Parameters: {4}' # $ComputerName, $config.Target, $config.HasOptions, $config.UseSSH, @($config.Parameters).Count
	
	'Sync-AdcObject.ConnectError'            = 'Failed to connect to {0}' # $errorObject.TargetObject
	
	'Sync-LdapObject.DestinationAccessError' = 'Failed to connect to destination server {0} | {1}' # $Target, $_
	'Sync-LdapObject.PerformingReplication'  = 'Performing replication from {0} to {1}' # $Server, $Target
	'Sync-LdapObject.SourceAccessError'      = 'Failed to connect to source server {0} | {1}' # $Server, $_

	'Write-AdcChangeLog.ChangeEntry'         = 'Updating {0} from {1} to {2} on {3}' # $change.Property, $change.Old, $change.New, $change.Identity
}