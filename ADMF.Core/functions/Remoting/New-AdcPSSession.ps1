function New-AdcPSSession {
	<#
	.SYNOPSIS
		Establish a new PowerShell remoting session to the target computer.
	
	.DESCRIPTION
		Establish a new PowerShell remoting session to the target computer.
		Respects the configuration provided via Set-AdcRemotingConfig.
	
	.PARAMETER ComputerName
		The computer to connect to.
		Specify thhe full FQDN.
	
	.PARAMETER Credential
		The credentials to use for the connection.
	
	.EXAMPLE
		PS C:\> New-AdcPSSession -ComputerName dc1.contoso.com

		Establish a session to dc1.contoso.com using the settings for either dc1.contoso.com or contoso.com
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSPossibleIncorrectUsageOfAssignmentOperator", "")]
	[CmdletBinding()]
	param (
		[PSFComputer]
		$ComputerName,

		[PSCredential]
		$Credential
	)
	process {
		$credParam = @{}
		if ($Credential) { $credParam.Credential = $Credential }

		$target = "$ComputerName"
		$config = $null
		do {
			if ($config = $script:PSRemotingConfig[$target]) { break }
			$null, $target = $target -split "\.", 2
		}
		while ($target -match '\.')
		
		if (-not $config) {
			Invoke-PSFProtectedCommand -ActionString 'New-AdcPSSession.Connecting' -ActionStringValues $ComputerName -ScriptBlock {
				New-PSSession @credParam -ComputerName $ComputerName -ErrorAction Stop
			} -Target $ComputerName -EnableException $true -PSCmdlet $PSCmdlet
			return
		}

		$param = $config.Parameters | ConvertTo-PSFHashtable -ReferenceCommand New-PSSession
		if ($config.Options) { $param.SessionOption = $config.Options }
		if (-not $config.UseSSH) {
			$param.ComputerName = $ComputerName
			if ($Credential) { $param.Credential = $Credential }
		}
		else {
			$param.HostName = $ComputerName
			if ($config.Ssh.UserName) { $param.UserName = $config.Ssh.UserName }
			if ($config.Ssh.KeyFilePath) { $param.KeyFilePath = $config.Ssh.KeyFilePath }
			if ($config.Ssh.Subsystem) { $param.Subsystem = $config.Ssh.Subsystem }
			if ($config.Ssh.Transport) { $param.SSHTransport = $config.Ssh.Transport }
			if ($config.Ssh.Options.Count -gt 0) { $param.Options = $config.Ssh.Options }
		}

		Write-PSFMessage -Level Debug -String 'New-AdcPSSession.Connecting.Config' -StringValues $ComputerName, $config.Target, $config.HasOptions, $config.UseSSH, $config.Parameters.Count -Target $ComputerName -Data @{ Config = $config }
		Invoke-PSFProtectedCommand -ActionString 'New-AdcPSSession.Connecting' -ActionStringValues $ComputerName -ScriptBlock {
			New-PSSession @param -ErrorAction Stop
		} -Target $ComputerName -EnableException $true -PSCmdlet $PSCmdlet
	}
}