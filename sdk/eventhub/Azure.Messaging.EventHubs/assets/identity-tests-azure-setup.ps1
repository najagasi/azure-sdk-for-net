# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
  .SYNOPSIS
    Performs the tasks needed to setup a service principal to perform authentication against 
    Azure Active Directory and sets the roles needed to access Event Hubs's resources.

  .DESCRIPTION
    This script handles creation and configuration of a service principal and the role 
    "Azure Event Hubs Data Owner" to it.
    
    Upon completion, the script will output a set of environment variables with sensitive information which
    are used for testing.  When running Live tests, please be sure to have these environment variables available,
    either within Visual Studio or command line environment.
 
    For more detailed help, please use the -Help switch. 
#>

# =======================
# == Script Parameters ==
# =======================

[CmdletBinding(DefaultParameterSetName="Help")] 
[OutputType([String])] 
param
( 
  [Parameter(Mandatory=$true, ParameterSetName="Help", Position=0)]
  [Switch] $Help,

  [Parameter(Mandatory=$true, ParameterSetName="Execute", Position=0)]
  [ValidateNotNullOrEmpty()]
  [string] $SubscriptionName,

  [Parameter(Mandatory=$true, ParameterSetName="Execute")]
  [ValidateNotNullOrEmpty()]
  [string] $ResourceGroupName,

  [Parameter(Mandatory=$true, ParameterSetName="Execute")]
  [ValidateNotNullOrEmpty()]
  [ValidateScript({ $_.Length -ge 6})]
  [string] $ServicePrincipalName
)

# =====================
# == Module Imports  ==
# =====================

Import-Module Az.Resources

# ==========================
# == Function Definitions ==
# ==========================

. .\functions\live-tests-functions.ps1

# ====================
# == Script Actions ==
# ====================

if ($Help)
{
  DisplayHelp $Defaults
  exit 0
}

if ([String]::IsNullOrEmpty($AzureRegion))
{
    $AzureRegion = "southcentralus"
}

# Disallow principal names with a space.

if ($ServicePrincipalName.Contains(" "))
{
    Write-Error "The principal name may not contain spaces."
    exit -1
}

# Verify the location is valid for an Event Hubs namespace.

$validLocations = @{}
Get-AzLocation | where { $_.Providers.Contains("Microsoft.EventHub")} | ForEach { $validLocations[$_.Location] = $_.Location }

if (!$validLocations.Contains($AzureRegion))
{
    Write-Error "The Azure region must be one of: `n$($validLocations.Keys -join ", ")`n`n" 
    exit -1
}

# Capture the subscription.  The cmdlet will error if there was no subscription, 
# so no need to validate.

Write-Host ""
Write-Host "Working:"
Write-Host "`t...Requesting subscription"
$subscription = (Get-AzSubscription -SubscriptionName "$($SubscriptionName)" -ErrorAction SilentlyContinue)

if ($subscription -eq $null)
{
    Write-Error "Unable to locate the requested Azure subscription: $($SubscriptionName)"
    exit -1
}

Set-AzContext -SubscriptionId "$($subscription.Id)" -Scope "Process" | Out-Null

# Create the resource group, if needed.

Write-Host "`t...Requesting resource group"

$createResourceGroup = $false
$resourceGroup = (Get-AzResourceGroup -ResourceGroupName "$($ResourceGroupName)" -ErrorAction SilentlyContinue)

if ($resourceGroup -eq $null)
{
    $createResourceGroup = $true
}

if ($createResourceGroup)
{
    Write-Host "`t...Creating new resource group"
    $resourceGroup = (New-AzResourceGroup -Name "$($ResourceGroupName)" -Location "$($AzureRegion)")
}

if ($resourceGroup -eq $null)
{
    Write-Error "Unable to locate or create the resource group: $($ResourceGroupName)"
    exit -1
}

# At this point, we may have created a resource, so be safe and allow for removing any
# resources created should the script fail.

try 
{
    # Create the service principal and grant contributor access for management in the resource group.

    Write-Host "`t...Creating new service principal"
    Start-Sleep 1

    $credentials = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{StartDate=Get-Date; EndDate=Get-Date -Year 2099; Password="$(GenerateRandomPassword)"}            
    $principal = (New-AzADServicePrincipal -DisplayName "$($ServicePrincipalName)" -PasswordCredential $credentials)

    if ($principal -eq $null)
    {
        Write-Error "Unable to create the service principal: $($ServicePrincipalName)"
        TearDownResources $createResourceGroup
        exit -1
    }
    
    Write-Host "`t...Assigning permissions (this will take a moment)"
    Start-Sleep 60

    # The propagation of the identity is non-deterministic.  Attempt to retry once after waiting for another minute if
    # the initial attempt fails.

    try 
    {
        New-AzRoleAssignment -ApplicationId "$($principal.ApplicationId)" -RoleDefinitionName "Contributor" -ResourceGroupName "$($ResourceGroupName)" | Out-Null
    }
    catch 
    {
        Write-Host "`t...Still waiting for identity propagation (this will take a moment)"
        Start-Sleep 60
        New-AzRoleAssignment -ApplicationId "$($principal.ApplicationId)" -RoleDefinitionName "Contributor" -ResourceGroupName "$($ResourceGroupName)" | Out-Null
    }    

    # Write the environment variables.

    Write-Host "Done."
    Write-Host ""
    Write-Host ""
    Write-Host "EVENT_HUBS_RESOURCEGROUP=$($ResourceGroupName)"
    Write-Host ""
    Write-Host "EVENT_HUBS_SUBSCRIPTION=$($subscription.SubscriptionId)"
    Write-Host ""
    Write-Host "EVENT_HUBS_TENANT=$($subscription.TenantId)"
    Write-Host ""
    Write-Host "EVENT_HUBS_CLIENT=$($principal.ApplicationId)"
    Write-Host ""
    Write-Host "EVENT_HUBS_SECRET=$($credentials.Password)"
    Write-Host ""
}
catch 
{
    Write-Error $_.Exception.Message
    TearDownResources $createResourceGroup
    exit -1
}