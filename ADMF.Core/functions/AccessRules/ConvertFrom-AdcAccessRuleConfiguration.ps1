function ConvertFrom-AdcAccessRuleConfiguration {
	<#
	.SYNOPSIS
		Resolves AccessRule configuration objects.
	
	.DESCRIPTION
		Resolves AccessRule configuration objects.
		For use by Access Rule configurations of both DomainManagement and ForestManagement.
	
	.PARAMETER Rule
		The rule configuration to convert.
	
	.PARAMETER ADObject
		The AD Object the rule applies to.

	.PARAMETER IncludeCategory
		Whether to also return all Object-Category-based rules that apply to the object.

	.PARAMETER CategoryRules
		Access rules defined via Object Categories
	
	.PARAMETER Server
		The server / domain to work with.
	
	.PARAMETER Credential
		The credentials to use for this operation.
	
	.EXAMPLE
		PS C:\> $script:accessRules[$key] | ConvertFrom-AdcAccessRuleConfiguration @parameters -ADObject $adObject -IncludeCategory

		Resolve all configured access rules stored in $script:accessRules[$key], including any applicable rules assigned via Object Category
	#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true)]
		$Rule,

		[Parameter(Mandatory = $true)]
		$ADObject,

		[switch]
		$IncludeCategory,

		[hashtable]
		$CategoryRules,

		[PSFComputer]
		$Server,

		[PSCredential]
		$Credential
	)
	begin {
		$parameters = $PSBoundParameters | ConvertTo-PSFHashtable -Include Server, Credential
		$convertCmdName = { Convert-AdcSchemaGuid @parameters -OutType Name }.GetSteppablePipeline()
		$convertCmdName.Begin($true)
		$convertCmdGuid = { Convert-AdcSchemaGuid @parameters -OutType Guid }.GetSteppablePipeline()
		$convertCmdGuid.Begin($true)

		$explicitRules = [System.Collections.ArrayList]@()
	}
	process {
		foreach ($ruleObject in $Rule) {
			$objectTypeGuid = $convertCmdGuid.Process($ruleObject.ObjectType)[0]
			$objectTypeName = $convertCmdName.Process($ruleObject.ObjectType)[0]
			$inheritedObjectTypeGuid = $convertCmdGuid.Process($ruleObject.InheritedObjectType)[0]
			$inheritedObjectTypeName = $convertCmdName.Process($ruleObject.InheritedObjectType)[0]

			try { $identity = Resolve-AdcAceIdentity @parameters -IdentityReference $ruleObject.IdentityReference -ADObject $ADObject }
			catch {
				if ('True' -ne $ruleObject.Present) { continue }
				Stop-PSFFunction -String 'ConvertFrom-AdcAccessRuleConfiguration.Identity.ResolutionError' -StringValues $ruleObject.IdentityReference, $ADObject -Target $ruleObject -ErrorRecord $_ -Continue
			}

			$rule = [PSCustomObject]@{
				PSTypeName              = 'ADMF.Core.AccessRule.Converted'
				IdentityReference       = $identity
				AccessControlType       = $ruleObject.AccessControlType
				ActiveDirectoryRights   = $ruleObject.ActiveDirectoryRights
				InheritanceFlags        = $ruleObject.InheritanceFlags
				InheritanceType         = $ruleObject.InheritanceType
				InheritedObjectType     = $inheritedObjectTypeGuid
				InheritedObjectTypeName = $inheritedObjectTypeName
				ObjectFlags             = $ruleObject.ObjectFlags
				ObjectType              = $objectTypeGuid
				ObjectTypeName          = $objectTypeName
				PropagationFlags        = $ruleObject.PropagationFlags
				Present                 = $ruleObject.Present
			}
			$null = $explicitRules.Add($rule)
			$rule
		}
	}
	end {
		#region Inject Category-Based rules
		if ($IncludeCategory) {
			Get-AdcCategoryBasedRules -ADObject $ADObject @parameters -ConvertNameCommand $convertCmdName -ConvertGuidCommand $convertCmdGuid -CategoryRules $CategoryRules -ExplicitRules $explicitRules.ToArray()
		}
		#endregion Inject Category-Based rules

		$convertCmdName.End()
		$convertCmdGuid.End()
	}
}