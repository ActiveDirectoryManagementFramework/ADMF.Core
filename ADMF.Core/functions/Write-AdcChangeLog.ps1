function Write-AdcChangeLog {
	<#
	.SYNOPSIS
		Writes a log entry for change objects.
	
	.DESCRIPTION
		Writes a log entry for change objects.
		This is designed to provide standardized logging for changes being applied.

		Use New-AdcChange to generate a change object in the format expected by this command.
	
	.PARAMETER Changes
		The list of changes to log
	
	.EXAMPLE
		PS C:\> Write-AdcChangeLog -Changes $testItem.Changed
		
		Writes log entries, one for each change in the $testItem variable.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[AllowEmptyCollection()]
		[AllowNull()]
		$Changes
	)

	begin {
		$param = @{
			Level  = 'SomewhatVerbose'
			String = 'Write-AdcChangeLog.ChangeEntry'
			Tag    = 'change'
		}
	}

	process {
		foreach ($change in $Changes) {
			Write-PSFMessage @param -StringValues $change.Property, $change.Old, $change.New, $change.Identity -Target $change -Data ($change | ConvertTo-PSFHashtable)
		}
	}
}