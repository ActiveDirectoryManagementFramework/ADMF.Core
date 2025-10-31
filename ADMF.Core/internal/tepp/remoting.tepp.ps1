Register-PSFTeppScriptblock -Name 'ADMF.Core.RemotingTarget' -ScriptBlock {
	(Get-AdcRemotingConfig).Target
} -Global