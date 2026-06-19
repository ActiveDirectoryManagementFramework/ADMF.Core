function Get-AdcCategoryBasedRules {
	<#
	.SYNOPSIS
		Returns all access rules applicable to an ad object via category rules.
	
	.DESCRIPTION
		Returns all access rules applicable to an ad object via category rules.
	
	.PARAMETER ADObject
		The AD Object for which to resolve access rules by category.
	
	.PARAMETER Server
		The server / domain to work with.
	
	.PARAMETER Credential
		The credentials to use for this operation.
	
	.PARAMETER ConvertNameCommand
		A steppable pipeline wrapping Convert-AdcSchemaGuid converting to name.
	
	.PARAMETER ConvertGuidCommand
		A steppable pipeline wrapping Convert-AdcSchemaGuid converting to guid.

	.PARAMETER CategoryRules
		All access rules defined via Object Categories.
		These are compared against the list of ObjectCategories that apply to the object and then - if applicable - converted to access rules.

	.PARAMETER ExplicitRules
		Explicitly assigned rules by configuration via Path.
		Path-based assignment overrides category-based assignment.
	
	.EXAMPLE
		PS C:\> Get-AdcCategoryBasedRules -ADObject $foundADObject @parameters -ConvertNameCommand $convertCmdName -ConvertGuidCommand $convertCmdGuid

		Returns all access rules applicable to $foundADObject via category rules.
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$ADObject,

		[PSFComputer]
		$Server,

		[PSCredential]
		$Credential,

		$ConvertNameCommand,

		$ConvertGuidCommand,

		[hashtable]
		$CategoryRules,

		$ExplicitRules
	)

	$parameters = $PSBoundParameters | ConvertTo-PSFHashtable -Include ADObject, Server, Credential

	$resolvedCategories = Resolve-AdcObjectCategory @parameters
	$processedRules = foreach ($resolvedCategory in $resolvedCategories) {
		:byRule foreach ($ruleObject in $CategoryRules[$resolvedCategory.Name]) {
			$objectTypeGuid = $ConvertGuidCommand.Process($ruleObject.ObjectType)[0]
			$objectTypeName = $ConvertNameCommand.Process($ruleObject.ObjectType)[0]
			$inheritedObjectTypeGuid = $ConvertGuidCommand.Process($ruleObject.InheritedObjectType)[0]
			$inheritedObjectTypeName = $ConvertNameCommand.Process($ruleObject.InheritedObjectType)[0]

			try { $identity = Resolve-AdcAceIdentity @parameters -IdentityReference $ruleObject.IdentityReference }
			catch { Stop-PSFFunction -String 'Get-AdcCategoryBasedRules.Identity.ResolutionError' -StringValues $ruleObject.IdentityReference, $resolvedCategory.Name -Target $ruleObject -ErrorRecord $_ -Continue }

			$categoryRule = [PSCustomObject]@{
				PSTypeName              = 'DomainManagement.AccessRule.Converted'
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
			# Path-based rules take precedence, when they attempt to do the exact same thing.
			# Mostly so an explicit "Present = $false" can be applied to override a far-reaching category
			foreach ($rule in $ExplicitRules) {
				if (Test-AdcAccessRuleEquality -Rule1 $rule -Rule2 $categoryRule -Parameters $parameters) {
					continue byRule
				}
			}
			$categoryRule
		}
	}

	# When two category-rules clash, the Present = $false rule wins
	$nonPresent = $processedRules | Where-Object Present -EQ 'False'
	$present = $processedRules | Where-Object Present -NE 'False'

	:main foreach ($rule in $present) {
		foreach ($denyRule in $nonPresent) {
			if (Test-AdcAccessRuleEquality -Rule1 $rule -Rule2 $denyRule -Parameters $parameters) {
				continue main
			}
		}
		$rule
	}
	$nonPresent
}