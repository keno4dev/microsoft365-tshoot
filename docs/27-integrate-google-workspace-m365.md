# Integrating Google Workspace with Microsoft 365

> **Category:** DNS, SPF, DKIM, MX Records, Email Coexistence, Google Workspace, Exchange Online  
> **Applies to:** Organizations using both Google Workspace and Microsoft 365 simultaneously

---

## Table of Contents

1. [Overview — Can You Use Both?](#1-overview--can-you-use-both)
2. [Use Cases](#2-use-cases)
3. [Step 1 — Modify SPF Record to Allow Both Providers](#3-step-1--modify-spf-record-to-allow-both-providers)
4. [Step 2 — Add DKIM Records for Both Providers](#4-step-2--add-dkim-records-for-both-providers)
5. [Step 3 — MX Records for Subdomains](#5-step-3--mx-records-for-subdomains)
6. [Step 4 — Configure Email Forwarding (Primary to Secondary)](#6-step-4--configure-email-forwarding-primary-to-secondary)
   - [Scenario A — Google is Primary MX](#scenario-a--google-is-primary-mx)
   - [Scenario B — Microsoft is Primary MX](#scenario-b--microsoft-is-primary-mx)
7. [Google Calendar Interop with Microsoft 365](#7-google-calendar-interop-with-microsoft-365)
8. [Caveats and Considerations](#8-caveats-and-considerations)

---

## 1. Overview — Can You Use Both?

Yes — an organization can operate **Google Workspace** and **Microsoft 365** simultaneously. This is a legitimate and supported architecture for specific business needs.

> **This guide documents the technical configuration required to achieve coexistence. It does not constitute official Microsoft or Google guidance.**  
> Always validate DNS changes in a test environment before production rollout. Incorrect DNS records can cause email delivery failures for the entire domain.

---

## 2. Use Cases

| Scenario | Description |
|----------|-------------|
| **Departmental split** | One department on Google, another on Microsoft 365 |
| **Email + Calendar coexistence** | Users on Google email but invited to Microsoft Teams meetings |
| **Migration in progress** | Mid-migration — some users moved, others still on-prem or Google |
| **Regulatory or regional split** | Different jurisdictions require different cloud providers |

---

## 3. Step 1 — Modify SPF Record to Allow Both Providers

The **SPF (Sender Policy Framework)** record must include both providers to prevent spoofing failures when either sends email using the shared domain.

### Current typical SPF for M365 only:

```
v=spf1 include:spf.protection.outlook.com -all
```

### Updated SPF for both Google and Microsoft:

```dns
v=spf1 include:_spf.google.com include:spf.protection.outlook.com -all
```

Add or update this as a **TXT record** in your DNS zone for the root domain (`@`).

> **DNS TTL:** Set TTL to 3600 (1 hour) or lower during changes so that corrections propagate quickly.

**Reference:**
- [Set up SPF to help prevent spoofing — Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/email-authentication-spf-configure)
- [Google Workspace SPF record](https://support.google.com/a/answer/178723)

---

## 4. Step 2 — Add DKIM Records for Both Providers

Both providers need their DKIM CNAME/TXT DNS records published so that receiving mail servers can verify message signatures.

### Microsoft 365 DKIM (two selectors)

In the Microsoft 365 Defender portal → **Email & Collaboration → Policies & Rules → Threat Policies → DKIM**:

1. Select the domain
2. Click **Enable** — this generates selector1 and selector2 CNAME values
3. Publish both CNAMEs in your DNS:

```dns
selector1._domainkey.contoso.com  CNAME  selector1-contoso-com._domainkey.contoso.onmicrosoft.com
selector2._domainkey.contoso.com  CNAME  selector2-contoso-com._domainkey.contoso.onmicrosoft.com
```

### Google Workspace DKIM

In the Google Admin Console → **Apps → Google Workspace → Gmail → Authenticate email**:

1. Click **Generate new record**
2. Copy the TXT record value
3. Publish it in DNS:

```dns
google._domainkey.contoso.com  TXT  "v=DKIM1; k=rsa; p=<public-key>"
```

**Reference:**
- [Set up DKIM — Microsoft Learn](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/email-authentication-dkim-configure)
- [Set up DKIM — Google Workspace Admin Help](https://support.google.com/a/answer/174124)

---

## 5. Step 3 — MX Records for Subdomains

To route email to both providers, create two subdomains and point each to its respective mail provider:

| Subdomain | MX Points To |
|-----------|-------------|
| `google.contoso.com` | Google MX servers: `aspmx.l.google.com` (priority 1), etc. |
| `microsoft.contoso.com` | Microsoft: `contoso-com.mail.protection.outlook.com` |

### Add the subdomains

These subdomains must also be **verified** in both Google Admin Console and Microsoft 365 Admin Center respectively.

> Google requires DNS verification via a TXT or CNAME record before it accepts email for a subdomain.  
> Microsoft requires domain verification in the M365 Admin Center before routing works.

---

## 6. Step 4 — Configure Email Forwarding (Primary to Secondary)

Users exist on **both platforms** with the same primary identity — the primary MX receives the email and forwards a copy to the secondary system.

### Scenario A — Google is Primary MX

The main domain MX points to Google. Configure Google to forward a copy to each user's Microsoft subdomain address.

**In the Google Admin Console:**

1. Go to **Apps → Google Workspace → Gmail → Routing**
2. Click **Email forwarding using recipient address map**
3. Add a row for each Google user:
   - **Original recipient:** `user@contoso.com`
   - **New recipient:** `user@microsoft.contoso.com`
   - Check **Also route to original recipient** (delivers to both Google and Microsoft)
4. Save

**Test:**  
Send an email to `user@contoso.com` and verify it appears in both Google Gmail and the user's Microsoft inbox.

---

### Scenario B — Microsoft is Primary MX

The main domain MX points to Microsoft. Configure Microsoft Exchange Online to forward a copy to each user's Google subdomain address.

#### Step 1 — Allow external forwarding

In the **Microsoft Defender portal → Anti-spam → Outbound policy**:

1. Select the default outbound policy (or create a new one for affected users)
2. Under **Forwarding rules**, set **Automatic forwarding** to **On**
3. Save

**Reference:** [Control automatic email forwarding — Microsoft Learn](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/outbound-spam-policies-external-email-forwarding)

#### Step 2 — Set forwarding address per user

In the Microsoft 365 Admin Center or via PowerShell:

```powershell
# Set forwarding for a single user
Set-Mailbox -Identity "user@contoso.com" `
    -ForwardingSmtpAddress "user@google.contoso.com" `
    -DeliverToMailboxAndForward $true   # Keep a copy in Microsoft mailbox

# Bulk forwarding from CSV
Import-Csv "C:\Users.csv" | ForEach-Object {
    Set-Mailbox -Identity $_.UserPrincipalName `
        -ForwardingSmtpAddress $_.GoogleSubdomainAddress `
        -DeliverToMailboxAndForward $true
}
```

**Test:**  
Send an email to the user's primary address and verify it arrives in both the Microsoft mailbox and the Google mailbox at the subdomain address.

---

## 7. Google Calendar Interop with Microsoft 365

If users on **Google** need to see or respond to **Microsoft Teams** meeting invites (and vice versa), configure **Google Calendar Interop**:

1. In the Google Admin Console → **Apps → Google Workspace → Calendar → Calendar Interop Management**
2. Add Microsoft 365 as an external calendar resource using the Exchange Web Services (EWS) or free/busy URL
3. On the Microsoft side, configure the **Organization Relationship** or **Sharing Policy** in Exchange Online to allow Google to query free/busy data

```powershell
# Allow external free/busy sharing with Google Workspace federated domain
New-OrganizationRelationship `
    -Name "Google Workspace Interop" `
    -DomainNames "google.contoso.com" `
    -FreeBusyAccessEnabled $true `
    -FreeBusyAccessLevel LimitedDetails
```

**Reference:** [Google Calendar Interop with Microsoft Exchange](https://support.google.com/a/answer/9553406)

---

## 8. Caveats and Considerations

| Risk Area | Consideration |
|-----------|---------------|
| **DMARC** | With two providers sharing a domain, ensure DMARC is set to `p=quarantine` initially; do not start with `p=reject` until verified that both DKIM/SPF pass |
| **SPF limit** | SPF records have a 10-DNS-lookup limit; combining both providers may approach this. Use SPF flattening tools if needed |
| **User confusion** | Users may not know which platform receives email or which calendar to check. Publish clear internal documentation |
| **Licensing** | Users on both platforms require licenses for both Google Workspace and Microsoft 365 |
| **Support scope** | Microsoft Support will only troubleshoot the Microsoft side of this architecture. Google Support handles the Google side |
| **MX propagation** | DNS changes can take up to 48 hours to propagate globally. Expect some delivery delays during cutover |
| **Dual accounts** | Most implementation of this coexistence requires duplicate accounts in both systems — this is administrative overhead and should be factored into your decision |

> **Recommendation:** This coexistence architecture is complex and adds significant ongoing administrative overhead. Unless there is a strong business requirement, consolidating to a single platform is almost always the simpler long-term choice.
