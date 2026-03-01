# Exchange Online PowerShell — Connectivity

> **Category:** Connectivity  
> **Applies to:** Exchange Online, Microsoft 365

---

## Overview

Before running any Exchange Online administrative cmdlets, you must establish an authenticated session using the **ExchangeOnlineManagement** PowerShell module. This is the modern, recommended replacement for the legacy Remote PowerShell method.

---

## Prerequisites

```powershell
# 1. Set execution policy to allow signed scripts
Set-ExecutionPolicy RemoteSigned

# 2. Enforce TLS 1.2 (required for connecting to Microsoft services)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 3. Install required modules (run as Administrator)
Install-Module MSOnline -Force
Import-Module MSOnline

Install-Module ExchangeOnlineManagement -Verbose -Force
Import-Module ExchangeOnlineManagement
```

> **Note:** You only need to install the modules once. After that, import them at the start of each session.

---

## Connecting to Exchange Online

### Basic Connection

```powershell
Connect-ExchangeOnline -UserPrincipalName admin@contoso.com -ShowProgress $true
```

### Silent Connection (no browser prompt — useful for scripts)

```powershell
$Credential = Get-Credential
Connect-ExchangeOnline -Credential $Credential -ShowProgress $true
```

### With Certificate-Based Authentication (unattended scripts)

```powershell
Connect-ExchangeOnline `
    -CertificateThumbprint "THUMBPRINT" `
    -AppId "APP_ID" `
    -Organization "contoso.onmicrosoft.com"
```

> See [Register an app for unattended scripts](https://learn.microsoft.com/en-us/powershell/exchange/app-only-auth-powershell-v2?view=exchange-ps) for setup steps.

---

## Optional: Transcript Logging

It is good practice to log all sessions — useful for audit trails and post-session review:

```powershell
Start-Transcript -Path "C:\transcripts\transcript0.txt" -NoClobber
```

Place this **before** the `Connect-ExchangeOnline` call.

---

## Connecting to Security & Compliance PowerShell (Purview)

Used for compliance-related cmdlets such as `New-ComplianceSearch`:

```powershell
Connect-IPPSSession -UserPrincipalName admin@contoso.com
```

---

## Connecting to MSOnline (Azure AD / MSOL)

Required for user lifecycle and license operations:

```powershell
Connect-MsolService
```

---

## Disconnecting

Always disconnect your session when finished:

```powershell
Disconnect-ExchangeOnline -Confirm:$false
```

---

## Troubleshooting Connection Issues

| Error | Likely Cause | Fix |
|-------|-------------|-----|
| `WinRM client cannot complete the operation` | TLS not enforced | Run `[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12` |
| `Access is denied` | Wrong credentials or MFA not completed | Ensure you're using the correct admin UPN and MFA is satisfied |
| `The term 'Connect-ExchangeOnline' is not recognized` | Module not imported | Run `Import-Module ExchangeOnlineManagement` |
| `Execution Policy` error | Scripts blocked | Run `Set-ExecutionPolicy RemoteSigned` as Administrator |

---

## References

- [Connect to Exchange Online PowerShell — Microsoft Docs](https://docs.microsoft.com/en-us/powershell/exchange/connect-to-exchange-online-powershell?view=exchange-ps)
- [ExchangeOnlineManagement Module](https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps)
- [Connect to Security & Compliance PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell?view=exchange-ps)
