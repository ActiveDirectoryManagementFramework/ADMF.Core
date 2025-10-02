function Compare-AdcProperty
{
<#
	.SYNOPSIS
		Helper function simplifying the changes processing of Test-* commands.
	
	.DESCRIPTION
		Helper function simplifying the changes processing of Test-* commands.
	
	.PARAMETER Property
		The property to use for comparison.
	
	.PARAMETER Configuration
		The object that was used to define the desired state.
	
	.PARAMETER ADObject
		The AD Object containing the actual state.
	
	.PARAMETER Changes
		An arraylist where changes get added to.
		The content of -Property will be added if the comparison fails.
	
	.PARAMETER Resolve
		Whether the value on the configured object's property should be string-resolved.
	
	.PARAMETER ADProperty
		The property on the ad object to use for the comparison.
		If this parameter is not specified, it uses the value from -Property.
	
	.PARAMETER Parameters
		AD Parameters to pass through for Resolve-String.
	
	.PARAMETER AsString
		Compare properties as string.
		Will convert all $null values to "".

	.PARAMETER AsUpdate
		The result added to the changes arraylist is a custom object with greater details than the default.

	.PARAMETER CaseSensitive
		Property comparisons are executed minding casing of values.

	.PARAMETER IfExists
		If the property compared does not exist on the configured item, return silently.

	.PARAMETER Type
		What kind of component is the compared object part of.
		Used together with the -AsUpdate parameter to name the resulting object.
	
	.EXAMPLE
		PS C:\> Compare-AdcProperty -Property Description -Configuration $ouDefinition -ADObject $adObject -Changes $changes -Resolve
		
		Compares the description on the configuration object (after resolving it) with the one on the ADObject and adds to $changes if they are inequal.
#>
	
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true)]
		[string]
		$Property,

		[Parameter(Mandatory = $true)]
		[object]
		$Configuration,

		[Parameter(Mandatory = $true)]
		[object]
		$ADObject,

		[Parameter(Mandatory = $true)]
		[AllowEmptyCollection()]
		[System.Collections.ArrayList]
		$Changes,

		[switch]
		$Resolve,

		[string]
		$ADProperty,
		
		[hashtable]
		$Parameters = @{ },
		
		[switch]
		$AsString,

		[switch]
		$AsUpdate,

		[switch]
		$CaseSensitive,

		[switch]
		$IfExists,

		[string]
		$Type = 'Unknown'
	)
	
	begin
	{
		if (-not $ADProperty) { $ADProperty = $Property }
	}
	process
	{
		if ($IfExists -and $Configuration.PSObject.Properties.Name -notcontains $Property) { return }

		$param = @{
			Property = $Property
			Identity = $ADObject.DistinguishedName
			Type = $Type
		}
		$propValue = $Configuration.$Property
		if ($Resolve) { $propValue = $propValue | Resolve-String @parameters }

		if (($propValue -is [System.Collections.ICollection]) -and ($ADObject.$ADProperty -is [System.Collections.ICollection])) {
			if (Compare-Object $propValue $ADObject.$ADProperty -CaseSensitive:$CaseSensitive) {
				if ($AsUpdate) { $null = $Changes.Add((New-AdcChange @param -NewValue $propValue -OldValue $ADObject.$ADProperty)) }
				else { $null = $Changes.Add($Property) }
			}
		}
		elseif ($AsString) {
			if ($CaseSensitive) { $result = "$propValue" -cne "$($ADObject.$ADProperty)" }
			else { $result = "$propValue" -ne "$($ADObject.$ADProperty)" }

			if ($result) {
				if ($AsUpdate) { $null = $Changes.Add((New-AdcChange @param -NewValue "$propValue" -OldValue "$($ADObject.$ADProperty)")) }
				else { $null = $Changes.Add($Property) }
			}
		}
		else {
			if ($CaseSensitive) { $result = $propValue -cne $ADObject.$ADProperty }
			else { $result = $propValue -ne $ADObject.$ADProperty }

			if ($result) {
				if ($AsUpdate) { $null = $Changes.Add((New-AdcChange @param -NewValue $propValue -OldValue $ADObject.$ADProperty)) }
				else { $null = $Changes.Add($Property) }
			}
		}
	}
}