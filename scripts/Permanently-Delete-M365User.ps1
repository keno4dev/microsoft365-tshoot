# Permanently-Delete-M365User.ps1
#
# Description: Interactively soft-deletes and then hard-deletes a Microsoft 365
#              user account from both the active directory and the recycle bin.
#
# Usage:
#   .\Permanently-Delete-M365User.ps1
#
# Prerequisites:
#   - MSOnline module: Install-Module MSOnline
#   - Run as an account with User Management Admin or Global Admin privilege

Connect-MsolService

$Upn = Read-Host -Prompt "Enter the user account Email (UPN)"

# Step 1: Soft delete (moves to recycle bin — 30-day recovery window)
Remove-MsolUser -UserPrincipalName $Upn

# Step 2: Hard delete (remove from recycle bin permanently)
Remove-MsolUser -UserPrincipalName "$Upn" -RemoveFromRecycleBin

# Confirm deletion
Get-MsolUser -All | Sort-Object DisplayName | Select-Object DisplayName, UserPrincipalName

Write-Host "USER ACCOUNT $Upn HAS BEEN PERMANENTLY DELETED" -ForegroundColor Red
