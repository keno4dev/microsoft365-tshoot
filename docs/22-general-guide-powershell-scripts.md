# General Guide for Running PowerShell Scripts

> **Category:** PowerShell, Microsoft 365, MSOnline, Microsoft Teams, Exchange Online, Execution Policy  
> **Applies to:** Windows PowerShell 5.1+, PowerShell 7+, Microsoft 365 tenants

---

## Table of Contents

1. [Set PowerShell Execution Policy](#1-set-powershell-execution-policy)
2. [Microsoft 365 / MSOnline Module](#2-microsoft-365--msonline-module)
3. [Microsoft Graph PowerShell Module](#3-microsoft-graph-powershell-module)
4. [Exchange Online PowerShell](#4-exchange-online-powershell)
5. [Microsoft Teams PowerShell Module](#5-microsoft-teams-powershell-module)
6. [Auto Attendant Diagnostics](#6-auto-attendant-diagnostics)
7. [Logging with Start-Transcript](#7-logging-with-start-transcript)
8. [Common Modules Quick Reference](#8-common-modules-quick-reference)
9. [Running as Administrator](#9-running-as-administrator)

---

## 1. Set PowerShell Execution Policy

Before running any unsigned or locally written PowerShell scripts, you must set an appropriate execution policy.

### Set for Current User (Recommended — least privilege)

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Set for Local Machine (All Users — requires elevation)

```powershell
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
```

### Confirm the Current Policy

```powershell
Get-ExecutionPolicy -List
```

| Policy | Meaning |
|--------|---------|
| `Restricted` | No scripts run (Windows default) |
| `RemoteSigned` | Local scripts run; downloaded scripts require a signature |
| `Unrestricted` | All scripts run (not recommended for production) |
| `Bypass` | Nothing blocked — typically used in automated pipeline environments |

> **Best practice:** Use `RemoteSigned -Scope CurrentUser` when working interactively. Avoid `Unrestricted` on production servers.

**Reference:** [Set-ExecutionPolicy — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy)

---

## 2. Microsoft 365 / MSOnline Module

> **Note:** The MSOnline module (`MSOL`) is **deprecated** as of 30 March 2024.  
> Migrate to [Microsoft Graph PowerShell](#3-microsoft-graph-powershell-module) for all new work.  
> Reference: [Deprecation notice — Microsoft Entra](https://learn.microsoft.com/en-us/entra/identity/users/ms-graph-module-retirement)

### Install the MSOnline Module

```powershell
Install-Module MSOnline -Force
```

### Connect to Microsoft 365

```powershell
# Prompt for credentials
$MsolCred = Get-Credential

# Connect
Connect-MsolService -Credential $MsolCred
```

Or interactively (browser-based MFA):

```powershell
Connect-MsolService
```

### Test the Connection

```powershell
Get-MsolDomain
```

---

## 3. Microsoft Graph PowerShell Module

The modern replacement for MSOnline and AzureAD modules.

### Install

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser -Force
```

### Connect with Required Scopes

```powershell
# Example: connect with User.Read.All scope
Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All"
```

### Verify Connection

```powershell
Get-MgContext
```

**Reference:** [Microsoft Graph PowerShell overview](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview)

---

## 4. Exchange Online PowerShell

### Install the Exchange Online PowerShell Module

```powershell
Install-Module ExchangeOnlineManagement -Force
```

### Connect

```powershell
Connect-ExchangeOnline -UserPrincipalName admin@contoso.com
```

### Disconnect

```powershell
Disconnect-ExchangeOnline -Confirm:$false
```

**Reference:** [Connect to Exchange Online PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/connect-to-exchange-online-powershell)

---

## 5. Microsoft Teams PowerShell Module

### Install

```powershell
Install-Module -Name MicrosoftTeams -Force -AllowClobber
```

### Connect

```powershell
Connect-MicrosoftTeams
```

### Verify Connection

```powershell
Get-CsTenant
```

### Disconnect

```powershell
Disconnect-MicrosoftTeams
```

**Reference:** [Microsoft Teams PowerShell overview](https://learn.microsoft.com/en-us/microsoftteams/teams-powershell-overview)

---

## 6. Auto Attendant Diagnostics

Retrieve details about a Teams Auto Attendant by its Identity GUID:

```powershell
# Replace the GUID with the actual Auto Attendant identity
Get-CsAutoAttendant -Identity "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### Find All Auto Attendants

```powershell
Get-CsAutoAttendant | Select-Object Name, Identity, LanguageId, TimeZoneId
```

### Find Auto Attendant by Name

```powershell
Get-CsAutoAttendant | Where-Object { $_.Name -like "*Sales*" }
```

**Reference:** [Get-CsAutoAttendant — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/teams/get-csautoattendant)

---

## 7. Logging with Start-Transcript

`Start-Transcript` captures all PowerShell input and output to a log file. This is essential when running bulk operations or admin scripts for auditing purposes.

### Start a Transcript

```powershell
Start-Transcript -Path "C:\Transcripts\transcript0.txt" -NoClobber
```

| Parameter | Meaning |
|-----------|---------|
| `-Path` | Full path to the log file |
| `-NoClobber` | Do not overwrite an existing file — appends a sequence number instead |
| `-Append` | Append to an existing log file instead of overwriting it |
| `-Force` | Override read-only attributes on the output file |

### Stop a Transcript

```powershell
Stop-Transcript
```

### Best Practice — Timestamped Log Files

```powershell
$Timestamp  = (Get-Date -Format "yyyyMMdd_HHmmss")
$LogRoot    = "C:\Transcripts"
$LogFile    = "$LogRoot\transcript_$Timestamp.txt"

# Create log directory if it does not exist
if (-not (Test-Path $LogRoot)) { New-Item -ItemType Directory -Path $LogRoot | Out-Null }

Start-Transcript -Path $LogFile -NoClobber
# ... script body here ...
Stop-Transcript
```

**Reference:** [Start-Transcript — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.host/start-transcript)

---

## 8. Common Modules Quick Reference

| Module | Install Command | Connect Command |
|--------|-----------------|-----------------|
| **MSOnline** (deprecated) | `Install-Module MSOnline` | `Connect-MsolService` |
| **Microsoft.Graph** | `Install-Module Microsoft.Graph` | `Connect-MgGraph -Scopes "..."` |
| **ExchangeOnlineManagement** | `Install-Module ExchangeOnlineManagement` | `Connect-ExchangeOnline` |
| **MicrosoftTeams** | `Install-Module MicrosoftTeams` | `Connect-MicrosoftTeams` |
| **AzureAD** (deprecated) | `Install-Module AzureAD` | `Connect-AzureAD` |
| **Az (Azure)** | `Install-Module Az` | `Connect-AzAccount` |

> **Upgrade all modules at once:**
> ```powershell
> Get-InstalledModule | Update-Module
> ```

---

## 9. Running as Administrator

Several cmdlets require an elevated PowerShell session.

### Open Elevated Session

1. Search for **Windows PowerShell** in the Start menu
2. Right-click → **Run as administrator**

### Detect Elevation in Script

```powershell
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Warning "This script must be run as Administrator."
    exit 1
}
```

---

## Common Errors

| Error Message | Likely Cause | Fix |
|---------------|-------------|-----|
| `script.ps1 cannot be loaded because running scripts is disabled` | Execution policy restricting scripts | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| `The term 'Connect-MsolService' is not recognized` | MSOnline module not installed | `Install-Module MSOnline -Force` |
| `Access denied` when running cmdlets | Script not running as Administrator | Open PowerShell as Administrator |
| `Connect-ExchangeOnline : User account is not enabled for Microsoft Exchange` | Account lacks Exchange Online license | Assign an Exchange Online license via M365 Admin Center |
