# User Management

> **Category:** User Lifecycle, Identity  
> **Applies to:** Microsoft 365, Azure AD / Entra ID, Exchange Online

---

## 1. Permanently Delete a Microsoft 365 User via PowerShell

```powershell
Connect-MsolService

# Prompt for the user's UPN
$Upn = Read-Host -Prompt "Enter user account Email"

# Soft delete (moves to recycle bin — recoverable for 30 days)
Remove-MsolUser -UserPrincipalName $Upn

# Hard delete (permanently removes from recycle bin)
Remove-MsolUser -UserPrincipalName "$Upn" -RemoveFromRecycleBin

# Confirm deletion by listing all users
Get-MsolUser -All | Sort-Object DisplayName | Select-Object DisplayName, UserPrincipalName

Write-Host "USER ACCOUNT $Upn PERMANENTLY DELETED"
```

> **Warning:** This action cannot be undone. Always confirm the correct UPN before proceeding.

---

## 2. Bulk Change Domain Name for Multiple Users

### Scenario
You need to migrate users from one domain (e.g., `contoso.onmicrosoft.com`) to a new custom domain (e.g., `contoso.com`).

### Step 1 — Connect and Export Existing Users

```powershell
Install-Module MSOnline
Import-Module MSOnline
Connect-MsolService

# Export UPNs to CSV
Get-MsolUser | Select-Object UserPrincipalName | Export-Csv "C:\users.csv" -NoTypeInformation
```

### Step 2 — Edit the CSV

Add a second column `EmailAddress` with the new domain-mapped address:

```csv
UserPrincipalName,EmailAddress
john.doe@contoso.onmicrosoft.com,john.doe@contoso.com
jane.smith@contoso.onmicrosoft.com,jane.smith@contoso.com
```

### Step 3 — Run the Domain Change Script

> **Note:** This script requires **PowerShell ISE** to run correctly.

```powershell
$Usersdatabase = Import-Csv "C:\Users\admin\users.csv"

foreach ($record in $Usersdatabase) {
    $upn   = $record.UserPrincipalName
    $email = $record.EmailAddress
    Write-Host "Setting $upn to $email"
    Set-MsolUserPrincipalName -UserPrincipalName $upn -NewUserPrincipalName $email
    Write-Host ".."
}
```

---

## 3. Bulk Password Reset via CSV

```powershell
$Usersdatabase = Import-Csv "C:\Users\admin\Documents\users.csv"

foreach ($record in $Usersdatabase) {
    $upn         = $record.UserPrincipalName
    $newPassword = "MyP@55w0rd!"
    Set-MsolUserPassword -UserPrincipalName $upn -NewPassword $newPassword
}
```

> **Best practice:** Use a unique generated password per user and force a password change at next sign-in.

---

## 4. Check User Login & Logoff Times

### Last Logon / Logoff via PowerShell

```powershell
Get-MailboxStatistics -Identity "user@contoso.com" | Select LastLogonTime, LastLogoffTime
```

### Sign-in Logs via Azure AD Portal

1. Navigate to: `Azure Active Directory Admin Center`
2. Go to: `Users → [Select User] → Sign-in logs`

> **Note:** Sign-in logs show **login timestamps**; logoff times require the `Get-MailboxStatistics` cmdlet.

---

## 5. Set Automatic Reply (Out of Office) via PowerShell

### Symptom
Admin center throws: `"The operation couldn't be performed because 'Jane Doe' matches multiple entries."`

### Resolution — Use PowerShell with Unique Identity

```powershell
# Basic auto-reply (internal and external)
Set-MailboxAutoReplyConfiguration `
    -Identity "user@contoso.com" `
    -AutoReplyState Enabled `
    -InternalMessage "I am currently out of the office." `
    -ExternalMessage "Thank you for your email. I will respond shortly." `
    -ExternalAudience All

# Scheduled auto-reply with date range
Set-MailboxAutoReplyConfiguration `
    -Identity "user@contoso.com" `
    -AutoReplyState Scheduled `
    -StartTime "2024-07-10 08:00:00" `
    -EndTime "2024-07-15 17:00:00" `
    -InternalMessage "I am on annual leave and will return on 15 July."

# Disable auto-reply
Set-MailboxAutoReplyConfiguration -Identity "user@contoso.com" -AutoReplyState Disabled
```

### Using Exchange GUID (to avoid "multiple entries" error)

```powershell
# Get the GUID
Get-Recipient -Identity user@contoso.com | Format-List

# Use the GUID as identity
Set-MailboxAutoReplyConfiguration `
    -Identity "edfb6254-9b06-4acb-abba-1d60c18e726d" `
    -AutoReplyState Enabled `
    -InternalMessage "I am currently travelling." `
    -ExternalMessage "I am currently travelling." `
    -ExternalAudience All
```

---

## 6. Assign a License via Admin Center

1. Navigate to: `Microsoft 365 Admin Center → Users → Active Users`
2. Click the user → **Licenses and Apps** tab
3. Select the desired license
4. Click **Save changes**

---

## References

- [Remove-MsolUser — Microsoft Docs](https://learn.microsoft.com/en-us/powershell/module/msonline/remove-msoluser?view=azureadps-1.0)
- [Set-MsolUserPrincipalName](https://learn.microsoft.com/en-us/powershell/module/msonline/set-msoluserPrincipalname?view=azureadps-1.0)
- [Set-MailboxAutoReplyConfiguration](https://learn.microsoft.com/en-us/powershell/module/exchange/set-mailboxautoreplyconfiguration?view=exchange-ps)
- [Azure AD Sign-in Logs](https://learn.microsoft.com/en-us/azure/active-directory/reports-monitoring/concept-sign-ins)
