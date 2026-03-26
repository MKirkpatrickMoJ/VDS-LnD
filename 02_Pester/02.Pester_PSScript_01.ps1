<#
SCENARIO:
There's been a request to acquire a regular audit number of hosts within each Host Pool. As this will be ran by an external team
the decision was made to have this ran locally (rather than via pipeline) and output to a local file. To provide assurance of
code quality and sound logic, Pester tests will be created to validate the code.

NOTES ON THE SCRIPT:
Typically, we would NOT pipe in credentials such as passwords. Where secrets are required, this would be done in a 
secure manner - this will be covered in the GitHub Actions module. For the purpose of this exercise, we will be passing in 
credentials as parameters to the script, as we will not be running this script, but testing it via Pester.

Ensure to read through the script and understand the logic and flow, as this will be important when creating the Pester
tests. The script is well commented to assist with this, and provides additional notes on the decisions made and why.

The logic and flow of the script will be documented via write-host statements, so is is always clear where and what the 
script is doing. This will also assist with the Pester tests, as we can validate that the correct write-host statements
are being called.

The script utilises thorough error handling to validate variables are populated and that external calls are successful.
Pester exists to ensure that this is the case and there are no gaps in the logic. The script will be tested to ensure that
it fails when expected and that the correct error messages are thrown.

NOTHING will need to be modified on this PowerShell Script and the actions will need to be taken on:
./02_Pester/02.Pester_PSScript_01.Tests.ps1
#>

[CmdletBinding()]
param (
    [Parameter(HelpMessage='Enter the username to connect with')]
    [string] $User,
    [Parameter(HelpMessage='Enter the password to connect with')]
    [string] $Password,
    [Parameter(HelpMessage='Enter the Tenant ID to connect with')]
    [string] $TenantId,
    [Parameter(HelpMessage='Enter the Subscription ID to connect with')]
    [string] $SubId,
    [Parameter(HelpMessage='Enter the Host Pool naming pattern to filter, e.g. HP-PROD-*')]
    [string] $HpNaming,
    [Parameter(HelpMessage='Enter the directory for the host count report. Default is the current directory')]
    [string] $OutputPath = ".\02_Pester"
)

  $ErrorActionPreference = 'Stop'

  Write-Host "validating parameters..."
###################################
## NOTE: Parameters can be forced to be mandatory by adding the 'Mandatory' attribute to the parameter declaration.
## For the purpose of this exercise, we will not be doing this, as we want to test that the script is validating
## parameters and throwing errors as expected.
##
## eg: [Parameter(Mandatory=$true)] [string] $User
###################################
if ([string]::IsNullOrWhiteSpace($User)) {
  $ErrorUser = "User parameter is required."
  throw $ErrorUser
}
if ([string]::IsNullOrWhiteSpace($Password)) {
  $ErrorPassword = "Password parameter is required."
  throw $ErrorPassword
}
if ([string]::IsNullOrWhiteSpace($TenantId)) {
  $ErrorTenantId = "TenantId parameter is required."
  throw $ErrorTenantId
}
if ([string]::IsNullOrWhiteSpace($SubId)) {
  $ErrorSubId = "SubscriptionId parameter is required."
  throw $ErrorSubId
}
if ([string]::IsNullOrWhiteSpace($HpNaming)) {
  $ErrorHpNaming = "HpNaming parameter is required."
  throw $ErrorHpNaming
}

try {
  Write-Host "Attempting to connect to Azure..."
  Connect-AzAccount `
    -TenantId $TenantId `
    -SubscriptionId $SubId `
    -Credential (New-Object System.Management.Automation.PSCredential($User, (ConvertTo-SecureString $Password -AsPlainText -Force)))
    Write-Host "Successfully connected to Azure." 
}
catch {
  $ErrorConnect = "Error connecting to Azure: $($_.Exception.Message)"
  throw $ErrorConnect
}

try {
  Write-Host "Retrieving Host Pools with naming pattern $HpNaming..."
  [array]$HostPools = Get-AzWvdHostPool | Where-Object { $_.Name -like $HpNaming }
  Write-Host "Successfully retrieved Host Pools. Count: $($HostPools.Count)"
}
catch {
  $ErrorGetHostPools = "Error retrieving Host Pools: $($_.Exception.Message)"
  throw $ErrorGetHostPools
}

if ($HostPools.Count -eq 0) {
  # If no host pools are found, but the call ran successfully, we want to throw an error to indicate
  # that the expected naming convention is not being followed. This stops the script from running and
  # potentially outputting an empty file, which could be misinterpreted as a successful run with no hosts,
  # rather than an issue with the naming convention.
  Throw "No Host Pools found with naming pattern $HpNaming."
}

$HostCount = @()
foreach ($Pool in $HostPools) {
  try {
    Write-Host "Acquiring session host information for host pool: $($Pool.Name)..."
    $Hosts = Get-AzWvdSessionHost -ResourceGroupName $Pool.ResourceGroupName -HostPoolName $Pool.Name
    $HostCount += [PSCustomObject]@{
        HostPool    = $Pool.Name
        HostCount   = $Hosts.Count
    }
    Write-Host "$($Pool.Name) details added to count"
  }
  catch {
    $ErrorSessionHosts = "Error acquiring session host information for hostpool: $($Pool.Name)"
    throw $ErrorSessionHosts
  }
}

$Date = Get-Date -Format "yyyy-MM-dd"
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputPath)
$OutputFile = Join-Path -Path $OutputDirectory -ChildPath "HostPoolCount_$Date.csv"

Write-Host "Ensuring intended file path is valid and accessible..."

$PathTest = Test-Path -Path $OutputDirectory -PathType Container
if (-not $PathTest) {
  $ErrorPath = "The specified output directory is not valid or accessible: $OutputDirectory"
  throw $ErrorPath
}

try {
  Write-Host "Exporting host pool count report to $OutputFile..."
  $HostCount | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
  Write-Host "Report successfully written to $OutputFile"
}
catch {
  $ErrorExport = "Error exporting report: $($_.Exception.Message)"
  throw $ErrorExport  
}