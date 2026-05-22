# This is where the strings go, that are written by
# Write-PSFMessage, Stop-PSFFunction or the PSFramework validation scriptblocks
@{
	'Compare-AdcAccessRule.Error.BadIdentity'                         = 'Failed to resolve Identity "{1}" configured for "{0}"' # $ADObject, $configuredRule.IdentityReference
	
	'Convert-AdcPrincipal.Processing'                                 = 'Converting principal: {0}' # $Name
	'Convert-AdcPrincipal.Processing.InputNT'                         = 'Input detected as NT: {0}' # $Name
	'Convert-AdcPrincipal.Processing.InputSID'                        = 'Input detected as SID: {0}' # $Name
	'Convert-AdcPrincipal.Processing.NT.LdapFilter'                   = 'Resolving NT identity via AD using the following filter: {0}' # "(samAccountName=$namePart)"
	'Convert-AdcPrincipal.Processing.NTDetails'                       = 'Resolved NT identity: Domain = {0} | Name = {1}' # $domainPart, $namePart

	'ConvertFrom-AdcAccessRuleConfiguration.Identity.ResolutionError' = 'Failed to convert identity "{0}" on "{1}. This generally means a configuration error, especially when referencing the parent as identity.' # $ruleObject.IdentityReference, $ADObject
	
	'Find-AdcObjectCategoryItem.ADError'                              = 'Error retrieving AD Objects for object category {0}' # $Name
	'Find-AdcObjectCategoryItem.Category.NotFound'                    = 'No such object category defined: {0}' # $Name
	
	'Get-AdcPrincipal.Resolution.Failed'                              = 'Failed to resolve principal: SID {0} | Name {1} | ObjectClass {2} | Domain {3}' # $Sid, $Name, $ObjectClass, $Domain
	'Get-AdcPrincipal.Resolution.FailedWithTarget'                    = 'Failed to resolve principal: SID {0} | Name {1} | ObjectClass {2} | Domain {3} | Target {4}' # $Sid, $Name, $ObjectClass, $Domain, $Target
	
	'Get-LdapObject.SearchError'                                      = 'Failed to execute ldap request.' # 
	'Get-LdapObject.Searchfilter'                                     = 'Searching with filter: {0}' # $LdapFilter
	'Get-LdapObject.SearchRoot'                                       = 'Searching {0} in {1}' # $SearchScope, $searcher.SearchRoot.Path

	'Get-PermissionGuidMapping.Processing'                            = 'Processing Permission Guids for domain: {0} (This may take a while)' # $identity
	
	'Get-SchemaGuidMapping.Processing'                                = 'Processing Schema Guids for domain: {0} (This may take a while)' # $identity
	
	'New-AdcPSSession.Connecting'                                     = 'Connecting via PS Remoting to {0}' # $ComputerName
	'New-AdcPSSession.Connecting.Config'                              = 'Remoting Config used for {0} | Target: {1} | Options: {2} | SSH: {3} | Parameters: {4}' # $ComputerName, $config.Target, $config.HasOptions, $config.UseSSH, @($config.Parameters).Count

	'Resolve-AdcAccessRuleMode.PathResolution.Failed'                 = 'Unable to resolve path: {0}' # $mode.Path
	
	
	
	'Sync-AdcObject.ConnectError'                                     = 'Failed to connect to {0}' # $errorObject.TargetObject
	
	'Sync-LdapObject.DestinationAccessError'                          = 'Failed to connect to destination server {0} | {1}' # $Target, $_
	'Sync-LdapObject.PerformingReplication'                           = 'Performing replication from {0} to {1}' # $Server, $Target
	'Sync-LdapObject.SourceAccessError'                               = 'Failed to connect to source server {0} | {1}' # $Server, $_

	'Write-AdcChangeLog.ChangeEntry'                                  = 'Updating {0} from {1} to {2} on {3}' # $change.Property, $change.Old, $change.New, $change.Identity
}