# Contacting Microsoft Support

> **Category:** Support, Escalation, Microsoft 365, Personal Accounts, Business Accounts, Quick Assist  
> **Applies to:** All Microsoft 365 plans, Microsoft Personal accounts, Microsoft Business subscriptions

---

> ## ⚠ Important — Read Before Using This Repository
>
> This knowledge base is a **self-help resource** designed to help you resolve common Microsoft 365 issues **before or instead of opening a support ticket**.
>
> **Try the applicable fix from this repository first.** Most of the documented resolutions are aligned with standard Microsoft Support procedures.
>
> If the issue is **not resolved after attempting self-remediation**, or if the situation requires **tenant-level changes, account recovery, or billing adjustments**, escalate to Microsoft Support using the contact methods documented below.
>
> **Free support is available to all Microsoft 365 subscribers.** You are entitled to it — use it.

---

## Table of Contents

1. [Support for Personal Microsoft Accounts](#1-support-for-personal-microsoft-accounts)
2. [Support for Business and Commercial Subscriptions](#2-support-for-business-and-commercial-subscriptions)
3. [Global Customer Service Phone Numbers](#3-global-customer-service-phone-numbers)
4. [Quick Assist — Remote Support Tool](#4-quick-assist--remote-support-tool)
5. [What to Prepare Before Contacting Support](#5-what-to-prepare-before-contacting-support)
6. [Support Tiers — What Microsoft can and cannot do](#6-support-tiers--what-microsoft-can-and-cannot-do)

---

## 1. Support for Personal Microsoft Accounts

For issues with **Outlook.com, OneDrive personal, Microsoft 365 Personal/Family, Xbox, or MSN**:

**Microsoft Answer Desk (Personal Support):**  
[https://support.microsoft.com/en-gb/home/contact](https://support.microsoft.com/en-gb/home/contact)

**Microsoft Office Personal Support:**  
[https://support.microsoft.com/en-us/topic/contact-microsoft-office-support-fd6bb40e-75b7-6f43-d6f9-c13d10850e77](https://support.microsoft.com/en-us/topic/contact-microsoft-office-support-fd6bb40e-75b7-6f43-d6f9-c13d10850e77)

**Self-service options available:**
- Live chat (24/7 for eligible subscriptions)
- Screen sharing with an agent
- Community forums (free, peer-assisted)
- In-product Help → "?" → "Contact Support"

---

## 2. Support for Business and Commercial Subscriptions

For issues with **Microsoft 365 for Business, Enterprise, Education, or Government** plans:

**Primary support portal for admins:**  
[https://support.microsoft.com/en-us/contactus](https://support.microsoft.com/en-us/contactus)

**Steps to open a service request (admin):**

1. Sign in to the **Microsoft 365 Admin Center**: [https://admin.microsoft.com](https://admin.microsoft.com)
2. Go to **Support → New service request** (the `?` icon in the left nav, or **Help & support**)
3. Describe the issue — the AI assistant will suggest relevant docs and fixes
4. If the AI does not resolve your issue, select **Contact support**
5. Choose **Chat** or **Phone** based on your preference and urgency

> **Admin rights required:** Only a Global Administrator or Service Support Administrator can open service requests in the Admin Center.

**Reference:** [Get support for Microsoft 365 for business](https://learn.microsoft.com/en-us/microsoft-365/admin/get-help-support?view=o365-worldwide)

---

## 3. Global Customer Service Phone Numbers

Microsoft provides phone support in most countries. Dial the number for your country/region:

**Global directory:**  
[https://support.microsoft.com/en-us/topic/global-customer-service-phone-numbers-c0389ade-5640-e588-8b0e-28de8afeb3f2](https://support.microsoft.com/en-us/topic/global-customer-service-phone-numbers-c0389ade-5640-e588-8b0e-28de8afeb3f2)

| Region | Common Entry Point |
|--------|-------------------|
| United States | 1-800-642-7676 |
| United Kingdom | 0800 026 0329 |
| Canada | 1-877-568-2495 |
| Australia | 1800 197 503 |
| All other regions | See global directory above |

> **Business hours vary by region.** Enterprise/commercial customers with Premier or Unified support contracts typically have 24/7 access.

---

## 4. Quick Assist — Remote Support Tool

**Quick Assist** is a built-in Windows tool that allows a Microsoft support agent (or an IT admin) to remotely access and control your device.

### For the person receiving help (sharer):

**Web link:** [https://aka.ms/qawebsharer](https://aka.ms/qawebsharer)

Or open directly:
- **Start → Quick Assist** (pre-installed on Windows 10/11)
- Enter the 6-character code provided by the helper

### For the person providing help (helper):

**Web link:** [https://aka.ms/qawebhelper](https://aka.ms/qawebhelper)

Or open directly:
- **Start → Quick Assist → Give assistance**
- Share the 6-character code with the recipient

### In PowerShell (open directly)

```powershell
Start-Process "ms-quick-assist:"
```

> **Security note:** Only share device access with trusted individuals. Microsoft Support agents will never ask you to install Quick Assist yourself — they will walk you through the built-in tool.

**Reference:** [Quick Assist overview — Microsoft Learn](https://learn.microsoft.com/en-us/windows/client-management/client-tools/quick-assist)

---

## 5. What to Prepare Before Contacting Support

Gathering this information before the call or chat significantly reduces resolution time:

| Information | How to Get It |
|-------------|--------------|
| **Tenant domain** | e.g., `contoso.onmicrosoft.com` |
| **Admin UPN** | Your own admin account `admin@contoso.com` |
| **Tenant ID** | Microsoft 365 Admin Center → Settings → Org Settings → Organization profile |
| **Affected user UPNs** | List of affected users, e.g., `john.doe@contoso.com` |
| **Error message / code** | Screenshot or exact verbatim text |
| **Message Trace ID** | From EXO Admin Center → Mail Flow → Message Trace if email-related |
| **Incident time (UTC)** | Knowing the approximate time in UTC helps support search logs |
| **Steps already tried** | What you have already done from this knowledge base |
| **Subscription plan** | E3, Business Premium, etc. — visible in M365 Admin Center → Billing |

---

## 6. Support Tiers — What Microsoft can and cannot do

Understanding support scope prevents frustration during escalation:

| Scope | Microsoft Support Can Help | Outside Support Scope |
|-------|---------------------------|----------------------|
| Exchange Online | Configuration, routing, connector issues, NDR analysis | Third-party mail gateways not in M365 |
| Azure AD / Entra ID | Sign-in issues, sync errors, MFA, conditional access | Third-party IdP integration issues |
| Teams | Call quality, meetings, policies, licensing | Third-party SBC issues (requires partner support) |
| SharePoint Online | Site creation, permissions, storage | Custom code / SPFx customizations |
| OneDrive | Sync issues, account recovery | Files deleted beyond 90-day recycle bin |
| Billing | License assignment, subscription changes | Payment gateway disputes |
| Security & Compliance | Purview, DLP, audit logs | Third-party SIEM integration |

> For **third-party integrations** (non-Microsoft products), contact the respective vendor. Microsoft Support will confirm whether the root cause is on the Microsoft side before escalating to a partner.

---

## Support Contract Types

| Type | Typical Customer | SLA / Response Time |
|------|-----------------|-------------------|
| **Included (no-cost)** | All M365 subscribers | Best-effort, chat + phone |
| **Developer** | MSDN / Visual Studio subscribers | Technical advisory |
| **Unified** (formerly Premier) | Enterprise customers | Guaranteed SLA, dedicated TAM |
| **Partner network** | CSP / reseller partners | Partner-tier escalation paths |

**Reference:** [Compare Microsoft support plans](https://www.microsoft.com/en-us/msservices/compare-support-plans)
