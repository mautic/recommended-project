# Mautic 6 Railway Deployment Guide for Non-Technical Users

Welcome! This guide will walk you through deploying your own Mautic 6 email marketing platform on Railway.app, even if you have no technical experience. Follow each step carefully, and you'll have a fully functional Mautic installation in about 30 minutes.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [What You'll Need](#what-youll-need)
3. [Step-by-Step Deployment](#step-by-step-deployment)
4. [Configuring Your Email Provider](#configuring-your-email-provider)
5. [First-Time Setup](#first-time-setup)
6. [Troubleshooting](#troubleshooting)
7. [Cost Estimates](#cost-estimates)
8. [Next Steps](#next-steps)

---

## Prerequisites

Before you begin, you'll need:

1. **A Railway.app account** (Free to start)
   - Sign up at: https://railway.app/
   - You can use your GitHub account to sign in

2. **A GitHub account** (Free)
   - Sign up at: https://github.com/ if you don't have one

3. **An email service provider account** (Most have free tiers)
   - Options: SendGrid, Mailgun, Postmark, Amazon SES, etc.
   - We'll configure this later

4. **A domain name** (Optional but recommended)
   - You can use Railway's free subdomain to start
   - Custom domains improve email deliverability

---

## What You'll Need

### Information to Gather

Have these ready before you start:

- [ ] Railway.app account credentials
- [ ] GitHub account credentials
- [ ] Email provider API key or SMTP credentials
- [ ] A strong password for your Mautic admin account
- [ ] Your "from" email address (e.g., hello@yourdomain.com)

---

## Step-by-Step Deployment

### Step 1: Fork This Repository to Your GitHub Account

1. **Go to this repository on GitHub**
   - URL: https://github.com/your-username/recommended-project-6

2. **Click the "Fork" button** (top right corner)
   - This creates your own copy of the template

3. **Wait for the fork to complete**
   - GitHub will redirect you to your forked repository

### Step 2: Sign Up for Railway.app

1. **Go to Railway.app**
   - URL: https://railway.app/

2. **Click "Login" and select "Login with GitHub"**
   - This connects your GitHub account to Railway

3. **Authorize Railway** to access your GitHub account
   - Click "Authorize Railway"

### Step 3: Create a New Railway Project

1. **Click "New Project"** on your Railway dashboard

2. **Select "Deploy from GitHub repo"**

3. **Choose your forked repository**
   - Find: `your-username/recommended-project-6`
   - Click on it to select

4. **Railway will start deploying**
   - This may take 5-10 minutes for the first deployment

### Step 4: Add a Database to Your Project

Mautic needs a database to store your contacts, campaigns, and settings.

1. **In your Railway project, click "+ New"**

2. **Select "Database"**

3. **Choose "MySQL"** or **"MariaDB"**
   - Either works great with Mautic
   - MariaDB is recommended (better performance)

4. **Railway automatically connects the database**
   - The `DATABASE_URL` environment variable is auto-configured

### Step 5: Add Redis for Better Performance (Optional but Recommended)

Redis makes Mautic faster and more responsive.

1. **Click "+ New" again**

2. **Select "Database"**

3. **Choose "Redis"**

4. **Railway automatically connects Redis**
   - The `REDIS_URL` environment variable is auto-configured

### Step 6: Configure Environment Variables

Now you'll tell Mautic how to work with your setup.

1. **Click on your Mautic service** (the main deployment)

2. **Go to the "Variables" tab**

3. **Add these required variables:**

   Click "New Variable" for each one:

   | Variable Name | Example Value | Description |
   |---------------|---------------|-------------|
   | `APP_SECRET` | `a1b2c3d4e5f6...` | Random 32-character string ([Generate here](https://www.random.org/strings/?num=1&len=32&digits=on&loweralpha=on&unique=on&format=html&rnd=new)) |
   | `MAUTIC_URL` | `https://your-app.up.railway.app` | Your Railway app URL (found in Settings > Domains) |
   | `MAILER_FROM_EMAIL` | `hello@yourdomain.com` | Your "from" email address |
   | `MAILER_FROM_NAME` | `Your Company Name` | Your "from" name |
   | `MAILER_DSN` | See [Email Configuration](#configuring-your-email-provider) | Your email provider settings |

4. **Click "Add" for each variable**

5. **Your app will automatically redeploy** with the new settings

### Step 7: Set Up Your Domain (Optional)

1. **In your Mautic service, go to "Settings" > "Domains"**

2. **Click "Generate Domain"** for a free Railway subdomain
   - Example: `your-app-name.up.railway.app`

3. **Or add a custom domain:**
   - Click "Custom Domain"
   - Enter your domain (e.g., `mautic.yourdomain.com`)
   - Follow the DNS configuration instructions
   - Update `MAUTIC_URL` environment variable with your custom domain

---

## Configuring Your Email Provider

Choose ONE email provider and copy its configuration:

### SendGrid (Recommended for Beginners)

1. **Sign up at SendGrid**: https://signup.sendgrid.com/
2. **Create an API key**: Settings > API Keys > Create API Key
3. **Copy your API key**
4. **Set MAILER_DSN to:**
   ```
   sendgrid+api://YOUR_API_KEY@default
   ```

**Free tier**: 100 emails/day forever

---

### Mailgun

1. **Sign up at Mailgun**: https://signup.mailgun.com/
2. **Get your API key**: Settings > API Keys
3. **Find your domain**: Sending > Domains
4. **Set MAILER_DSN to:**
   ```
   mailgun+https://YOUR_API_KEY:YOUR_DOMAIN@default?region=us
   ```
   For EU: Change `region=us` to `region=eu`

**Free tier**: 5,000 emails/month for 3 months

---

### Postmark

1. **Sign up at Postmark**: https://account.postmarkapp.com/sign_up
2. **Create a server**: Servers > Create Server
3. **Get your Server API Token**: Server > API Tokens
4. **Set MAILER_DSN to:**
   ```
   postmark+api://YOUR_SERVER_TOKEN@default
   ```

**Free tier**: 100 emails/month forever

---

### Amazon SES

1. **Sign up for AWS**: https://aws.amazon.com/
2. **Enable SES**: https://console.aws.amazon.com/ses/
3. **Create SMTP credentials**: SMTP Settings > Create My SMTP Credentials
4. **Set MAILER_DSN to:**
   ```
   ses+smtp://YOUR_ACCESS_KEY:YOUR_SECRET_KEY@default?region=us-east-1
   ```

**Free tier**: 62,000 emails/month (when sending from EC2)

---

### Resend (Modern & Simple)

1. **Sign up at Resend**: https://resend.com/signup
2. **Create an API key**: API Keys > Create API Key
3. **Set MAILER_DSN to:**
   ```
   resend+api://YOUR_API_KEY@default
   ```

**Free tier**: 3,000 emails/month forever

---

### Generic SMTP (Any Provider)

If your provider isn't listed, use generic SMTP:

```
smtp://USERNAME:PASSWORD@smtp.example.com:587?encryption=tls
```

Replace:
- `USERNAME` with your SMTP username
- `PASSWORD` with your SMTP password
- `smtp.example.com` with your SMTP server
- `587` with your SMTP port (usually 587 or 465)
- `encryption=tls` or `encryption=ssl` as needed

---

## First-Time Setup

### Method 1: Web Installer (Recommended)

1. **Visit your Mautic URL** in a web browser
   - Example: `https://your-app.up.railway.app`

2. **The installation wizard will appear**
   - Follow the on-screen instructions

3. **Database Configuration**
   - Click "Next" (Railway auto-configured this)

4. **Create Admin User**
   - Enter your desired username
   - Create a strong password
   - Enter your email address
   - Click "Next"

5. **Email Configuration**
   - Select "Other SMTP Server"
   - The settings from your `MAILER_DSN` are automatically used
   - Click "Next"

6. **Installation Complete!**
   - Click "Go to Mautic"
   - Log in with your admin credentials

### Method 2: Automated Installation (Advanced)

If you want to skip the web installer:

1. **Add these environment variables in Railway:**

   | Variable Name | Example Value |
   |---------------|---------------|
   | `MAUTIC_INSTALL_MODE` | `1` |
   | `MAUTIC_ADMIN_USERNAME` | `admin` |
   | `MAUTIC_ADMIN_PASSWORD` | `YourSecurePassword123!` |
   | `MAUTIC_ADMIN_EMAIL` | `admin@yourdomain.com` |
   | `MAUTIC_ADMIN_FIRSTNAME` | `Admin` |
   | `MAUTIC_ADMIN_LASTNAME` | `User` |

2. **Redeploy your app** (click "Deploy" in Railway)

3. **Wait for deployment to complete**

4. **Set `MAUTIC_INSTALL_MODE` to `0`** (important!)

5. **Visit your Mautic URL and log in**

---

## Troubleshooting

### Issue: "Database connection failed"

**Solution:**
1. Make sure you added a MySQL/MariaDB database to your Railway project
2. Check that `DATABASE_URL` is set in environment variables
3. Wait 2-3 minutes for the database to fully start

---

### Issue: "Emails not sending"

**Solution:**
1. Verify your `MAILER_DSN` is correctly formatted
2. Check that your API key is valid
3. Ensure your "from" email is verified with your ESP
4. Check Railway logs for specific errors:
   - Go to your service > "Deployments" > Click latest deployment > "View Logs"

---

### Issue: "Page not found" or "404 error"

**Solution:**
1. Make sure deployment completed successfully
2. Check that `MAUTIC_URL` matches your actual Railway domain
3. Try clearing your browser cache
4. Wait 5-10 minutes for DNS to propagate (if using custom domain)

---

### Issue: "Site is slow or timing out"

**Solution:**
1. Add Redis to your project (see Step 5)
2. Upgrade your Railway plan for more resources
3. Clear Mautic cache:
   - Go to Settings > System Settings > Clear Cache

---

### Issue: "Can't access admin panel"

**Solution:**
1. Check that you're using the correct admin credentials
2. Reset password via database if needed (contact support)
3. Check Railway logs for errors

---

## Cost Estimates

### Railway.app Plans

| Plan | Monthly Cost | Resources | Best For |
|------|--------------|-----------|----------|
| **Starter** | $5/month | 512MB RAM, Shared CPU | Testing, small lists (<1,000 contacts) |
| **Developer** | $20/month | 8GB RAM, 8 vCPU | Production, medium lists (1,000-10,000 contacts) |
| **Team** | Custom | Custom resources | Large lists (10,000+ contacts) |

**Note:** Railway charges based on usage. Estimates assume moderate email sending activity.

### Email Provider Costs

| Provider | Free Tier | Paid Plans Start At |
|----------|-----------|---------------------|
| **SendGrid** | 100 emails/day | $19.95/month (50,000 emails) |
| **Mailgun** | 5,000 emails/month (3 mo) | $35/month (50,000 emails) |
| **Postmark** | 100 emails/month | $15/month (10,000 emails) |
| **Amazon SES** | 62,000 emails/month | $0.10 per 1,000 emails |
| **Resend** | 3,000 emails/month | $20/month (50,000 emails) |

---

## Next Steps

### After Installation

1. **Configure your domain** (if you haven't already)
   - This improves email deliverability significantly

2. **Set up cron jobs for automation**
   - See: [Setting Up Cron Jobs](./CRON_SETUP.md)
   - Use Railway's cron feature or an external service like cron-job.org

3. **Configure SPF, DKIM, and DMARC records**
   - Essential for email deliverability
   - Your ESP will provide these settings

4. **Import your contacts**
   - Go to Contacts > Import
   - Upload a CSV file

5. **Create your first campaign**
   - Go to Campaigns > New Campaign
   - Follow Mautic's built-in wizard

6. **Watch video tutorials**
   - Mautic University: https://www.mautic.org/mautic-university
   - YouTube: Search "Mautic tutorials"

### Recommended Configurations

1. **Enable HTTPS** (automatically handled by Railway)
2. **Set up regular backups** (use Railway's backup features)
3. **Configure monitoring** (see AI monitoring section below)
4. **Install recommended plugins** (available in Mautic marketplace)

---

## Getting Help

- **Mautic Community Forum**: https://forum.mautic.org/
- **Mautic Slack**: https://www.mautic.org/slack
- **Documentation**: https://docs.mautic.org/
- **Railway Support**: https://railway.app/help

---

## Video Guide Script

*Coming soon: A companion video tutorial covering all deployment steps*

**Suggested Videos:**
1. "Deploying Mautic 6 on Railway.app (Part 1: Setup)" - 15 minutes
2. "Configuring Email Providers for Mautic (Part 2: Email)" - 10 minutes
3. "First Campaign in Mautic (Part 3: Getting Started)" - 20 minutes

---

## Need Professional Help?

If you need assistance with:
- Custom domain setup
- Email deliverability optimization
- Advanced automation workflows
- Migration from another platform
- Technical troubleshooting

Consider hiring a Mautic expert from:
- Mautic Community Slack (#consultants channel)
- Upwork or Fiverr (search "Mautic expert")
- Your repository maintainer's consulting services

---

**Congratulations!** You now have a production-ready Mautic 6 installation. Happy email marketing!
