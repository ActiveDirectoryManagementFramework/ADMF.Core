function Set-AdcRemotingConfig {
	<#
	.SYNOPSIS
		Define the connection settings to use for PS remoting connections to the target.
	
	.DESCRIPTION
		Define the connection settings to use for PS remoting connections to the target.
		Target can be any specific host, domain or subdomain.

		For example, assuming these three targets have settings defined:
		- contoso.com
		- corp.contoso.com
		- dc1.corp.contoso.com

		In this case, the most specific target wins:
		- dc1.corp.contoso.com will select the "dc1.corp.contoso.com" config.
		- dc2.corp.contoso.com will select the "corp.contoso.com" config.
		- dc1.sales.contoso.com will select the "contoso.com" config.
	
	.PARAMETER Target
		The target the configuration applies to.
	
	.PARAMETER Parameters
		Parameters to use when establishing the connection.
		Each key in the hashtable must map to a parameter on "New-PSSession".
		Note: There are different parameters between PowerShell v5.1 and v7+.
	
	.PARAMETER SessionOption
		A PowerShell session option item to apply.
		This allows enabling proxy settings and other connection metadata.
	
	.PARAMETER UseSSH
		Use SSH for the remoting connection.
		Redundant if used with other SSH parameters.
	
	.PARAMETER SshUserName
		The user name to use with SSH sessions.
	
	.PARAMETER SshKeyFilePath
		The path to the key file for authenticating via SSH.
	
	.PARAMETER SshSubsystem
		The Subsystem in the SSH server.
	
	.PARAMETER SshTransport
		Whether to use SSH transport.
	
	.PARAMETER SshOption
		The SSH options to include.
	
	.EXAMPLE
		PS C:\> Set-AdcRemotingConfig -Target contoso.com -SessionOption $option

		Have all remoting connections to DCs in contoso.com use the specified options.

	.EXAMPLE
		PS C:\> Set-AdcRemotingConfig -Target dc1.contoso.com -UseSSH

		Have all remoting connections to DC dc1.contoso.com use SSH.
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PsfArgumentCompleter('ADMF.Core.RemotingTarget')]
		[string]
		$Target,

		[hashtable]
		$Parameters,

		[System.Management.Automation.Remoting.PSSessionOption]
		[AllowNull()]
		$SessionOption,

		[switch]
		$UseSSH,

		[string]
		$SshUserName,

		[string]
		$SshKeyFilePath,

		[string]
		$SshSubsystem,

		[switch]
		$SshTransport,

		[hashtable]
		$SshOption
	)
	process {
		$config = $script:PSRemotingConfig[$Target]
		if (-not $config) {
			$config = [PSCustomObject]@{
				PSTypeName = 'ADMF.Core.RemotingConfig'
				Target     = $Target
				HasOptions = $false
				UseSSH     = $false
				Ssh        = @{}
				Options    = $null
				Parameters = @{}
			}
		}

		if ($UseSSH -or $PSBoundParameters.Keys -match '^Ssh') { $config.UseSSH = $true }
		
		if ($PSBoundParameters.Keys -contains 'SessionOption') {
			if ($SessionOption) {
				$config.UseSSH = $false
				$config.Options = $SessionOption
			}
			else { $config.Options = $null }
		}
		if ($Parameters) {
			$config.Parameters = $Parameters
		}
		if ($PSBoundParameters.Keys -contains 'SshUserName') { $config.Ssh.UserName = $SshUserName }
		if ($PSBoundParameters.Keys -contains 'SshKeyFilePath') { $config.Ssh.KeyFilePath = $SshKeyFilePath }
		if ($PSBoundParameters.Keys -contains 'SshSubsystem') { $config.Ssh.Subsystem = $SshSubsystem }
		if ($PSBoundParameters.Keys -contains 'SshTransport') { $config.Ssh.Transport = $SshTransport.ToBool() }
		if ($PSBoundParameters.Keys -contains 'SshOption') { $config.Ssh.Options = $SshOption }

		$config.HasOptions = $null -ne $config.Options
		$script:PSRemotingConfig[$Target] = $config
	}
}