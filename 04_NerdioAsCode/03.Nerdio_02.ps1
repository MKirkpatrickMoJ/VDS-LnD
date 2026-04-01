<#
Task 2: Build the request objects required to create a new Nerdio workspace.

Objective:
- Produce a script that can create a workspace request end-to-end.
- You do not need to execute New-NmeWorkspace unless you want to.

Discovery path: #>
Get-Help New-NmeWorkspace -Full

## This will provide the information required to be able to create a new workspace.
## New-NmeWorkspace [-NmeCreateWorkspaceRequest] <Object> [<CommonParameters>]
## Currently, we do not know what NmeCreateWorkspaceRequest is, so we will need to find out how to create this object.
## To find out how to create this object, we can run:

Get-Help New-NmeCreateWorkspaceRequest -Full

## New-NmeCreateWorkspaceRequest [-Id] <PSObject> [-Location] <String> [[-FriendlyName] <String>] [[-Description] <String>] [[-Tags] <Hashtable>] [<CommonParameters>]
## Again, there is a parameter that we do not know how to create, which is the Id parameter. The PARAMETERS section provides
## more information about the Id parameter, and that it is an object of type NmeWvdObjectId.
## To find out how to create this object, we can run:

Get-Help New-NmeWvdObjectId -Full

## New-NmeWvdObjectId [-SubscriptionId] <String> [-ResourceGroup] <String> [-Name] <String> [<CommonParameters>]
## We have now reached a stage where we can be confident what each parameter is.
## Reading the full information about the parameters, provides us with everything we need to continue.

## Using the available information, write a script to connect to:
# 1) Connect to Nerdio
# 2) Create a new workspace
#   a) This will require the creation of an NmeWvdObjectId object and an NmeCreateWorkspaceRequest object

# It is not necessary to actually create the workspace, but the script should be completed to a point
# where the New-NmeWorkspace command can be run without any errors if so desired.