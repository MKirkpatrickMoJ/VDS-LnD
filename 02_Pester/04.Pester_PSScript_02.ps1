<#
SCENARIO:
An identity operations team is moving AVD host pool assignment from a legacy Entra group to a new
group that supports updated access governance controls.

This script reads user members from a source group, resolves user details, then migrates each user
to a target group and writes a migration log.

This script is missing validation and error handling.

TASK:
1. Add robust parameter validation
2. Add error handling (try-catch) for all operations that interact with external systems (Graph API calls, file writing)
3. Ensure error messages are clear and actionable

Once done, move onto the associated Pester test file.
#>

[CmdletBinding()]
param (
    [Parameter(HelpMessage='Tenant ID used for Graph connection')]
    [string] $TenantId,
    [Parameter(HelpMessage='Source Entra group object ID (legacy host pool assignment group)')]
    [string] $SourceGroupId,
    [Parameter(HelpMessage='Target Entra group object ID (new host pool assignment group)')]
    [string] $TargetGroupId,
    [Parameter(HelpMessage='Logical host pool assignment name for logging')]
    [string] $HostPoolName,
    [Parameter(HelpMessage='Reason recorded for migration')]
    [string] $MigrationReason = 'Moved to governance-enabled assignment group',
    [Parameter(HelpMessage='Output directory for migration log')]
    [string] $OutputPath = '.\02_Pester'
)

Write-Host "Starting host pool group migration for $HostPoolName..."

Connect-MgGraph -TenantId $TenantId -Scopes 'Group.ReadWrite.All','User.Read.All'

$SourceGroup = Get-MgGroup -GroupId $SourceGroupId
$TargetGroup = Get-MgGroup -GroupId $TargetGroupId

[array]$SourceMembers = Get-MgGroupMember -GroupId $SourceGroup.Id -All

$MigrationRows = @()

foreach ($Member in $SourceMembers) {
    if ($Member.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.user') {
        $User = Get-MgUser -UserId $Member.Id -Property Id,DisplayName,UserPrincipalName,AccountEnabled

        Remove-MgGroupMemberByRef -GroupId $SourceGroup.Id -DirectoryObjectId $User.Id
        New-MgGroupMemberByRef -GroupId $TargetGroup.Id -OdataId "https://graph.microsoft.com/v1.0/directoryObjects/$($User.Id)"

        $MigrationRows += [PSCustomObject]@{
            HostPoolName       = $HostPoolName
            UserId             = $User.Id
            UserPrincipalName  = $User.UserPrincipalName
            DisplayName        = $User.DisplayName
            SourceGroupName    = $SourceGroup.DisplayName
            TargetGroupName    = $TargetGroup.DisplayName
            MigrationReason    = $MigrationReason
            AccountEnabled     = $User.AccountEnabled
            MigratedAtUtc      = (Get-Date).ToUniversalTime().ToString('s') + 'Z'
        }
    }
}

if (-not (Test-Path -Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
}

$Date = Get-Date -Format 'yyyy-MM-dd'
$OutputFile = Join-Path -Path $OutputPath -ChildPath "HostPoolGroupMigration_$Date.log"

foreach ($Row in $MigrationRows) {
    $LogLine = "[$($Row.MigratedAtUtc)] HostPool=$($Row.HostPoolName) | User=$($Row.UserPrincipalName) | SourceGroup=$($Row.SourceGroupName) | TargetGroup=$($Row.TargetGroupName) | Reason=$($Row.MigrationReason)"
    Add-Content -Path $OutputFile -Value $LogLine -Encoding UTF8
}

Write-Host "Migration log written to $OutputFile"
