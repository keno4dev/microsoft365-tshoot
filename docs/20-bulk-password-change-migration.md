# Bulk Password Change for Users Prior to Migration

> **Category:** Password Management, User Migration, MSOnline PowerShell, Bulk Operations  
> **Applies to:** Microsoft 365, Azure AD / Entra ID, Exchange Online

---

## Table of Contents

1. [Overview — When to Use Bulk Password Reset](#1-overview--when-to-use-bulk-password-reset)
2. [Bulk Password Change via CSV](#2-bulk-password-change-via-csv)
3. [Force Password Change at Next Sign-In](#3-force-password-change-at-next-sign-in)
4. [Reset Password for a Single User](#4-reset-password-for-a-single-user)
5. [Reset All Unlicensed / All Users' Passwords](#5-reset-all-unlicensed--all-users-passwords)
6. [Require Password Change for All Users (Org-Wide)](#6-require-password-change-for-all-users-org-wide)
7. [Microsoft Graph Alternative (Modern Approach)](#7-microsoft-graph-alternative-modern-approach)
8. [Important Considerations](#8-important-considerations)

---

## 1. Overview — When to Use Bulk Password Reset

Bulk password resets are commonly needed in scenarios such as:

| Scenario | Reason |
|----------|--------|
| **Pre-migration cleanup** | Set known passwords before migrating mailboxes/accounts |
| **Security incident response** | Reset all passwords after a suspected compromise |
| **Onboarding new users in bulk** | Set a uniform initial password for a batch of new users |
| **Domain migration** | Accounts moving to a new domain need a fresh credential state |
| **Tenant consolidation** | Importing users from one tenant to another |

> **Security note:** Always enforce a **forced password change at next sign-in** after any bulk reset. Never leave users with a static shared password for extended periods.

---

## 2. Bulk Password Change via CSV

This is the primary method used for pre-migration scenarios.

### Step 1 — Prepare the CSV File

```
UserPrincipalName
user1@contoso.com
user2@contoso.com
user3@contoso.com
```

Save the file as `C:\temp\users.csv`.

### Step 2 — Run the Bulk Reset

```powershell
# Connect
Set-ExecutionPolicy RemoteSigned
Connect-MsolService

# Bulk password reset — replace 'P@55w0rd!' with your chosen initial password
Import-Csv C:\temp\users.csv | ForEach-Object {
    Set-MsolUserPassword `
        -UserPrincipalName $_.UserPrincipalName `
        -NewPassword "P@55w0rd!" `
        -ForceChangePassword $true
}
```

> `ForceChangePassword $true` ensures users must change the password on their next sign-in.

### Step 3 — Verify the Changes

```powershell
# Confirm the password was updated and change-at-next-login is set
Import-Csv C:\temp\users.csv | ForEach-Object {
    Get-MsolUser -UserPrincipalName $_.UserPrincipalName |
        Select UserPrincipalName,PasswordNeverExpires,LastPasswordChangeTimestamp
}
```

---

## 3. Force Password Change at Next Sign-In

Use this flag whenever doing any bulk reset to ensure users create their own password immediately:

```powershell
# Set a password AND force change at next login
Set-MsolUserPassword `
    -UserPrincipalName user@contoso.com `
    -NewPassword "TempP@55!" `
    -ForceChangePassword $true

# Force password change only (without changing the password itself)
Set-MsolUser `
    -UserPrincipalName user@contoso.com `
    -StrongPasswordRequired $true
```

---

## 4. Reset Password for a Single User

```powershell
Connect-MsolService

# Reset a single user's password (interactive — generates a random password)
Set-MsolUserPassword `
    -UserPrincipalName user@contoso.com `
    -ForceChangePassword $true

# Reset with a specific password
Set-MsolUserPassword `
    -UserPrincipalName user@contoso.com `
    -NewPassword "NewP@ssw0rd!" `
    -ForceChangePassword $true
```

---

## 5. Reset All Unlicensed / All Users' Passwords

```powershell
Connect-MsolService

# Reset password for ALL licensed users in the tenant
Get-MsolUser -All | Where-Object { $_.isLicensed -eq $true } |
    ForEach-Object {
        Set-MsolUserPassword `
            -UserPrincipalName $_.UserPrincipalName `
            -NewPassword "TempP@55!" `
            -ForceChangePassword $true
    }

# Reset password for all users in a specific department
Get-MsolUser -All | Where-Object { $_.Department -eq "Marketing" } |
    ForEach-Object {
        Set-MsolUserPassword `
            -UserPrincipalName $_.UserPrincipalName `
            -NewPassword "TempP@55!" `
            -ForceChangePassword $true
    }
```

---

## 6. Require Password Change for All Users (Org-Wide)

If you need all users to change their password at next sign-in (e.g., after a security incident):

```powershell
Connect-MsolService

# Force all licensed users to change password on next login
Get-MsolUser -All |
    Where-Object { $_.isLicensed -eq $true -and $_.BlockCredential -eq $false } |
    ForEach-Object {
        Set-MsolUser `
            -UserPrincipalName $_.UserPrincipalName `
            -PasswordNeverExpires $false
        Set-MsolUserPassword `
            -UserPrincipalName $_.UserPrincipalName `
            -ForceChangePassword $true
    }
```

---

## 7. Microsoft Graph Alternative (Modern Approach)

The MSOnline module (`Connect-MsolService`) is **deprecated**. For new scripts, use the **Microsoft Graph PowerShell SDK**:

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
Connect-MgGraph -Scopes "UserAuthenticationMethod.ReadWrite.All"

# Reset a password for a single user using Microsoft Graph
$PasswordProfile = @{
    password = "NewP@ssw0rd!"
    forceChangePasswordNextSignIn = $true
}

Update-MgUser -UserId "user@contoso.com" -PasswordProfile $PasswordProfile

# Bulk reset via CSV using Microsoft Graph
Import-Csv C:\temp\users.csv | ForEach-Object {
    $Profile = @{
        password = "TempP@55!"
        forceChangePasswordNextSignIn = $true
    }
    Update-MgUser -UserId $_.UserPrincipalName -PasswordProfile $Profile
    Write-Host "Reset: $($_.UserPrincipalName)"
}
```

**Reference:** [Update-MgUser — Microsoft Graph PowerShell](https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/update-mguser)

---

## 8. Important Considerations

```
⚠  Always use ForceChangePassword $true — never leave users on a static shared password

⚠  Notify users securely about their temporary password before resetting
   (e.g., via phone, secure email channel, or manager communication)

⚠  Ensure Self-Service Password Reset (SSPR) is configured before migration
   so users can reset their own passwords post-migration without calling helpdesk

⚠  If MFA is enforced via Security Defaults or Conditional Access, users will be
   prompted to register MFA on first sign-in with their new password

⚠  The MSOnline module is deprecated — migrate new scripts to Microsoft Graph

⚠  Test on a small subset of users before running a bulk operation on the entire org
```

**References:**
- [Set-MsolUserPassword](https://learn.microsoft.com/en-us/powershell/module/msonline/set-msoluserpassword)
- [Bulk password reset — Microsoft 365 admin center](https://learn.microsoft.com/en-us/microsoft-365/admin/add-users/reset-passwords)
- [Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview)
- [Self-Service Password Reset (SSPR)](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-sspr-deployment)
