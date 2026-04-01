# Using the previous tasks as a guide
# 1) Connect to Nerdio
# 2) Create a new workspace
#   a) putting the commands to variables should allow $_.id to be used in the next steps
# 3) Create a new host pool within the new workspace

# It is not necessary to actually create the workspace or host pool, but the script should be completed to a point
# where the New-NmeWorkspace and New-NmeHostPool commands can be run without any errors if so desired, along with
# necessary pre-requisites.

param (
    [Parameter(mandatory=$true)]
    [string]$clientId,
    [Parameter(mandatory=$true)]
    [string]$clientSecret,
    [Parameter(mandatory=$true)]
    [string]$tenantId,
    [Parameter(mandatory=$true)]
    [string]$apiScope,
    [Parameter(mandatory=$true)]
    [string]$nmeUri,
    [Parameter(mandatory=$true)]
    [string]$subscriptionId,
    [Parameter(mandatory=$true)]
    [string]$RG,
    [Parameter(mandatory=$true)]
    [string]$wsName,
    [Parameter(mandatory=$true)]
    [string]$location,
    [Parameter(mandatory=$true)]
    [string]$friendlyName,
    [Parameter(mandatory=$true)]
    [string]$description
)

connect-nme `
    -clientID $clientId `
    -clientsecret $clientSecret `
    -TenantId $tenantId `
    -ApiScope $apiScope `
    -NmeUri $nmeUri

$nmeWvdObjectId = New-NmeWvdObjectId -SubscriptionId $subscriptionId -ResourceGroup $RG -Name $wsName
$workspaceRequest = New-NmeCreateWorkspaceRequest -Id $nmeWvdObjectId -Location $location -FriendlyName $friendlyName -Description $description
$workspace = New-NmeWorkspace -NmeCreateWorkspaceRequest $workspaceRequest

$hostPoolArmRequest = new-NmeCreateArmHostPoolRequest -WorkspaceId $workspace.ID
New-NmeHostPool -NmeCreateArmHostPoolRequest $hostPoolArmRequest -SubscriptionId $subscriptionId -ResourceGroup $RG -Name "$($wsName)-HP"