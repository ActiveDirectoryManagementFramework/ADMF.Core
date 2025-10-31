function Clear-AdcConfiguration
{
<#
	.SYNOPSIS
		Resets all configuration settings part of ADMF processing.
	
	.DESCRIPTION
		Resets all configuration settings part of ADMF processing.
		Hard resets its own configuration data.
		Offers an extension point via the PSFCallback system that its dependents should tie in for all logic resetting their own configuration settings.
		Can also be used as an extension point by a management wrapper on top of the ADMF system.
	
		To register your own logic, run the following command:
		Register-PSFCallback -Name MyModule.ConfigurationReset -ModuleName ADMF.Core -CommandName Clear-AdcConfiguration -ScriptBlock $scriptblock
		(replacing "MyModule" with your module's name and defining the logic in $scriptblock)
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> Clear-AdcConfiguration
	
		Resets all configuration settings part of ADMF processing.
#>
	[CmdletBinding()]
	Param (
		[switch]
		$EnableException
	)
	
	process
	{
		Invoke-PSFCallback -PSCmdlet $PSCmdlet -EnableException $EnableException
		& "$script:ModuleRoot\internal\scripts\variables.ps1"
		Clear-StringMapping
	}
}
