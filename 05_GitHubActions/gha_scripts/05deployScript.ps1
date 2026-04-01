<#
    .SYNOPSIS
    Outputs a formatted deployment summary for a given application, version, and environment.

    .DESCRIPTION
    This script writes a deployment summary to the host, including the application name,
    target environment, and version. It also builds and outputs a deployment tag in the
    format: {Application}-{Version}-{Environment} (e.g. "my-app-1.0.0-prod").

    .PARAMETER Environment
    The target environment. Must be 'dev' or 'prod'.

    .PARAMETER Application
    The name of the application being deployed.

    .PARAMETER Version
    The version number or tag being deployed (e.g. '1.0.0' or 'v2.3.1').
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet("dev", "prod")]
    [string]$Environment,

    [Parameter(Mandatory)]
    [string]$Application,

    [Parameter(Mandatory)]
    [string]$Version
)

# TODO: Write the following header line exactly:
#       "===== Deployment Summary ====="

# TODO: Write the following three lines, substituting the parameter values:
#       "Application : <Application>"
#       "Version     : <Version>"
#       "Environment : <Environment>"

# TODO: Build a deployment tag string in the format "<Application>-<Version>-<Environment>"
#       and write it to the host as:
#       "Deployment Tag : <tag>"

$deploymentTag = "$Application-$Version-$Environment"
Write-Host "===== Deployment Summary ====="
Write-Host "Application : $Application"
Write-Host "Version     : $Version"
Write-Host "Environment : $Environment"

Write-Host "Deployment Tag : $deploymentTag"