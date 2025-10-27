# Email Service Provider (ESP) Configuration Guide

Welcome to the Inbox SOS ESP Configuration Guide! This document will walk you through setting up your email service provider (ESP) with Mautic 6. As an email marketer, you know that proper ESP configuration is critical for deliverability, and we've made it simple to connect your preferred provider.

## Table of Contents

- [Overview](#overview)
- [Accessing Email Settings](#accessing-email-settings)
- [Amazon SES Configuration](#amazon-ses-configuration)
- [Brevo Configuration](#brevo-configuration)
- [Mailgun Configuration](#mailgun-configuration)
- [SendGrid Configuration](#sendgrid-configuration)
- [Postmark Configuration](#postmark-configuration)
- [Testing Your Configuration](#testing-your-configuration)
- [Switching ESPs](#switching-esps)
- [Troubleshooting](#troubleshooting)

---

## Overview

Mautic 6 supports multiple email service providers out of the box. Your Inbox SOS installation comes pre-configured with support for:

- **Amazon SES** - Cost-effective, scalable AWS email service
- **Brevo** (formerly Sendinblue) - All-in-one marketing platform
- **Mailgun** - Developer-focused email API
- **SendGrid** - Enterprise-grade email delivery
- **Postmark** - Transactional email specialist

You can switch between providers at any time without reinstalling or reconfiguring your Mautic instance.

---

## Accessing Email Settings

1. Log into your Mautic admin panel
2. Click the **gear icon** (⚙️) in the top right corner
3. Navigate to **Configuration**
4. Click the **Email Settings** tab

This is where you'll configure your ESP connection.

---

## Amazon SES Configuration

Amazon SES offers excellent deliverability at low cost, making it perfect for both small businesses and enterprises.

### Prerequisites

1. AWS account with SES access
2. Verified sender email address or domain in SES
3. IAM user with SES sending permissions
4. AWS Access Key ID and Secret Access Key

### Step 1: Install the Amazon SES Plugin

The Amazon SES Bundle plugin is automatically installed during deployment. To verify:

1. Go to **Settings** > **Plugins**
2. Look for **AmazonSesBundle**
3. If not visible, click **Install/Update Plugins**

### Step 2: Get Your AWS Credentials

1. Log into AWS Console
2. Go to **IAM** > **Users**
3. Create a new user or select existing user
4. Attach the **AmazonSESFullAccess** policy (or create a custom policy with `ses:SendEmail` and `ses:SendRawEmail` permissions)
5. Generate **Access Key** credentials
6. Note your AWS Region (e.g., `us-east-1`, `eu-west-1`)

### Step 3: Verify Your Domain/Email in SES

1. Go to **Amazon SES** > **Verified identities**
2. Click **Create identity**
3. Choose **Domain** (recommended) or **Email address**
4. Follow verification steps (DNS records for domain, or click verification link for email)
5. **Important**: Move out of SES Sandbox mode by requesting production access in the AWS Console

### Step 4: Configure in Mautic

1. Go to **Configuration** > **Email Settings**
2. **Service to send mail**: Select **Amazon SES**
3. **AWS Access Key ID**: Enter your AWS access key
4. **AWS Secret Access Key**: Enter your AWS secret key
5. **AWS Region**: Select your region (e.g., `us-east-1`)
6. **From Email**: Your verified email address
7. **From Name**: Your company/sender name
8. Click **Apply** then **Save & Close**

### DSN Configuration (Alternative Method)

If you prefer environment variables, add this to your Railway environment:

```
MAILER_DSN=mautic+ses+api://YOUR_ACCESS_KEY_ID:YOUR_SECRET_ACCESS_KEY@default?region=us-east-1
```

Replace:
- `YOUR_ACCESS_KEY_ID` with your AWS Access Key ID
- `YOUR_SECRET_ACCESS_KEY` with your AWS Secret Access Key
- `us-east-1` with your AWS region

### Setting Up SNS Callbacks (Recommended)

To track bounces and complaints:

1. In AWS SES, go to **Configuration Sets**
2. Create a new configuration set
3. Add **SNS** as a destination for bounce and complaint events
4. Point SNS to: `https://your-mautic-domain.com/mailer/callback`

---

## Brevo Configuration

Brevo (formerly Sendinblue) offers an all-in-one marketing solution with generous free tier.

### Prerequisites

1. Brevo account
2. API key with sending permissions

### Step 1: Get Your Brevo API Key

1. Log into [Brevo](https://www.brevo.com)
2. Go to **Settings** > **SMTP & API**
3. Click **Create a new API key**
4. Name it (e.g., "Mautic Integration")
5. Copy the API key (starts with `xkeysib-`)

### Step 2: Verify Your Sender

1. In Brevo, go to **Settings** > **Senders**
2. Add and verify your sender email address
3. Follow email verification steps

### Step 3: Configure in Mautic

1. Go to **Configuration** > **Email Settings**
2. **Service to send mail**: Select **Other SMTP Server**
3. Or configure via DSN in Railway environment variables:

```
MAILER_DSN=brevo+api://YOUR_API_KEY@default
```

4. **From Email**: Your verified sender email
5. **From Name**: Your company name
6. Click **Apply** then **Save & Close**

### Alternative: SMTP Configuration

If API is not working, use SMTP:

- **Host**: smtp-relay.sendinblue.com (or smtp-relay.brevo.com)
- **Port**: 587
- **Encryption**: TLS
- **Username**: Your Brevo login email
- **Password**: Your SMTP password (from SMTP & API settings)

---

## Mailgun Configuration

Mailgun is a powerful email API service popular with developers and SaaS companies.

### Prerequisites

1. Mailgun account
2. Verified domain
3. API key

### Step 1: Get Your Mailgun Credentials

1. Log into [Mailgun](https://www.mailgun.com)
2. Go to **Sending** > **Domain Settings**
3. Select your domain
4. Copy your **API Key**
5. Note your **Domain** (e.g., `mg.yourdomain.com`)
6. Note your **Region** (US or EU)

### Step 2: Verify Your Domain

1. In Mailgun, go to **Sending** > **Domains**
2. Add your domain
3. Add the DNS records provided (SPF, DKIM, CNAME)
4. Wait for verification (can take up to 48 hours)

### Step 3: Configure in Mautic

Add to Railway environment variables:

```
MAILER_DSN=mailgun+https://YOUR_API_KEY:YOUR_DOMAIN@default?region=us
```

Replace:
- `YOUR_API_KEY` with your Mailgun API key
- `YOUR_DOMAIN` with your verified domain (e.g., `mg.yourdomain.com`)
- `region=us` with `region=eu` if using EU servers

Or configure in Mautic UI:
1. **Service to send mail**: Select **Mailgun**
2. Enter your API key and domain
3. Set From Email and From Name
4. **Save & Close**

---

## SendGrid Configuration

SendGrid is an enterprise-grade email delivery platform trusted by Fortune 500 companies.

### Prerequisites

1. SendGrid account
2. API key with sending permissions
3. Verified sender identity

### Step 1: Get Your SendGrid API Key

1. Log into [SendGrid](https://sendgrid.com)
2. Go to **Settings** > **API Keys**
3. Click **Create API Key**
4. Give it **Full Access** or **Mail Send** permissions
5. Copy the API key (starts with `SG.`)

### Step 2: Verify Your Sender

1. Go to **Settings** > **Sender Authentication**
2. Choose **Single Sender Verification** (quick) or **Domain Authentication** (recommended)
3. Follow verification steps

### Step 3: Configure in Mautic

Add to Railway environment variables:

```
MAILER_DSN=sendgrid+api://YOUR_API_KEY@default
```

Or configure in Mautic UI:
1. **Service to send mail**: Select **SendGrid API**
2. **API Key**: Your SendGrid API key
3. **From Email**: Your verified sender email
4. **From Name**: Your company name
5. **Save & Close**

---

## Postmark Configuration

Postmark specializes in transactional email with industry-leading deliverability rates.

### Prerequisites

1. Postmark account
2. Server API token
3. Verified sender signature

### Step 1: Get Your Postmark API Token

1. Log into [Postmark](https://postmarkapp.com)
2. Go to **Servers** and select your server
3. Go to **API Tokens** tab
4. Copy your **Server API Token**

### Step 2: Verify Your Sender

1. Go to **Sender Signatures**
2. Add your sender email or domain
3. Follow verification steps

### Step 3: Configure in Mautic

Add to Railway environment variables:

```
MAILER_DSN=postmark+api://YOUR_API_TOKEN@default
```

Or configure in Mautic UI:
1. **Service to send mail**: Select **Other SMTP Server**
2. Configure SMTP settings:
   - **Host**: smtp.postmarkapp.com
   - **Port**: 587
   - **Encryption**: TLS
   - **Username**: Your Server API Token
   - **Password**: Your Server API Token
3. **From Email**: Your verified sender email
4. **Save & Close**

---

## Testing Your Configuration

After configuring your ESP, it's crucial to test that emails are sending correctly.

### Step 1: Send a Test Email

1. Go to **Configuration** > **Email Settings**
2. Click **Send Test Email**
3. Enter your email address
4. Click **Send**
5. Check your inbox (and spam folder)

### Step 2: Check Logs

If the test fails:
1. Check Mautic logs in **Settings** > **System Info** > **Log**
2. Look for error messages
3. Verify your credentials are correct

### Step 3: Verify DNS Records

For best deliverability, ensure you have:
- **SPF** record
- **DKIM** record
- **DMARC** record (recommended)

Most ESPs provide these in their dashboard under domain verification.

---

## Switching ESPs

You can switch between ESPs at any time without data loss.

### Steps to Switch

1. Go to **Configuration** > **Email Settings**
2. Change **Service to send mail** to your new ESP
3. Enter new credentials
4. Send a test email
5. **Save & Close**

Or update the `MAILER_DSN` environment variable in Railway.

### Important Notes

- Your email templates, contacts, and campaigns remain unchanged
- Email statistics and history are preserved
- Send a test email before switching in production
- Consider switching during low-traffic periods

---

## Troubleshooting

### Common Issues

**"Authentication failed"**
- Double-check your API key or credentials
- Ensure the API key has sending permissions
- Check if the key has been regenerated in your ESP dashboard

**"Sender not verified"**
- Verify your sender email/domain in your ESP
- Check DNS records are properly configured
- For AWS SES, ensure you're out of sandbox mode

**"Rate limit exceeded"**
- Check your ESP's sending limits
- Upgrade your ESP plan if needed
- For high volume, consider using a dedicated IP

**"Connection timeout"**
- Check Railway environment variables
- Verify firewall rules
- Try SMTP if API method fails

**Emails going to spam**
- Configure SPF, DKIM, and DMARC records
- Warm up your IP/domain gradually
- Use authenticated domain (not @gmail.com)
- Check sender reputation at mail-tester.com

### Getting Help

- **Mautic Community**: [mautic.org/community](https://www.mautic.org/community)
- **Mautic Docs**: [docs.mautic.org](https://docs.mautic.org)
- **ESP Support**: Contact your email service provider directly

---

## Best Practices for Email Deliverability

1. **Always authenticate your domain** - Use DKIM, SPF, and DMARC
2. **Start with a warm-up** - Gradually increase sending volume
3. **Maintain list hygiene** - Remove bounces and inactive subscribers
4. **Use double opt-in** - Confirm subscription with email verification
5. **Monitor metrics** - Track opens, clicks, bounces, and complaints
6. **Respect unsubscribes** - Honor opt-outs immediately
7. **Send relevant content** - Segment your audience and personalize messages
8. **Test before sending** - Always send test emails before broadcasts

---

**Need Help?** If you're stuck or have questions about ESP configuration, reach out to the Mautic community or consult your ESP's documentation. Happy sending!
