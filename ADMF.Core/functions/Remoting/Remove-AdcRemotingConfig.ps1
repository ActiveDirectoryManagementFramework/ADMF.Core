function Remove-AdcRemotingConfig {
	<#
	.SYNOPSIS
		Removes a powershell remoting configuration.
	
	.DESCRIPTION
		Removes a powershell remoting configuration.
		Use Set-AdcRemotingConfig to define how connections to a target are established when calling New-AdcPSSession.
	
	.PARAMETER Target
		The target the configuration applies to.
	
	.EXAMPLE
		PS C:\> Remove-AdcRemotingConfig -Target contoso.com

		Removes a powershell remoting configuration targeting contoso.com.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfArgumentCompleter('ADMF.Core.RemotingTarget')]
		[string]
		$Target
	)
	process {
		$null = $script:PSRemotingConfig.Remove($Target)
	}
}