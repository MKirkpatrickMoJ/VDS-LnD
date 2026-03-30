<#
Task 1: Connect to Nerdio Manager using the Nerdio PowerShell module.

What this exercise covers:
1. Discovering cmdlets in the module.
2. Reading cmdlet help to understand parameters.
3. Connecting without hardcoding secrets.

Helpful discovery commands:
Get-Command -Module NerdioManagerPowerShell
Get-Help New-NmeWorkspace -Full

Note that the -Full switch provides detailed information about the command, without this, the 
information can sometimes be limited.

To use the PowerShell Module, you must connect to the Nerdio Manager.

You need to retrieve the required parameters from your Nerdio Manager deployment. 
You can find these in the Nerdio Manager portal under Settings > Environment >  Integrations > REST API
#>


# This is one way to script the connection without hardcoding the parameters preventing secret values from entering
# into the codebase. These values should NEVER be hardcoded into the codebase, as they are sensitive values that
# could be used to access your Nerdio Manager environment.

$NmeClientId      = Read-Host "Enter the Client ID for your Nerdio Manager API application"
$NmeClientSecret  = Read-Host "Enter the Client Secret for your Nerdio Manager API application"
$NmeTenantId      = Read-Host "Enter the Tenant ID for your Nerdio Manager API application"
$NmeScope         = Read-Host "Enter the API Scope for your Nerdio Manager API application"
$NmeUri           = Read-Host "Enter the URI for your Nerdio Manager API application"

Connect-NME `
  -ClientId $NmeClientId `
  -ClientSecret $NmeClientSecret `
  -TenantId $NmeTenantId `
  -ApiScope $NmeScope `
  -NmeUri $NmeUri

### In production environments, you would ideally run these commands through a pipeline/workflow that
### can securely store, retrieve, and pass these parameters to the command without human interaction.

### Once connected, you can run any of the commands in the module. For example, to get a list of all
### workspaces in your Nerdio Manager environment, you can run:

Get-NmeWorkspace