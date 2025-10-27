# Inbox SOS - Mautic 6 Deployment Guide for Railway.com

Welcome! This guide will walk you through deploying your own Mautic 6 instance on Railway.com. Even if you're not technical, we've made this process simple and straightforward. Let's get started!

## Table of Contents

- [What You'll Need](#what-youll-need)
- [Step 1: Create a Railway Account](#step-1-create-a-railway-account)
- [Step 2: Create a New Project](#step-2-create-a-new-project)
- [Step 3: Deploy the Mautic Template](#step-3-deploy-the-mautic-template)
- [Step 4: Add MySQL Database](#step-4-add-mysql-database)
- [Step 5: Add Redis Cache](#step-5-add-redis-cache)
- [Step 6: Configure Environment Variables](#step-6-configure-environment-variables)
- [Step 7: Access Your Mautic Instance](#step-7-access-your-mautic-instance)
- [Step 8: Complete Initial Setup](#step-8-complete-initial-setup)
- [Step 9: Configure Your Email Provider](#step-9-configure-your-email-provider)
- [Step 10: Set Up Custom Domain (Optional)](#step-10-set-up-custom-domain-optional)
- [Monitoring and Maintenance](#monitoring-and-maintenance)
- [Troubleshooting](#troubleshooting)
- [Scaling Your Instance](#scaling-your-instance)
- [Getting Help](#getting-help)

---

## What You'll Need

Before you begin, make sure you have:

- ✅ A Railway.com account (free to start)
- ✅ A credit card for Railway verification (free tier available)
- ✅ An email service provider account (Amazon SES, Brevo, Mailgun, SendGrid, or Postmark)
- ✅ About 15-20 minutes to complete the setup

**Cost Estimate**: Railway offers a free tier with $5 credit/month. For small to medium email lists, you can typically stay within or just above the free tier (~$5-10/month). Enterprise users may need more resources.

---

## Step 1: Create a Railway Account

1. Go to [railway.app](https://railway.app)
2. Click **Start a New Project** or **Sign Up**
3. Sign up with GitHub, Google, or Email
4. Verify your email address
5. Add a payment method (required even for free tier)

---

## Step 2: Create a New Project

1. Once logged in, click **New Project**
2. You'll see several deployment options
3. Keep this window open - we'll return to it in the next step

---

## Step 3: Deploy the Mautic Template

There are two ways to deploy this template:

### Option A: Deploy from Railway Template (Recommended)

1. In Railway, click **Deploy from Template**
2. Search for "Inbox SOS Mautic" or "Mautic 6"
3. Click on the template
4. Click **Deploy Now**
5. Railway will automatically create the project with all services

### Option B: Deploy from GitHub Repository

1. In Railway, click **Deploy from GitHub repo**
2. Connect your GitHub account if not already connected
3. Select the repository containing this template
4. Click **Deploy**
5. Wait for the initial deployment (this may take 5-10 minutes)

**What's happening?** Railway is:
- Building a Docker container with Mautic 6
- Installing PHP, Apache, and all dependencies
- Setting up the application structure

---

## Step 4: Add MySQL Database

Mautic needs a database to store your contacts, campaigns, and settings.

1. In your Railway project, click **New Service**
2. Select **Database**
3. Choose **MySQL**
4. Railway will automatically provision a MySQL instance
5. Railway will automatically connect it to your Mautic service via `DATABASE_URL`

**That's it!** Railway handles all the database connection details automatically.

---

## Step 5: Add Redis Cache

Redis dramatically improves Mautic's performance, especially for larger contact lists.

1. In your Railway project, click **New Service**
2. Select **Database**
3. Choose **Redis**
4. Railway will automatically provision a Redis instance
5. Railway will automatically connect it to your Mautic service via `REDIS_URL`

**Why Redis?** It speeds up:
- Contact segment calculations
- Campaign processing
- Email queue management
- Page load times

---

## Step 6: Configure Environment Variables

Now we need to set a few important variables.

1. Click on your **Mautic service** (not database or Redis)
2. Go to the **Variables** tab
3. Add the following variables:

### Required Variables

**MAUTIC_SECRET_KEY** (Critical for security)
```
Click "Generate" or create a random 32+ character string
Example: f8a7d9c2e1b4a5c6d8e9f1a2b3c4d5e6f7a8b9c1d2e3f4a5b6c7d8e9f1a2b3c4
```

**MAILER_FROM_NAME**
```
Your Company Name
Example: Acme Marketing
```

**MAILER_FROM_EMAIL**
```
noreply@yourdomain.com
Example: hello@acmemarketing.com
```

### Optional Variables (can configure later)

**MAUTIC_TIMEZONE**
```
Your timezone (default: UTC)
Example: America/New_York
```

**MAUTIC_LOCALE**
```
Your language (default: en_US)
Example: en_US, fr_FR, es_ES
```

4. Click **Deploy** after adding variables
5. Wait for the service to redeploy (1-2 minutes)

---

## Step 7: Access Your Mautic Instance

1. In your Railway project, click on your Mautic service
2. Go to the **Settings** tab
3. Scroll to **Networking**
4. You'll see a **Public URL** (e.g., `mautic-production-abc123.up.railway.app`)
5. Click the URL or copy it to your browser
6. Your Mautic installation will open!

**Note**: The first load may take 30-60 seconds as the system initializes the database.

---

## Step 8: Complete Initial Setup

When you first access Mautic, you'll see the setup wizard:

### Page 1: Environment Check
- Mautic will verify all requirements
- Everything should show green checkmarks ✅
- Click **Next Step**

### Page 2: Database Configuration
- **Skip this page** - Railway already configured the database
- Click **Next Step**

### Page 3: Create Admin User
- **Username**: Choose an admin username (e.g., `admin`)
- **First Name**: Your first name
- **Last Name**: Your last name
- **Email**: Your email address (you'll use this to log in)
- **Password**: Choose a strong password (use a password manager!)
- **Confirm Password**: Enter password again
- Click **Next Step**

### Page 4: Email Configuration
- **Skip for now** - We'll configure this in the next step
- Click **Next Step**

### Page 5: Complete!
- Click **Go to Mautic**
- Log in with the credentials you just created

🎉 **Congratulations!** You now have a running Mautic instance!

---

## Step 9: Configure Your Email Provider

Now let's connect your email service provider so you can send emails.

1. In Mautic, click the **gear icon** (⚙️) in the top right
2. Go to **Configuration**
3. Click the **Email Settings** tab
4. Follow the detailed guide for your ESP in [ESP_CONFIGURATION.md](./ESP_CONFIGURATION.md):
   - [Amazon SES](./ESP_CONFIGURATION.md#amazon-ses-configuration)
   - [Brevo](./ESP_CONFIGURATION.md#brevo-configuration)
   - [Mailgun](./ESP_CONFIGURATION.md#mailgun-configuration)
   - [SendGrid](./ESP_CONFIGURATION.md#sendgrid-configuration)
   - [Postmark](./ESP_CONFIGURATION.md#postmark-configuration)
5. After configuring, click **Send Test Email**
6. Verify the test email arrives
7. Click **Save & Close**

**Important**: Don't skip the test email! This ensures everything is working before you send to real contacts.

---

## Step 10: Set Up Custom Domain (Optional)

Using a custom domain improves deliverability and branding.

### In Railway:

1. Go to your Mautic service **Settings**
2. Scroll to **Networking** > **Custom Domains**
3. Click **Add Domain**
4. Enter your domain (e.g., `marketing.yourdomain.com`)
5. Railway will provide DNS records to add

### In Your Domain Provider (e.g., GoDaddy, Namecheap, Cloudflare):

1. Add a **CNAME** record:
   - **Name**: marketing (or your subdomain)
   - **Value**: The Railway-provided value
   - **TTL**: 3600 or Auto
2. Save the record
3. Wait 5-60 minutes for DNS propagation
4. Return to Railway and verify the domain

### Update Mautic:

1. In Railway, add environment variable:
   ```
   MAUTIC_SITE_URL=https://marketing.yourdomain.com
   ```
2. Redeploy the service
3. Access Mautic via your custom domain

### Configure ESP for Custom Domain:

Don't forget to verify your custom domain in your ESP for better deliverability:
- Add SPF, DKIM, and DMARC records
- See your ESP's documentation for specific instructions

---

## Monitoring and Maintenance

### Checking System Health

1. In Mautic, go to **Settings** > **System Info**
2. Review:
   - **PHP Info**: Verify PHP version and settings
   - **Database Info**: Check database connection
   - **Logs**: Review errors and warnings

### Viewing Logs in Railway

1. Go to your Mautic service in Railway
2. Click the **Logs** tab
3. Monitor for errors or warnings

### Railway Metrics

Railway provides metrics for:
- **CPU usage**
- **Memory usage**
- **Network traffic**

Access these in the **Metrics** tab of your service.

### Backup Recommendations

**Database Backups:**
- Railway doesn't automatically backup databases
- Use Railway's database backup feature (available on paid plans)
- Or set up automated MySQL dumps to external storage

**Media Files:**
- Media files are stored in the container (not persistent by default)
- For production, consider using Railway Volumes or external storage (S3)

---

## Troubleshooting

### "Application Error" or "Service Unavailable"

1. Check Railway **Logs** tab for error messages
2. Verify all environment variables are set correctly
3. Ensure MySQL and Redis services are running
4. Try redeploying the service

### Can't Access Mautic URL

1. Check that the service is fully deployed (green checkmark in Railway)
2. Wait 1-2 minutes after deployment completes
3. Try clearing your browser cache
4. Check Railway service status page

### Database Connection Errors

1. Verify MySQL service is running in Railway
2. Check that `DATABASE_URL` is automatically set
3. Try restarting the MySQL service
4. Redeploy the Mautic service

### Emails Not Sending

1. Verify ESP credentials in Configuration > Email Settings
2. Send a test email and check logs
3. Review ESP_CONFIGURATION.md for your provider
4. Check ESP account for sending limits or blocks
5. Verify sender email/domain is authenticated

### Slow Performance

1. Verify Redis is connected (check `REDIS_URL` in Variables)
2. Check Railway Metrics for resource usage
3. Consider upgrading Railway plan for more resources
4. Review Mautic's campaign and segment processing settings

### Out of Memory Errors

1. Check Railway Metrics > Memory usage
2. Upgrade to a larger Railway plan
3. Optimize Mautic settings (reduce queue workers)

---

## Scaling Your Instance

As your contact list grows, you may need to scale your Mautic instance.

### Small to Medium (0-50,000 contacts)

- **Railway Plan**: Hobby (~$5-10/month)
- **Database**: Default MySQL instance
- **Redis**: Default Redis instance
- **Resources**: 512MB RAM, 0.5 vCPU

### Medium to Large (50,000-250,000 contacts)

- **Railway Plan**: Pro (~$20-50/month)
- **Database**: Upgraded MySQL with more storage
- **Redis**: Default Redis instance
- **Resources**: 2GB RAM, 1 vCPU

### Large to Enterprise (250,000+ contacts)

- **Railway Plan**: Pro with dedicated resources (~$100+/month)
- **Database**: High-performance MySQL with SSD
- **Redis**: Upgraded Redis for larger cache
- **Resources**: 4GB+ RAM, 2+ vCPU
- **Consider**: Separate queue worker service

### Upgrading Resources

1. Go to your service in Railway
2. Click **Settings** > **Resources**
3. Adjust CPU and Memory allocations
4. Click **Save**
5. Service will redeploy with new resources

---

## Getting Help

### Documentation

- **Mautic Docs**: [docs.mautic.org](https://docs.mautic.org)
- **Railway Docs**: [docs.railway.app](https://docs.railway.app)
- **ESP Configuration**: [ESP_CONFIGURATION.md](./ESP_CONFIGURATION.md)

### Community Support

- **Mautic Community**: [mautic.org/community](https://www.mautic.org/community)
- **Mautic Slack**: [mautic.org/slack](https://www.mautic.org/slack)
- **Mautic Forums**: [forum.mautic.org](https://forum.mautic.org)

### Professional Support

- **Mautic Partners**: [mautic.org/service-providers](https://www.mautic.org/service-providers)
- **Railway Support**: Available on paid plans

---

## Next Steps

Now that your Mautic instance is running, here's what to do next:

1. ✅ **Import your contacts** - Go to Contacts > Import
2. ✅ **Create segments** - Organize contacts into groups
3. ✅ **Build email templates** - Design beautiful emails
4. ✅ **Set up forms** - Capture leads on your website
5. ✅ **Create campaigns** - Automate your marketing
6. ✅ **Track website visitors** - Install Mautic tracking code
7. ✅ **Integrate apps** - Connect CRMs, Zapier, etc.

**Pro Tip**: Start small! Create one simple campaign, test it thoroughly, and gradually expand your automation.

---

## Security Best Practices

- 🔐 Use a strong admin password (20+ characters)
- 🔐 Enable two-factor authentication (2FA) if available
- 🔐 Keep Mautic updated (check for updates regularly)
- 🔐 Use HTTPS (Railway provides this by default)
- 🔐 Don't share your API keys publicly
- 🔐 Regularly review user access and permissions
- 🔐 Monitor login attempts in System Info > Logs

---

**You're all set!** 🚀

Your Inbox SOS Mautic installation is now ready for production use. Start building amazing email campaigns and automating your marketing!

**Questions?** Refer to the [ESP Configuration Guide](./ESP_CONFIGURATION.md) or reach out to the Mautic community.

---

*Last Updated: 2025-10-27*
*Version: Mautic 6.x on Railway.com*
