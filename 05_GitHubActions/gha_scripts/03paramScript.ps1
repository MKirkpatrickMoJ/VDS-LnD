[CmdletBinding()]
param (
    [parameter (Mandatory=$true)][ValidateSet("ping", "tracert", "nslookup")]
    [string]$Action,
    [parameter (Mandatory=$true)]
    [string]$Target = "google.com",
    [parameter (Mandatory=$false)]
    [bool]$DryRun = $false
)

Write-Host "Action : $Action"
Write-Host "Target : $Target"
Write-Host "DryRun : $DryRun"

if ($DryRun -eq $true) {
    Write-Host "This is a dry run. No actions will be performed."
    Write-Host "Would have executed: $Action on $Target"
    Write-Host "Exiting without performing any actions."
    exit 0
}

switch ($Action) {
    "ping" {
        Write-Host "Pinging $Target ..."
        try {
          ping $Target
        }
        catch {
          throw "Error pinging $Target : $_"
        }
    }
    "tracert" {
        Write-Host "Tracing route to $Target ..."
        try{
          tracert $Target
        }
        catch {
          throw "Error tracing route to $Target : $_"
        }
    }
    "nslookup" {
        Write-Host "Performing nslookup for $Target ..."
        try{
          nslookup $Target
        }
        catch {
          throw "Error performing nslookup for $Target : $_"
        }
    }
    default {
        Write-Host "Invalid action specified. Please choose 'ping', 'tracert', or 'nslookup'."
    }
}