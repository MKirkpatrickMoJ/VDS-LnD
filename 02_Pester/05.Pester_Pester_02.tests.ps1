<#
TASK:
Complete a Pester Test suite for: 04.Pester_PSScript_02.ps1

Utilise the previous Pester.tests.ps1 to help get started.

The primary aim is to ensure that the error handling fails in a predictable way when expected, 
and that the correct error messages are thrown. This will involve testing each parameter
validation and each try/catch block to ensure they are working as intended.
#>

BeforeAll {
	function Invoke-PSScript02 {
		param (
			[string] $TenantId,
			[string] $SourceGroupId,
			[string] $TargetGroupId,
			[string] $HostPoolName,
			[string] $MigrationReason,
			[string] $OutputPath
		)

		. (Join-Path -Path $PSScriptRoot -ChildPath '04.Pester_PSScript_02.ps1') `
			-TenantId $TenantId `
			-SourceGroupId $SourceGroupId `
			-TargetGroupId $TargetGroupId `
			-HostPoolName $HostPoolName `
			-MigrationReason $MigrationReason `
			-OutputPath $OutputPath
	}

	function Connect-MgGraph {}
	function Get-MgGroup {}
	function Get-MgGroupMember {}
	function Get-MgUser {}
	function Remove-MgGroupMemberByRef {}
	function New-MgGroupMemberByRef {}
	function Test-Path {}
	function New-Item {}
	function Add-Content {}
	function Write-Host {}
}

