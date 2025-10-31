function Get-AdcRemotingConfig {
	<#
	.SYNOPSIS
		Retrieve the list of remoting configurations.
	
	.DESCRIPTION
		Retrieve the list of remoting configurations.
		Remoting configurations apply to all remote connections via WinRM or - optionally - SSH.
		They can be defined for specific servers or all machines in a domain.

		For more details, see Set-AdcRemotingConfig.
	
	.PARAMETER Target
		The target the settings apply to.
		Defaults to: *
	
	.EXAMPLE
		PS C:\> Get-AdcRemotingConfig

		Retrieve the list of all remoting configurations.
	#>
	[CmdletBinding()]
	param (
		[PsfArgumentCompleter('ADMF.Core.RemotingTarget')]
		[string]
		$Target = '*'
	)
	process {
		($script:PSRemotingConfig.Values | Where-Object Target -Like $Target)
	}
}