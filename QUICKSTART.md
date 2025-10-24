# Mautic 6 on Railway - Quick Start Guide

Get your Mautic 6 email marketing platform running on Railway.app in 20 minutes or less.

## Prerequisites

- [ ] GitHub account
- [ ] Railway.app account
- [ ] Email provider account (SendGrid, Mailgun, etc.)

## 5-Step Deployment

### 1️⃣ Fork This Repository

Click the "Fork" button on this repository to create your own copy.

### 2️⃣ Deploy to Railway

1. Go to [Railway.app](https://railway.app/) and log in with GitHub
2. Click **"New Project"** → **"Deploy from GitHub repo"**
3. Select your forked repository
4. Wait for initial deployment (~5 minutes)

### 3️⃣ Add Database

1. In your Railway project, click **"+ New"** → **"Database"** → **"MySQL"**
2. Railway automatically connects it via `DATABASE_URL`
3. (Optional but recommended) Add **Redis** the same way

### 4️⃣ Configure Email

1. Click on your Mautic service → **"Variables"** tab
2. Click **"New Variable"** and add:

**Required variables:**
```env
APP_SECRET=your-random-32-char-string
MAUTIC_URL=https://your-app.up.railway.app
MAILER_FROM_EMAIL=hello@yourdomain.com
MAILER_FROM_NAME=Your Company
MAILER_DSN=sendgrid+api://YOUR_SENDGRID_API_KEY@default
```

**How to get values:**
- `APP_SECRET`: [Generate here](https://www.random.org/strings/?num=1&len=32&digits=on&loweralpha=on&unique=on&format=html&rnd=new)
- `MAUTIC_URL`: Found in Settings → Domains (after generating domain)
- `MAILER_DSN`: Get API key from your email provider (see `.env.example` for all options)

3. Click **"Add"** - Railway will automatically redeploy

### 5️⃣ Complete Installation

1. Visit your Railway app URL (Settings → Domains)
2. Follow the Mautic installation wizard:
   - Database: Click "Next" (already configured)
   - Admin: Create your admin account
   - Email: Click "Next" (already configured)
3. Done! Log in to Mautic

## Set Up Cron Jobs (Required)

Mautic needs cron jobs to send emails and process campaigns:

**Easiest option - cron-job.org (Free):**

1. Sign up at [cron-job.org](https://cron-job.org/)
2. Add these cron jobs (replace `YOUR-APP` with your Railway URL):

```
URL: https://YOUR-APP.up.railway.app/s/update/segments
Schedule: */10 * * * * (every 10 minutes)

URL: https://YOUR-APP.up.railway.app/s/update/campaigns
Schedule: */10 * * * *

URL: https://YOUR-APP.up.railway.app/s/send/emails
Schedule: */10 * * * *
```

See [CRON_SETUP.md](./CRON_SETUP.md) for more options.

## Verify Everything Works

- [ ] Can log in to Mautic admin
- [ ] Create a test contact
- [ ] Send a test email
- [ ] Check cron jobs are running (Settings → System Info)

## Next Steps

✅ **Set up monitoring:** [AI_MONITORING_SOLUTION.md](./AI_MONITORING_SOLUTION.md)
✅ **Configure domain:** Add custom domain in Railway settings
✅ **Import contacts:** Contacts → Import → Upload CSV
✅ **Create campaign:** Campaigns → New Campaign

## Costs

| Item | Cost | Notes |
|------|------|-------|
| Railway Starter | $5/month | For small lists (<1,000 contacts) |
| Railway Developer | $20/month | For medium lists (1,000-10,000 contacts) |
| Email Provider | $0-20/month | Most have free tiers |
| Cron Service | Free | cron-job.org |
| **Total** | **$5-40/month** | Depends on scale |

## Getting Help

- **Full Deployment Guide:** [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)
- **Email Configuration:** [.env.example](./.env.example)
- **Mautic Docs:** https://docs.mautic.org/
- **Railway Docs:** https://docs.railway.app/

## Common Issues

**"Database connection failed"**
→ Wait 2-3 minutes for database to start, then redeploy

**"Emails not sending"**
→ Check `MAILER_DSN` is correct and API key is valid

**"Page not found"**
→ Verify `MAUTIC_URL` matches your Railway domain exactly (no trailing slash)

**"Cron jobs not running"**
→ Set up external cron service (see [CRON_SETUP.md](./CRON_SETUP.md))

---

**You're ready to go!** 🚀

Deploy now and have Mautic running in 20 minutes.