Describe 'Testing 04.Pester_PSScript_02.ps1' {
	BeforeEach {
		$Script:TenantId = '11111111-1111-1111-1111-111111111111'
		$Script:SourceGroupId = '22222222-2222-2222-2222-222222222222'
		$Script:TargetGroupId = '33333333-3333-3333-3333-333333333333'
		$Script:HostPoolName = 'HP-Prod-01'
		$Script:MigrationReason = 'Security governance migration'
		$Script:OutputPath = '.\test-output'

		$Script:MockSourceGroup = [PSCustomObject]@{
			Id = $Script:SourceGroupId
			DisplayName = 'Legacy-AVD-Group'
		}

		$Script:MockTargetGroup = [PSCustomObject]@{
			Id = $Script:TargetGroupId
			DisplayName = 'Governance-AVD-Group'
		}

		$Script:MockUserMember = [PSCustomObject]@{
			Id = '44444444-4444-4444-4444-444444444444'
			AdditionalProperties = @{
				'@odata.type' = '#microsoft.graph.user'
			}
		}

		$Script:MockUser = [PSCustomObject]@{
			Id = '44444444-4444-4444-4444-444444444444'
			DisplayName = 'Demo User'
			UserPrincipalName = 'demo.user@contoso.com'
			AccountEnabled = $true
		}

		Mock -CommandName Connect-MgGraph -MockWith {}
		Mock -CommandName Get-MgGroup -MockWith {
			param($GroupId)

			if ($GroupId -eq $Script:SourceGroupId) {
				return $Script:MockSourceGroup
			}

			if ($GroupId -eq $Script:TargetGroupId) {
				return $Script:MockTargetGroup
			}

			return $null
		}
		Mock -CommandName Get-MgGroupMember -MockWith { @($Script:MockUserMember) }
		Mock -CommandName Get-MgUser -MockWith { $Script:MockUser }
		Mock -CommandName Remove-MgGroupMemberByRef -MockWith {}
		Mock -CommandName New-MgGroupMemberByRef -MockWith {}
		Mock -CommandName Test-Path -MockWith { $true }
		Mock -CommandName New-Item -MockWith {}
		Mock -CommandName Add-Content -MockWith {}
		Mock -CommandName Write-Host -MockWith {}
	}

	Context 'Parameter validation' {
		It 'Should throw if TenantId is missing' {
			{
				Invoke-PSScript02 -TenantId '' -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:TargetGroupId -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Throw 'TenantId parameter is required and cannot be empty.'
		}

		It 'Should throw if TenantId is not a valid GUID' {
			{
				Invoke-PSScript02 -TenantId 'not-a-guid' -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:TargetGroupId -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Throw "TenantId 'not-a-guid' is not a valid GUID*"
		}

		It 'Should throw if SourceGroupId is missing' {
			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId '' -TargetGroupId $Script:TargetGroupId -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Throw 'SourceGroupId parameter is required and cannot be empty.'
		}

		It 'Should throw if TargetGroupId is missing' {
			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId $Script:SourceGroupId -TargetGroupId '' -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Throw 'TargetGroupId parameter is required and cannot be empty.'
		}

		It 'Should throw if SourceGroupId and TargetGroupId are the same' {
			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:SourceGroupId -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Throw 'SourceGroupId and TargetGroupId must be different values.'
		}

		It 'Should throw if HostPoolName is missing' {
			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:TargetGroupId -HostPoolName '' -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Throw 'HostPoolName parameter is required and cannot be empty.'
		}

		It 'Should throw if MigrationReason is missing' {
			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:TargetGroupId -HostPoolName $Script:HostPoolName -MigrationReason '' -OutputPath $Script:OutputPath
			} | Should -Throw 'MigrationReason parameter is required and cannot be empty.'
		}

		It 'Should throw if OutputPath is missing' {
			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:TargetGroupId -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath ''
			} | Should -Throw 'OutputPath parameter is required and cannot be empty.'
		}
	}

	Context 'External operation error handling' {
		It 'Should throw a clear error when Graph connection fails' {
			Mock -CommandName Connect-MgGraph -MockWith { throw 'Auth failed' }

			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:TargetGroupId -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Throw 'Failed to connect to Microsoft Graph*'
		}

		It 'Should throw a clear error when source group lookup fails' {
			Mock -CommandName Get-MgGroup -MockWith {
				param($GroupId)

				if ($GroupId -eq $Script:SourceGroupId) {
					throw 'Source lookup failed'
				}

				if ($GroupId -eq $Script:TargetGroupId) {
					return $Script:MockTargetGroup
				}

				return $null
			}

			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:TargetGroupId -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Throw 'Failed to retrieve source group*'
		}

		It 'Should throw a clear error when target group lookup fails' {
			Mock -CommandName Get-MgGroup -MockWith {
				param($GroupId)

				if ($GroupId -eq $Script:SourceGroupId) {
					return $Script:MockSourceGroup
				}

				if ($GroupId -eq $Script:TargetGroupId) {
					throw 'Target lookup failed'
				}

				return $null
			}

			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:TargetGroupId -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Throw 'Failed to retrieve target group*'
		}

		It 'Should throw when listing source group members fails' {
			Mock -CommandName Get-MgGroupMember -MockWith { throw 'Member query failed' }

			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:TargetGroupId -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Throw 'Failed to list members for source group*'
		}

		It 'Should throw when user lookup fails for a member' {
			Mock -CommandName Get-MgUser -MockWith { throw 'User lookup failed' }

			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:TargetGroupId -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Throw 'Failed to retrieve user details for member*'
		}

		It 'Should throw when group membership migration fails' {
			Mock -CommandName Remove-MgGroupMemberByRef -MockWith { throw 'Remove failed' }

			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:TargetGroupId -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Throw "Failed to migrate user '$($Script:MockUser.UserPrincipalName)'*"
		}

		It 'Should throw when output directory creation fails' {
			Mock -CommandName Test-Path -MockWith { $false }
			Mock -CommandName New-Item -MockWith { throw 'Access denied' }

			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:TargetGroupId -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Throw 'Failed to prepare output directory*'
		}

		It 'Should throw when writing migration log fails' {
			Mock -CommandName Add-Content -MockWith { throw 'Disk full' }

			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:TargetGroupId -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Throw 'Failed to write migration log file*'
		}
	}

	Context 'Successful execution' {
		It 'Should migrate users and write log output when all operations succeed' {
			{
				Invoke-PSScript02 -TenantId $Script:TenantId -SourceGroupId $Script:SourceGroupId -TargetGroupId $Script:TargetGroupId -HostPoolName $Script:HostPoolName -MigrationReason $Script:MigrationReason -OutputPath $Script:OutputPath
			} | Should -Not -Throw

			Should -Invoke -CommandName Connect-MgGraph -Times 1
			Should -Invoke -CommandName Get-MgGroup -Times 2
			Should -Invoke -CommandName Get-MgGroupMember -Times 1
			Should -Invoke -CommandName Get-MgUser -Times 1
			Should -Invoke -CommandName Remove-MgGroupMemberByRef -Times 1
			Should -Invoke -CommandName New-MgGroupMemberByRef -Times 1
			Should -Invoke -CommandName Add-Content -Times 1
		}
	}
}