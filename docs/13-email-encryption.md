# Email Encryption — Issues & Resolutions

> **Category:** Email Encryption, IRM, S/MIME, Azure Information Protection (AIP), Microsoft Purview Message Encryption  
> **Applies to:** Exchange Online, Outlook Desktop, Outlook on the Web (OWA), Microsoft 365

---

## Table of Contents

1. [Licensing Requirements for Microsoft Purview Message Encryption](#1-licensing-requirements-for-microsoft-purview-message-encryption)
2. [Encryption Limitations on Shared Mailboxes](#2-encryption-limitations-on-shared-mailboxes)
3. [Encrypted Emails from Outside Org Not Opening in Outlook 2019](#3-encrypted-emails-from-outside-org-not-opening-in-outlook-2019)
4. [IRM Not Configured — "Your machine isn't setup for IRM"](#4-irm-not-configured--your-machine-isnt-setup-for-irm)
5. [Desktop Outlook Cannot Encrypt — OWA Works Fine](#5-desktop-outlook-cannot-encrypt--owa-works-fine)
6. [S/MIME — Certificate Not Found Error in OWA](#6-smime--certificate-not-found-error-in-owa)
7. [Complete IRM Setup — Working Script 1 (Quick)](#7-complete-irm-setup--working-script-1-quick)
8. [Complete IRM Setup — Working Script 2 (Full/Verbose)](#8-complete-irm-setup--working-script-2-fullverbose)
9. [General Encryption Troubleshooting Checklist](#9-general-encryption-troubleshooting-checklist)
10. [S/MIME Encryption Setup in Exchange Online & Outlook](#10-smime-encryption-setup-in-exchange-online--outlook)

---

## 1. Licensing Requirements for Microsoft Purview Message Encryption

Before deploying or troubleshooting email encryption, verify that the tenant and affected users hold a qualifying license.

### Included Licenses (No Additional Cost)

| Plan | Included? |
|------|:---------:|
| Office 365 Enterprise E3 / E5 | ✅ |
| Microsoft 365 Enterprise E3 / E5 | ✅ |
| Microsoft 365 Business Premium | ✅ |
| Office 365 A1, A3, A5 (Education) | ✅ |
| Office 365 Government G3 / G5 | ✅ |

### Add-On Plans (Requires Azure Information Protection Plan 1)

The following plans support message encryption when paired with **Azure Information Protection Plan 1**:

| Base Plan | Requires AIP P1 Add-on |
|-----------|:----------------------:|
| Exchange Online Plan 1 | ✅ |
| Exchange Online Plan 2 | ✅ |
| Office 365 F3 | ✅ |
| Microsoft 365 Business Basic | ✅ |
| Microsoft 365 Business Standard | ✅ |
| Office 365 Enterprise E1 | ✅ |

> **Important:** Every **user** who sends or receives encrypted messages must have a license that includes encryption entitlement.

**Reference:** [Microsoft Purview Message Encryption FAQ — Licensing](https://learn.microsoft.com/en-us/purview/ome-faq#what-subscriptions-do-i-need-to-use-microsoft-purview-message-encryption-)

---

## 2. Encryption Limitations on Shared Mailboxes

### Key Limitation — Opening Encrypted Emails in Shared Mailboxes

> **"When another user has access to a user mailbox, that mailbox cannot open encrypted emails. This is because the essence of encryption would be defeated."**

A shared mailbox does **not** have its own security context (username/password) and **cannot be assigned a cryptographic key**. This means:

- You **cannot** encrypt email sent _from_ a shared mailbox
- If multiple users of the shared mailbox have sent encrypted messages using their own personal keys, **some members will be able to read the email and others will not**, depending on which public key was used to encrypt the message

```
Shared Mailbox Encryption — What Happens:
─────────────────────────────────────────
User A (Member) encrypts with Key A  →  User B cannot decrypt
User B (Member) encrypts with Key B  →  User A cannot decrypt
Shared Mailbox has no key             →  No one can decrypt via shared access
```

### Workaround

If encryption is required for a group sending scenario:
- Use a **user mailbox** with "Send As" or "Send on Behalf" rights granted to appropriate staff
- Implement **Microsoft Purview Message Encryption (OME)** mail flow rules that auto-encrypt based on conditions (not reliant on per-user keys)

**References:**
- [Open encrypted or restricted message in shared mailbox](https://learn.microsoft.com/en-us/outlook/troubleshoot/user-interface/encrypted-restricted-message-shared-mailbox)
- [About shared mailboxes](https://learn.microsoft.com/en-us/microsoft-365/admin/email/about-shared-mailboxes?view=o365-worldwide)

---

## 3. Encrypted Emails from Outside Org Not Opening in Outlook 2019

### Symptom

When an external sender sends an encrypted email to an internal user, the recipient is prompted to sign in. After signing in, they receive:

> **"Sorry, but we are having trouble signing you in."**

### Root Cause

Outlook 2019 (desktop client) may not have the **Azure Information Protection (AIP) Unified Labeling Client** installed. Without this, Outlook cannot process the authentication flow required to decrypt and render messages protected with Azure RMS.

### Resolution

Install the **Microsoft Azure Information Protection** client package:

1. Download the AIP Unified Labeling Client from:  
   **https://www.microsoft.com/en-us/download/details.aspx?id=53018**

2. Run the installer as Administrator.

3. Restart Outlook after installation.

4. Re-attempt to open the encrypted email.

> After installation, Outlook gains the ability to process Azure RMS-protected content and complete the token exchange correctly.

**Alternative — Check IRM is Enabled in Outlook**

```
Outlook → File → Options → Trust Center → Trust Center Settings
  → Information Rights Management
  → Check "Use Rights Management Server at the following URL:"
     (Leave blank for online auto-discovery)
```

---

## 4. IRM Not Configured — "Your machine isn't setup for IRM"

### Symptom

Users receive the following error when attempting to apply IRM protection or open a protected message:

> **"Your machine isn't setup for Information Rights Management (IRM). To setup IRM sign into Office, open an existing IRM protected message or document, or contact your help desk."**

### Root Cause

Azure Rights Management (RMS) / IRM has not been activated or configured for the Exchange Online organization.

### Resolution

Run the following PowerShell commands as an Exchange Online administrator:

```powershell
# Step 1 — Set Execution Policy
Set-ExecutionPolicy RemoteSigned

# Step 2 — Connect Exchange Online
Install-Module ExchangeOnlineManagement -Verbose -Force
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

# Step 3 — Link RMS Online Key Sharing Location (North America endpoint example)
Set-IRMConfiguration -RMSOnlineKeySharingLocation "https://sp-rms.na.aadrm.com/TenantManagement/ServicePartner.svc"

# Step 4 — Import the Trusted Publishing Domain
Import-RMSTrustedPublishingDomain -RMSOnline -Name "RMS Online"

# Step 5 — Enable IRM
Set-IRMConfiguration -InternalLicensingEnabled $true
Set-IRMConfiguration -AzureRMSLicensingEnabled $true
Set-IRMConfiguration -SimplifiedClientAccessEnabled $true

# Step 6 — Verify and test
Get-IRMConfiguration
Test-IRMConfiguration -Sender user@contoso.com
```

### RMS Key Sharing Location by Region

| Region | Endpoint URL |
|--------|-------------|
| North America | `https://sp-rms.na.aadrm.com/TenantManagement/ServicePartner.svc` |
| Europe | `https://sp-rms.eu.aadrm.com/TenantManagement/ServicePartner.svc` |
| Asia Pacific | `https://sp-rms.ap.aadrm.com/TenantManagement/ServicePartner.svc` |

**References:**
- [Set-IRMConfiguration](https://learn.microsoft.com/en-us/powershell/module/exchange/set-irmconfiguration?view=exchange-ps)
- [Test-IRMConfiguration](https://docs.microsoft.com/en-us/powershell/module/exchange/test-irmconfiguration?view=exchange-ps)

---

## 5. Desktop Outlook Cannot Encrypt — OWA Works Fine

### Symptom

Encryption via the **Protect** button works correctly in **Outlook on the Web (OWA)** but **fails in the Outlook desktop client**. No error is displayed — the option is either missing or the action silently fails.

### Root Cause

The **Azure Information Protection (AIP) Onboarding Control Policy** may be restricting which users can use Azure RMS for content protection — blocking the desktop client's RMS call while OWA (which uses a different auth flow) still functions.

### Resolution

```powershell
# Step 1 — Install and connect to AIPService module
Install-Module -Name AIPService -AllowClobber
Import-Module -Name AIPService
Connect-AipService

# Step 2 — Check the current policy
Get-AipServiceOnboardingControlPolicy

# Step 3 — Remove restrictions (allow all users to protect content)
Set-AipServiceOnboardingControlPolicy -UseRmsUserLicense $false -Scope All
```

Allow **15–30 minutes** for the change to propagate across the tenant, then:
1. Restart the user's computer
2. Launch Outlook desktop
3. Test encryption (New Email → Options → Encrypt)

### Scoped Version — Apply to a Specific Security Group Only

If you want to test the change for a limited set of users first:

```powershell
# Scope the policy to a specific Azure AD Security Group by Object ID
Set-AipServiceOnboardingControlPolicy `
    -UseRmsUserLicense $false `
    -SecurityGroupObjectId "fba99fed-32a0-44e0-b032-37b419009501" `
    -Scope All
```

### Legacy AADRM Module Equivalent

If using the older `AADRM` module (being phased out in favour of `AIPService`):

```powershell
Set-AadrmOnboardingControlPolicy -UseRmsUserLicense $false -Scope All
Get-AadrmOnboardingControlPolicy
```

> **Note:** The `AADRM` module is deprecated. Migrate to `AIPService` using:
> ```powershell
> Uninstall-Module -Name AADRM
> Install-Module -Name AIPService
> ```

**Reference:** [Set-AipServiceOnboardingControlPolicy](https://learn.microsoft.com/en-us/powershell/module/aadrm/set-aadrmonboardingcontrolpolicy?view=azureipps)

---

## 6. S/MIME — Certificate Not Found Error in OWA

### Symptom

A user installs `SmimeOutlookWebChrome.msi` to enable S/MIME in Chrome/Edge and attempts to encrypt using S/MIME in OWA. They receive:

> **"Valid certificates weren't found for the recipients listed above."**

The **Encrypt** option may also appear **missing** entirely from Outlook on the Web.

### Root Cause — Causes & Checks

| Possible Cause | Check |
|----------------|-------|
| Tenant is on Targeted Release (First Release), causing feature rollout inconsistency | Check Release preferences |
| IRM not configured or AIP not connected to Exchange Online | Run `Get-IRMConfiguration` |
| AIP licensing location not set | Run `Get-AipServiceConfiguration` |
| S/MIME certificates not published to the GAL | Check user's certificate in EAC or AD |

### Resolution — Step 1: Switch to Standard Release

```
Microsoft 365 Admin Center
  → Settings
  → Org Settings → Organization Profile
  → Release Preferences
  → Select: "Standard release"
```

> Allow **1–2 hours** for the change to take effect across the tenant.

**Admin Portal direct link:**  
`https://admin.microsoft.com/AdminPortal/Home#/Settings/OrganizationProfile/:/Settings/L1/ReleasePreferences`

### Resolution — Step 2: Configure IRM / AIP Licensing Location

```powershell
Install-Module -Name AIPService -AllowClobber
Import-Module -Name AIPService
Connect-AipService

# Get the licensing endpoint from AIP configuration
$EndPoint = (Get-AipServiceConfiguration).LicensingIntranetDistributionPointUrl

# Set the licensing location in Exchange Online
Connect-ExchangeOnline
Set-IRMConfiguration -LicensingLocation $EndPoint
Set-IRMConfiguration -InternalLicensingEnabled $true -AzureRMSLicensingEnabled $true

# Verify
Get-IRMConfiguration
Get-RMSTemplate
```

### Resolution — Step 3: Verify S/MIME Certificate Published in GAL

For S/MIME to work, the recipient's public certificate must be **published to the Exchange directory (GAL)**:

```powershell
# Check if a user's certificate is available to Exchange
Get-Mailbox "recipient@contoso.com" | Get-MailboxCalendarConfiguration

# View certificate details via recipient
Get-Recipient "recipient@contoso.com" | Format-List UserCertificate
```

If the certificate is not present, the user must:
1. Export their S/MIME certificate as a `.cer` file
2. Upload it via OWA: `Settings → S/MIME → Manage S/MIME certificates`

**References:**
- [Encrypt email — Microsoft Support](https://support.microsoft.com/en-us/office/encrypt-email-messages-373339cb-bf1a-4509-b296-802a39d801dc)
- [Set up new message encryption capabilities](https://learn.microsoft.com/en-us/microsoft-365/compliance/set-up-new-message-encryption-capabilities?view=o365-worldwide)

---

## 7. Complete IRM Setup — Working Script 1 (Quick)

This script configures IRM end-to-end in a single session. Use this for straightforward tenants without on-premises ADRMS.

```powershell
# ─── WORKING SCRIPT 1 — IRM Full Setup (Quick) ───────────────────────────────

# Step 1: Execution policy
Set-ExecutionPolicy RemoteSigned

# Step 2: Install and connect AIPService
Install-Module -Name AIPService -Force
Import-Module -Name AIPService
Connect-AIPService
Enable-AIPService

# Verify AIP service state (should return "Enabled")
Get-AIPService

# Step 3: Install and connect Exchange Online
Install-Module ExchangeOnlineManagement -Verbose -Force
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

# Step 4: Check current IRM configuration
Get-IRMConfiguration

# Step 5: Retrieve the AIP licensing endpoint
Get-AipServiceConfiguration | Format-List LicensingIntranetDistributionPointUrl
# Note the URL returned — e.g.: https://<tenant-id>.rms.eu.aadrm.com/_wmcs/licensing

# Step 6: Set the licensing location
$RMSConfig    = Get-AipServiceConfiguration
$LicenseUri   = $RMSConfig.LicensingIntranetDistributionPointUrl
Set-IRMConfiguration -LicensingLocation $LicenseUri

# Step 7: Enable IRM features
Set-IRMConfiguration -AzureRMSLicensingEnabled $true
Set-IRMConfiguration -InternalLicensingEnabled $true
Set-IRMConfiguration -SimplifiedClientAccessEnabled $true   # Enables "Protect" button in OWA

# Step 8: Verify and test
Get-IRMConfiguration
Get-RMSTemplate
Test-IRMConfiguration -Sender admin@contoso.com -Recipient admin@contoso.com

# NB: No email is actually sent — the test simulates the IRM flow and reports success/failure
```

---

## 8. Complete IRM Setup — Working Script 2 (Full/Verbose)

This script includes additional verification steps, module maintenance, and is suitable for environments where the older AADRM module may conflict.

```powershell
# ─── WORKING SCRIPT 2 — IRM Full Setup (Verbose) ─────────────────────────────

# Step 1: Execution policy
Set-ExecutionPolicy RemoteSigned

# Step 2: Remove legacy AADRM module if present, then install AIPService
Uninstall-Module -Name AADRM -ErrorAction SilentlyContinue
Install-Module  -Name AIPService -Force
Update-Module   -Name AIPService

# Step 3: Connect to AIPService
Import-Module -Name AIPService
Connect-AIPService

# Step 4: Activate Azure Rights Management (if not already active)
Enable-Aadrm   # Use this if Enable-AIPService is not available on older modules

# Step 5: Connect to Exchange Online
Install-Module ExchangeOnlineManagement -Force
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

# Step 6: Check current IRM and AIP configuration
Get-IRMConfiguration
Get-AipServiceConfiguration | Format-List LicensingIntranetDistributionPointUrl

# Step 7: Build the licensing location list and assign it
$irmConfig  = Get-IRMConfiguration
$licenseUri = (Get-AipServiceConfiguration).LicensingIntranetDistributionPointUrl
$list       = $irmConfig.LicensingLocation

if (!$list)                        { $list = @() }
if (!$list.Contains($licenseUri))  { $list += $licenseUri }

Set-IRMConfiguration -LicensingLocation $list
Set-IRMConfiguration -AzureRMSLicensingEnabled $true -InternalLicensingEnabled $true

# Step 8: Enable the Protect button in Outlook on the web (optional but recommended)
Set-IRMConfiguration -SimplifiedClientAccessEnabled $true

# Step 9: Verify
Get-IRMConfiguration
Get-RMSTemplate
Test-IRMConfiguration -Sender admin@contoso.com -Recipient admin@contoso.com

# Step 10: Disconnect AIPService when done
Disconnect-AIPService
```

### Post-Script — Outlook Desktop Still Not Working After IRM Setup?

If Outlook desktop still fails **after the scripts run successfully**:

1. Open **Control Panel → Mail (Microsoft Outlook)** → **Show Profiles**
2. Click **Add** → create a new Outlook profile
3. Reboot Outlook using the new profile
4. Test encryption: **New Email → Options → Encrypt**

> In some cases, the Outlook profile caches stale IRM tokens. A new profile forces a clean re-authentication against the RMS endpoint.

> If the user's language is incorrect (e.g., English instead of Danish), change it:  
> `Outlook → File → Options → Language → Add a language → Set as Default → Restart Outlook`

---

## 9. General Encryption Troubleshooting Checklist

Use this checklist when investigating any email encryption issue before escalating.

```
☐ 1. Verify the user has a valid encryption-capable license assigned
        Admin Center → Users → Active Users → [User] → Licenses

☐ 2. Try opening Outlook in Incognito / InPrivate mode
        (rules out browser extension interference for OWA issues)

☐ 3. Search for RMS configuration issues in M365 Admin homepage
        Admin Center → Search "RMS" or "Information Rights Management"

☐ 4. Check for recent license changes on the affected user account
        Admin Center → Users → [User] → Licenses and Apps → Review history

☐ 5. Verify IRM is enabled for the organization
        Connect-ExchangeOnline → Get-IRMConfiguration
        → Check: InternalLicensingEnabled = True
        → Check: AzureRMSLicensingEnabled = True

☐ 6. Verify AIP Service is active
        Connect-AIPService → Get-AIPService
        → Result should be: "Enabled"

☐ 7. Confirm the licensing location is set
        Get-IRMConfiguration | Select LicensingLocation
        → Should NOT be empty

☐ 8. Run a test
        Test-IRMConfiguration -Sender admin@contoso.com -Recipient admin@contoso.com

☐ 9. For Outlook desktop issues — check AIP client
        Install AIP Unified Labeling Client from:
        https://www.microsoft.com/en-us/download/details.aspx?id=53018

☐ 10. For shared mailbox — note that encryption is not supported
         Inform user to use a licensed user mailbox with Send As rights
```

**References:**
- [Encrypt email messages — Microsoft Support](https://support.microsoft.com/en-us/office/encrypt-email-messages-373339cb-bf1a-4509-b296-802a39d801dc)
- [Set up new message encryption capabilities](https://learn.microsoft.com/en-us/microsoft-365/compliance/set-up-new-message-encryption-capabilities?view=o365-worldwide)
- [Azure IP protection features in Microsoft 365](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/azure-ip-protection-features?view=o365-worldwide)

---

## 10. S/MIME Encryption Setup in Exchange Online & Outlook

S/MIME (Secure/Multipurpose Internet Mail Extensions) provides **end-to-end email encryption and digital signing** using certificates. Unlike OME/IRM (which relies on Microsoft-managed keys), S/MIME uses **user-held certificates** — offering stronger cryptographic guarantees but requiring more setup.

### How S/MIME Works

```
Sender                              Recipient
  │                                    │
  │  Signs with private key             │
  │  Encrypts with recipient's          │
  │   public key (from GAL/AD cert)     │
  │ ──────── encrypted email ──────►   │
  │                                    │
  │                                    │  Decrypts with own private key
  │                                    │  Verifies signature with
  │                                    │   sender's public key
```

### Step 1 — Enable S/MIME in Exchange Online

```powershell
Connect-ExchangeOnline

# Enable S/MIME for the organization
Set-SmimeConfig -OWAAllowUserChoiceOfSigningCertificate $true `
                -OWASignedEmailCertificateInclusion $true `
                -OWACryptographyAlgorithms "3DES, AES128, AES256" `
                -OWAEncryptionAlgorithmPreferences "AES256" `
                -OWAForceSMIMEClientUpgrade $false
```

### Step 2 — Install the S/MIME Control for OWA (Chrome/Edge)

1. Download and install the S/MIME control:
   - For **Windows**: `SmimeOutlookWebChrome.msi` (available from your tenant's OWA settings page)
   - Navigate to: **OWA → Settings → S/MIME** → Follow the browser prompt to install the control

2. Restart the browser after installation.

### Step 3 — Obtain and Publish an S/MIME Certificate

Users need a **personal S/MIME certificate** from a Certificate Authority (CA). Options include:

| Certificate Source | Notes |
|--------------------|-------|
| Internal PKI (AD CS) | Best for enterprise — auto-published to GAL via AD synchronization |
| Third-party CA (e.g., DigiCert, Sectigo) | Must be manually published |
| Self-signed | Not suitable for external recipients |

```powershell
# Check if a user has a certificate already published to Exchange
Get-Recipient "user@contoso.com" | Format-List UserCertificate, UserSMimeCertificate
```

### Step 4 — Publish Certificate to the GAL (if not auto-published)

Users can self-publish via **OWA**:
1. `Settings (⚙) → S/MIME`
2. Under **S/MIME certificates**, click **Manage**
3. Import the `.pfx` certificate file
4. The public certificate is then discoverable by senders in the same organization

### Step 5 — Configure Outlook Desktop for S/MIME

1. Open **Outlook → File → Options → Trust Center → Trust Center Settings**
2. Click **Email Security**
3. Under **Encrypted email**, click **Settings**
4. Select your **Signing Certificate** and **Encryption Certificate** from the Windows Certificate Store
5. Click **OK**

### Step 6 — Verify S/MIME Functionality

```powershell
Connect-ExchangeOnline

# Confirm S/MIME configuration is live
Get-SmimeConfig | Format-List

# Check recipient certificate is accessible for encryption
Get-Recipient "recipient@contoso.com" | Select UserCertificate, UserSMimeCertificate
```

### Common S/MIME Issues & Fixes

| Symptom | Fix |
|---------|-----|
| "Valid certificates weren't found" | Recipient's certificate not published to GAL — they must import/publish their cert via OWA or AD |
| Encrypt option missing in OWA | Reinstall S/MIME control + verify `Set-SmimeConfig` is configured |
| Signed emails show "Untrusted" for external recipients | Certificate from unknown CA — use a publicly trusted CA |
| S/MIME works in OWA but not Outlook desktop | Check Windows Certificate Store; ensure the certificate is in **Personal** store with private key |
| Tenant on Targeted Release blocks S/MIME features | Switch to Standard Release (see [Section 6](#6-smime--certificate-not-found-error-in-owa)) |

**References:**
- [S/MIME for message signing and encryption in Exchange Online](https://learn.microsoft.com/en-us/exchange/security-and-compliance/smime-exo/smime-exo)
- [Configure S/MIME settings for OWA](https://learn.microsoft.com/en-us/exchange/security-and-compliance/smime-exo/configure-smime)
- [Encrypt email messages in Outlook](https://support.microsoft.com/en-us/office/encrypt-email-messages-373339cb-bf1a-4509-b296-802a39d801dc)

---

## Key Cmdlets Reference

| Cmdlet | Purpose |
|--------|---------|
| `Set-IRMConfiguration` | Configure IRM settings for the Exchange organization |
| `Get-IRMConfiguration` | View current IRM configuration |
| `Test-IRMConfiguration` | Test IRM end-to-end (no email sent) |
| `Get-RMSTemplate` | List available RMS/sensitivity label templates |
| `Connect-AIPService` | Connect to Azure Information Protection service |
| `Enable-AIPService` | Activate the AIP / Azure RMS service |
| `Get-AIPService` | Check if AIP service is enabled |
| `Get-AipServiceConfiguration` | Retrieve AIP config including licensing URL |
| `Set-AipServiceOnboardingControlPolicy` | Control which users can protect content with AIP |
| `Import-RMSTrustedPublishingDomain` | Import the RMS publishing domain for hybrid scenarios |
| `Set-SmimeConfig` | Configure S/MIME settings for the organization |
| `Get-SmimeConfig` | View current S/MIME configuration |
