# Outlook & OWA Issues

> **Category:** Client, OWA, Outlook  
> **Applies to:** Outlook Desktop, Outlook Web App (OWA), Microsoft 365

---

## 1. Create an Email Signature

### Method 1 — Exchange Admin Center (EAC) Mail Flow Rule (OWA Only)

> **Note:** Rules created in EAC apply only to **Outlook Web App (OWA)** — not the Outlook desktop client.

```
Exchange Admin Center
  → Mail Flow
  → Rules
  → Add Icon (+) → Apply Disclaimers
  → Set the signature / disclaimer text
  → Action: Wrap
  → Priority: 0  ← (Must be 0 to take effect)
```

### Method 2 — Outlook Desktop Client

1. Launch **Outlook**
2. Go to **File → Options → Mail → Signatures**
3. Click **New** → name the signature
4. Compose the signature content
5. Set default signature for **New Messages** and **Replies/Forwards**
6. Choose the default email account
7. Click **OK**

### Method 3 — Outlook Web (OWA)

1. Sign into [outlook.office.com](https://outlook.office.com)
2. Sign in with the relevant mailbox (e.g., shared mailbox)
3. Navigate to **Settings → View all Outlook settings → Compose and reply**
4. Under **Email signature**, create the signature

> **Important:** A signature created in **OWA propagates to the Outlook mobile app**, but a signature created in the **Outlook desktop client does NOT propagate to OWA**.

---

## 2. OWA Attachment Download Button Missing

### Symptom
The download button for attachments in Outlook Web App is no longer visible.

### Resolution

```
Exchange Admin Center (Classic EAC)
  → Permissions
  → Outlook Web App Policies
  → OwaMailboxPolicy-Default
  → File Access
  → Turn on: "Direct file access"
```

---

## 3. outlook.office.com Redirecting to GoDaddy SSO

### Symptom
Navigating to `outlook.office.com` redirects to `sso.godaddy.com` instead of the Microsoft sign-in page.

### Resolution Step 1 (Clear Cache)

1. Clear the browser cache and cookies
2. Navigate to `outlook.office.com`
3. Sign in normally

### Resolution Step 2 (Incognito/Private Mode)

1. Open an **Incognito / Private browsing window**
2. Visit `outlook.office.com`
3. Try `outlook.office365.com` as an alternative URL

> If the redirect persists, the domain may be configured under a GoDaddy-managed M365 tenant. Confirm with the customer whether their M365 was set up through GoDaddy.

---

## 4. User Cannot Log In to M365 Account

### Resolution

1. Open browser in **Incognito mode**
2. Navigate to [portal.microsoft.com](https://portal.microsoft.com)
3. Attempt sign-in — if successful, the issue is browser-local (cache, cookies, or extensions)
4. Clear cache or try a different browser
5. If still fails, verify the user has a valid **license** assigned

---

## 5. Adding a Shared Calendar

### Windows (Outlook Desktop)

1. Open **Outlook** → click the **Calendar** icon (bottom-left)
2. Click **Add Calendar** → **Open Calendar**
3. Choose type: User, Room, or Internet
4. Search for and select the desired user/resource

### macOS (Outlook Desktop)

1. Open **Outlook** → click the **Calendar** icon
2. Click **File** → **Open & Export** → **Other User's Folder**
3. Search for and select the user

---

## 6. Set Auto-Reply (Out of Office) via PowerShell

See full details in [06 — User Management](06-user-management.md#5-set-automatic-reply-out-of-office-via-powershell).

```powershell
# Quick reference
Set-MailboxAutoReplyConfiguration `
    -Identity "user@contoso.com" `
    -AutoReplyState Enabled `
    -InternalMessage "I am out of office." `
    -ExternalMessage "Thank you for your message. I will respond when I return." `
    -ExternalAudience All
```

---

## References

- [Create and add an email signature in Outlook](https://support.microsoft.com/en-us/office/create-and-add-an-email-signature-in-outlook-8ee5d4f4-68fd-464a-a1c1-0e1c80bb27f2)
- [Outlook Web App policies — Microsoft Docs](https://learn.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/outlook-on-the-web/outlook-web-app-mailbox-policy-procedures)
- [Set-MailboxAutoReplyConfiguration](https://learn.microsoft.com/en-us/powershell/module/exchange/set-mailboxautoreplyconfiguration?view=exchange-ps)
