<#PSScriptInfo
.VERSION 1.0
.AUTHOR Ivo Uenk
.RELEASENOTES

#>
<#
.SYNOPSIS
  Disable all shared mailbox user accounts
.DESCRIPTION
  Disable all shared mailbox user accounts
.NOTES
  Version:        1.0
  Author:         Ivo Uenk
  Creation Date:  2022-04-12
  Purpose/Change: Disable all shared mailbox user accounts

  Install the following modules:
  AzureAD
  ExchangeOnlineManagement

#>

Import-Module 'AzureAD'
Import-Module 'ExchangeOnlineManagement'

# Get the credential from Automation  
$credential = Get-AutomationPSCredential -Name 'AutomationCreds'  
$userName = $credential.UserName  
$securePassword = $credential.Password

$psCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName, $securePassword

# Connect to Microsoft 365 Services
Connect-AzureAD -Credential $psCredential
Connect-ExchangeOnline -Credential $psCredential

# Get all shared mailbox
$allmb = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited

# Set shared mailbox user object in Azure AD to disabled to prevent direct logon
foreach ($mb in $allmb){
  Get-AzureADUser -ObjectId $mb.UserPrincipalName | Where-Object {$_.AccountEnabled -eq $true} | Set-AzureADUser -AccountEnabled $false
  Write-Output "User object for shared mailbox $($mb.UserPrincipalName) disabled"
}