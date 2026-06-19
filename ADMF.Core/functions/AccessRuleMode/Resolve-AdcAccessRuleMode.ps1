function Resolve-AdcAccessRuleMode {
	<#
	.SYNOPSIS
		Resolves the AccessRule processing mode that applies to the specified ADObject.
	
	.DESCRIPTION
		Resolves the AccessRule processing mode that applies to the specified ADObject.
	
	.PARAMETER ADObject
		The AD Object for which to resolve the AccessRule processing mode.
	
	.PARAMETER Server
		The server / domain to work with.
	
	.PARAMETER Credential
		The credentials to use for this operation.
	
	.EXAMPLE
		PS C:\> Resolve-AdcAccessRuleMode @parameters -ADObject $adObject

		Resolves the AccessRule processing mode that applies to the specified ADObject.
	#>
	[OutputType([string])]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$ADObject,

		[PSFComputer]
		$Server,

		[PSCredential]
		$Credential
	)
	
	begin {
		$parameters = $PSBoundParameters | ConvertTo-PSFHashtable -Include Server, Credential
	}
	process {
		if ($script:accessRuleMode.Count -lt 1) { return 'Constrained' }

		$relevantCategories = @()
		if ($script:accessRuleMode.Values.ObjectCategory) {
			$relevantCategories = Resolve-AdcObjectCategory -ADObject $ADObject @parameters
		}

		$applicableModes = :main foreach ($mode in $script:accessRuleMode.Values) {
			if ($mode.Path) {
				try { $resolvedPath = $mode.Path | Resolve-String } # @parameters
				catch {
					Write-PSFMessage -Level Warning -String 'Resolve-AdcAccessRuleMode.PathResolution.Failed' -StringValues $mode.Path -ErrorRecord $_
					$resolvedPath = $mode.Path | Resolve-String
				}
				switch ($mode.PathMode) {
					'SingleItem' {
						if ($ADObject.DistinguishedName -eq $resolvedPath) { $mode }
						continue main
					}
					'SubTree' {
						if ($ADObject.DistinguishedName -like "*$resolvedPath") { $mode }
						continue main
					}
				}
			}
			if ($mode.ObjectCategory -and ($mode.ObjectCategory -in $relevantCategories.Name)) {
				$mode
			}
		}
		
		if ($primaryMode = $applicableModes | Where-Object { $_.Type -eq 'Path' -and $_.PathMode -eq 'SingleItem' }) {
			return $primaryMode.Mode
		}
		if ($secondaryMode = $applicableModes | Where-Object Type -EQ 'Category' | Select-Object -First 1) {
			return $secondaryMode.Mode
		}
		if ($tertiaryMode = $applicableModes | Where-Object { $_.Type -eq 'Path' -and $_.PathMode -eq 'SubTree' } | Sort-Object { $_.Path.Length } -Descending | Select-Object -First 1) {
			return $tertiaryMode.Mode
		}
		return 'Constrained'
	}
}
