function New-AdcChange {
	<#
	.SYNOPSIS
		Create a new change object.
	
	.DESCRIPTION
		Create a new change object.
		Used for test results in cases where no specialized change objects are intended.
		Mostly used from the internal Compare-Property command.
	
	.PARAMETER Property
		The property being updated
	
	.PARAMETER OldValue
		The previous value the property had
	
	.PARAMETER NewValue
		The new value the property should receive
	
	.PARAMETER Identity
		Identity of the object being updated
	
	.PARAMETER Type
		The object/component type of the object being changed

	.PARAMETER Data
		Additional data to include in the change object.
		Will ignore keys named "Property", "Old", "New" or "Identity"

	.PARAMETER ToString
		Scriptblock that determines, how the change is being displayed when a property itself.
		Defaults to '<property> -> <newvalue>'
		Use $this to refer to the object being displayed.
	
	.EXAMPLE
		PS C:\> New-Change -Property Path -OldValue $adObject.DistinguishedName -NewValue $path -Identity $adObject -Type Object

		Creates a new change object for the path of an object
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Property,

		$OldValue,

		$NewValue,

		[string]
		$Identity,
		
		[string]
		$Type = 'Unknown',

		[hashtable]
		$Data = @{ },

		[scriptblock]
		$ToString = { '{0} -> {1}' -f $this.Property, $this.New }
	)

	$changeHash = @{
		PSTypeName = "ADMF.$Type.Change"
		Property   = $Property
		Old        = $OldValue
		New        = $NewValue
		Identity   = $Identity
	}
	foreach ($pair in $Data.GetEnumerator()) {
		if ($pair.Key -in $changeHash.Keys) { continue }
		$changeHash[$pair.Key] = $pair.Value
	}

	$change = [PSCustomObject]$changeHash
	Add-Member -InputObject $change -MemberType ScriptMethod -Name ToString -Value $ToString -Force -PassThru
}