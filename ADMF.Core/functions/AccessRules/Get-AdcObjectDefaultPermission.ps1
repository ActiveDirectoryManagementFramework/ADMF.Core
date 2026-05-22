function Get-AdcObjectDefaultPermission {
	<#
	.SYNOPSIS
		Gathers the default object permissions in AD.
	
	.DESCRIPTION
		Gathers the default object permissions in AD.
		Uses PowerShell remoting against the SchemaMaster to determine the default permissions, as local identity resolution is not reliable.
	
	.PARAMETER ObjectClass
		The object class to look up.
	
	.PARAMETER Server
		The server / domain to work with.
	
	.PARAMETER Credential
		The credentials to use for this operation.
	
	.EXAMPLE
		PS C:\> Get-AdcObjectDefaultPermission -ObjectClass user

		Returns the default permissions for a user.
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
	[Alias('Get-DMObjectDefaultPermission')]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$ObjectClass,

		[PSFComputer]
		$Server = '<Default>',

		[PSCredential]
		$Credential
	)
	
	begin {
		if (-not $script:schemaObjectDefaultPermission) {
			$script:schemaObjectDefaultPermission = @{ }
		}

		$parameters = $PSBoundParameters | ConvertTo-PSFHashtable -Include Server, Credential

		#region Scriptblock that gathers information on default permission
		$gatherScript = {
			$parameters = @{ Server = $env:COMPUTERNAME }
			$rootDSE = Get-ADRootDSE @parameters
			$classes = Get-ADObject @parameters -SearchBase $rootDSE.schemaNamingContext -LDAPFilter '(objectCategory=classSchema)' -Properties defaultSecurityDescriptor, lDAPDisplayName
			foreach ($class in $classes) {
				$acl = [System.DirectoryServices.ActiveDirectorySecurity]::new()
				$acl.SetSecurityDescriptorSddlForm($class.defaultSecurityDescriptor)
				
				$access = foreach ($accessRule in $acl.Access) {
					try { Add-Member -InputObject $accessRule -MemberType NoteProperty -Name SID -Value $accessRule.IdentityReference.Translate([System.Security.Principal.SecurityIdentifier]) }
					catch {
						# Do nothing, don't want the property if no SID is to be had
					}
					$accessRule
				}
				
				# Workaround to prevent serialization issue. The $null of a loop return converts into an empty PSCustomObject, rather than actually being null, when serialized and deserialized.
				if (-not $access) { $access = $null }

				[PSCustomObject]@{
					Class  = $class.lDAPDisplayName
					Access = $access
				}
			}
		}
		#endregion Scriptblock that gathers information on default permission
	}
	process {
		if ($script:schemaObjectDefaultPermission["$Server"]) {
			return $script:schemaObjectDefaultPermission["$Server"].$ObjectClass
		}

		#region Process Gathering logic
		if ($Server -ne '<Default>') {
			$parameters['ComputerName'] = $parameters.Server
			$parameters.Remove("Server")
		}
		
		try { $data = Invoke-PSFCommand @parameters -ScriptBlock $gatherScript -ErrorAction Stop }
		catch { throw }
		$script:schemaObjectDefaultPermission["$Server"] = @{ }
		foreach ($datum in $data) {
			$script:schemaObjectDefaultPermission["$Server"][$datum.Class] = $datum.Access
		}
		$script:schemaObjectDefaultPermission["$Server"].$ObjectClass
		#endregion Process Gathering logic
	}
}