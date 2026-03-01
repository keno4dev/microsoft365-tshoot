# PowerShell Scripts

This folder contains reusable PowerShell scripts derived from real Microsoft 365 support case resolutions.

---

## Script Index

| Script | Description | Category |
|--------|-------------|----------|
| [Get-MessageReadStatusReport.ps1](Get-MessageReadStatusReport.ps1) | Generate a per-recipient email read status report and export to CSV | Email Tracking |
| [Permanently-Delete-M365User.ps1](Permanently-Delete-M365User.ps1) | Interactively soft-delete + hard-delete a Microsoft 365 user | User Management |
| [Bulk-Delete-MailContacts.ps1](Bulk-Delete-MailContacts.ps1) | Delete multiple Exchange mail contacts from a CSV file | Mail Contacts |
| [Bulk-Add-UsersToM365Group.ps1](Bulk-Add-UsersToM365Group.ps1) | Add multiple users from a CSV to a Microsoft 365 Group | M365 Groups |
| [Bulk-ChangeDomain.ps1](Bulk-ChangeDomain.ps1) | Bulk UPN / domain change for users from a CSV file | User Management |
| [Set-OrgRetentionPolicy.ps1](Set-OrgRetentionPolicy.ps1) | Create and apply a 7-year org-wide retention policy | Compliance |

---

## Prerequisites (All Scripts)

```powershell
# Required modules
Install-Module MSOnline                 -Force
Install-Module ExchangeOnlineManagement -Force
Install-Module Microsoft.Graph          -Force
Install-Module Microsoft.Graph.Beta     -Force

# Execution policy
Set-ExecutionPolicy RemoteSigned

# TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

---

## Usage Notes

- Always run scripts as **administrator** in PowerShell
- Test against a **non-production tenant** or pilot user before running org-wide
- Review and update hardcoded paths (e.g., `C:\CSV\`, `C:\Temp\`) before execution
- All scripts include `Disconnect-ExchangeOnline` at the end where applicable
