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

if ([string]::IsNullOrWhiteSpace($TenantId)) {
    throw 'TenantId parameter is required and cannot be empty.'
}

$ParsedTenantGuid = [guid]::Empty
if (-not [guid]::TryParse($TenantId, [ref]$ParsedTenantGuid)) {
    throw "TenantId '$TenantId' is not a valid GUID. Provide a valid Microsoft Entra tenant ID."
}

if ([string]::IsNullOrWhiteSpace($SourceGroupId)) {
    throw 'SourceGroupId parameter is required and cannot be empty.'
}

$ParsedSourceGroupGuid = [guid]::Empty
if (-not [guid]::TryParse($SourceGroupId, [ref]$ParsedSourceGroupGuid)) {
    throw "SourceGroupId '$SourceGroupId' is not a valid GUID."
}

if ([string]::IsNullOrWhiteSpace($TargetGroupId)) {
    throw 'TargetGroupId parameter is required and cannot be empty.'
}

$ParsedTargetGroupGuid = [guid]::Empty
if (-not [guid]::TryParse($TargetGroupId, [ref]$ParsedTargetGroupGuid)) {
    throw "TargetGroupId '$TargetGroupId' is not a valid GUID."
}

if ($SourceGroupId -eq $TargetGroupId) {
    throw 'SourceGroupId and TargetGroupId must be different values.'
}

if ([string]::IsNullOrWhiteSpace($HostPoolName)) {
    throw 'HostPoolName parameter is required and cannot be empty.'
}

if ([string]::IsNullOrWhiteSpace($MigrationReason)) {
    throw 'MigrationReason parameter is required and cannot be empty.'
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    throw 'OutputPath parameter is required and cannot be empty.'
}

Write-Host "Starting host pool group migration for $HostPoolName..."

try {
    Connect-MgGraph -TenantId $TenantId -Scopes 'Group.ReadWrite.All','User.Read.All'
}
catch {
    throw "Failed to connect to Microsoft Graph for tenant '$TenantId'. Confirm the tenant ID and required Graph permissions. Error: $($_.Exception.Message)"
}

try {
    $SourceGroup = Get-MgGroup -GroupId $SourceGroupId
}
catch {
    throw "Failed to retrieve source group '$SourceGroupId'. Confirm the group exists and is accessible. Error: $($_.Exception.Message)"
}

try {
    $TargetGroup = Get-MgGroup -GroupId $TargetGroupId
}
catch {
    throw "Failed to retrieve target group '$TargetGroupId'. Confirm the group exists and is accessible. Error: $($_.Exception.Message)"
}

if (-not $SourceGroup) {
    throw "Source group '$SourceGroupId' was not found in Microsoft Graph."
}

if (-not $TargetGroup) {
    throw "Target group '$TargetGroupId' was not found in Microsoft Graph."
}

try {
    [array]$SourceMembers = Get-MgGroupMember -GroupId $SourceGroup.Id -All
}
catch {
    throw "Failed to list members for source group '$($SourceGroup.DisplayName)' ($($SourceGroup.Id)). Error: $($_.Exception.Message)"
}

$MigrationRows = @()

foreach ($Member in $SourceMembers) {
    if ($Member.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.user') {
        try {
            $User = Get-MgUser -UserId $Member.Id -Property Id,DisplayName,UserPrincipalName,AccountEnabled
        }
        catch {
            throw "Failed to retrieve user details for member '$($Member.Id)'. Error: $($_.Exception.Message)"
        }

        if (-not $User -or [string]::IsNullOrWhiteSpace($User.Id)) {
            throw "User details for member '$($Member.Id)' were not returned by Microsoft Graph."
        }

        try {
            Remove-MgGroupMemberByRef -GroupId $SourceGroup.Id -DirectoryObjectId $User.Id
            New-MgGroupMemberByRef -GroupId $TargetGroup.Id -OdataId "https://graph.microsoft.com/v1.0/directoryObjects/$($User.Id)"
        }
        catch {
            throw "Failed to migrate user '$($User.UserPrincipalName)' from '$($SourceGroup.DisplayName)' to '$($TargetGroup.DisplayName)'. Error: $($_.Exception.Message)"
        }

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

try {
    if (-not (Test-Path -Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
    }
}
catch {
    throw "Failed to prepare output directory '$OutputPath'. Confirm the path is valid and writable. Error: $($_.Exception.Message)"
}

$Date = Get-Date -Format 'yyyy-MM-dd'
$OutputFile = Join-Path -Path $OutputPath -ChildPath "HostPoolGroupMigration_$Date.log"

try {
    foreach ($Row in $MigrationRows) {
        $LogLine = "[$($Row.MigratedAtUtc)] HostPool=$($Row.HostPoolName) | User=$($Row.UserPrincipalName) | SourceGroup=$($Row.SourceGroupName) | TargetGroup=$($Row.TargetGroupName) | Reason=$($Row.MigrationReason)"
        Add-Content -Path $OutputFile -Value $LogLine -Encoding UTF8
    }
}
catch {
    throw "Failed to write migration log file '$OutputFile'. Confirm the file path is writable. Error: $($_.Exception.Message)"
}

Write-Host "Migration complete. Processed $($MigrationRows.Count) users. Migration log written to $OutputFile"
