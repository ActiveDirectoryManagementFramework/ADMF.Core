function Sync-AdcObject
{
<#
	.SYNOPSIS
		Replicate a single item between DCs.
	
	.DESCRIPTION
		Replicate a single item between DCs.
		Can use either WinRM or LDAP to trigger a bulk sync of a single object in parallel.
	
		Use this command to ensure a specific object in AD has been replicated across all targeted DCs.
	
	.PARAMETER Object
		The object to replicate.
		Must be a distinguishedName.
	
	.PARAMETER Source
		The server that contains the current state of the targeted object.
	
	.PARAMETER Target
		The server(s) that should receive the latest updates for the targeted object.
	
	.PARAMETER Credential
		Credentials tro use for authenticating the operation.
	
	.PARAMETER Type
		Which protocl should be used to trigger the replication.
		Can use either LDAP or WinRM, defaults to LDAP.
	
	.EXAMPLE
		PS C:\> Sync-AdcObject -Object $userAccount -Source $pdc -Target (Get-ADComputer -LdapFilter "(&(primaryGroupID=516)(!(name=$pdc)))").DNSHostName
	
		Replicates the AD object stored in $userAccount across all domain controllers in the current domain.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Object,
		
		[Parameter(Mandatory = $true)]
		[string]
		$Source,
		
		[Parameter(Mandatory = $true)]
		[string[]]
		$Target,
		
		[PSCredential]
		$Credential,
		
		[ValidateSet('LDAP','WinRM')]
		[string]
		$Type = 'LDAP'
	)
	
	begin
	{
		$credParam = $PSBoundParameters | ConvertTo-PSFHashtable -Include Credential
	}
	process
	{
		$results = switch ($Type) {
			#region LDAP-triggered replication
			'LDAP'
			{
				$adObject = Get-ADObject @credParam -Identity $Object -Server $Source -Properties ObjectGUID
				Sync-LdapObjectParallel @credParam -Object $adObject.ObjectGUID -Server $Target -Target $Source
			}
			#endregion LDAP-triggered replication
			#region WinRM-triggered replication
			'WinRM'
			{
				Invoke-PSFCommand @credParam -ComputerName $Target -ScriptBlock {
					param (
						$TargetDC,
						
						$ADObject
					)
					
					$message = repadmin.exe /replsingleobj $env:COMPUTERNAME $TargetDC $ADObject *>&1
					$result = 0 -eq $LASTEXITCODE
					
					[PSCustomObject]@{
						ComputerName = $env:COMPUTERNAME
						Success	     = $result
						Message	     = ($message | Where-Object { $_ })
						ExitCode	 = $LASTEXITCODE
						Error	     = $null
					}
				} -ArgumentList $Source, $Object -ErrorVariable errorVar -ErrorAction SilentlyContinue | Select-PSFObject -KeepInputObject -TypeName 'ADMF.Core.SyncResult'
				
				foreach ($errorObject in $errorVar) {
					Write-PSFMessage -Level Warning -String 'Sync-AdcObject.ConnectError' -StringValues $errorObject.TargetObject -ErrorRecord $errorObject
					[PSCustomObject]@{
						PSTypeName   = 'ADMF.Core.SyncResult'
						ComputerName = $errorObject.TargetObject
						Success	     = $false
						Message	     = $errorObject.Exception.Message
						ExitCode	 = 1
						Error	     = $errorObject
					}
				}
			}
			#endregion WinRM-triggered replication
		}
		
		[PSCustomObject]@{
			Success = $results.Success -notcontains $false
			SuccessPercent = $results.Where{ $_.Success }.Count / $Target.Count * 100
			Results = $results
			ServerSuccess = $results.Where{ $_.Success }.ComputerName
			ServerFailed = $results.Where{ -not $_.Success }.ComputerName
		}
	}
}