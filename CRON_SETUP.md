# Mautic 6 Cron Jobs Setup Guide

Mautic requires periodic background tasks (cron jobs) to process campaigns, send emails, update segments, and perform other automated tasks. This guide covers multiple ways to set up cron jobs for your Railway-deployed Mautic instance.

## Table of Contents

1. [Understanding Mautic Cron Jobs](#understanding-mautic-cron-jobs)
2. [Option 1: External Cron Service (Recommended for Railway)](#option-1-external-cron-service-recommended-for-railway)
3. [Option 2: Railway Cron Plugin](#option-2-railway-cron-plugin)
4. [Option 3: In-Container Cron](#option-3-in-container-cron)
5. [Monitoring Cron Jobs](#monitoring-cron-jobs)

---

## Understanding Mautic Cron Jobs

Mautic requires these core cron jobs to function properly:

| Command | Purpose | Recommended Frequency |
|---------|---------|----------------------|
| `mautic:segments:update` | Update contact segments | Every 5-15 minutes |
| `mautic:campaigns:update` | Rebuild campaigns | Every 5-15 minutes |
| `mautic:campaigns:trigger` | Trigger campaign actions | Every 5-15 minutes |
| `mautic:emails:send` | Send scheduled emails | Every 5-15 minutes |
| `mautic:broadcasts:send` | Send broadcast emails | Every 5-15 minutes |
| `mautic:messages:send` | Send marketing messages | Every 5-15 minutes |
| `mautic:social:monitoring` | Monitor social media | Every 15 minutes |
| `mautic:webhooks:process` | Process webhooks queue | Every 1-5 minutes |
| `mautic:reports:scheduler` | Generate scheduled reports | Daily at 2 AM |
| `mautic:maintenance:cleanup` | Clean up old data | Daily at 3 AM |

---

## Option 1: External Cron Service (Recommended for Railway)

External cron services are the simplest and most reliable option for Railway deployments since Railway doesn't have built-in cron scheduling.

### Recommended Services

#### 1. EasyCron (Recommended)

**Why:** Reliable, affordable, easy to use
**Free Tier:** 1 cron job with 1-hour intervals
**Paid:** From $1.99/month for unlimited jobs at 1-minute intervals

**Setup Steps:**

1. **Sign up at EasyCron**
   - Go to: https://www.easycron.com/
   - Create a free account

2. **Create API Authentication Token**
   - In Mautic, go to Settings > Configuration > API Settings
   - Enable API
   - Create a new OAuth client
   - Copy Client ID and Secret

3. **Add Cron Jobs in EasyCron**

   For each command, create a new cron job:

   **Segments Update:**
   - URL: `https://your-app.up.railway.app/s/update/segments`
   - Interval: Every 5 minutes
   - Name: "Mautic Segments Update"

   **Campaigns Update:**
   - URL: `https://your-app.up.railway.app/s/update/campaigns`
   - Interval: Every 5 minutes

   **Campaigns Trigger:**
   - URL: `https://your-app.up.railway.app/s/update/triggers`
   - Interval: Every 5 minutes

   **Email Send:**
   - URL: `https://your-app.up.railway.app/s/send/emails`
   - Interval: Every 5 minutes

4. **Verify Execution**
   - In Mautic: Settings > System Info > Cron Jobs
   - Check "Last Run" timestamps

---

#### 2. cron-job.org

**Why:** Free, reliable, no registration required for basic use
**Free Tier:** Unlimited jobs, minimum 1-minute intervals

**Setup Steps:**

1. **Go to cron-job.org**
   - URL: https://cron-job.org/

2. **Create Free Account**
   - Sign up with email

3. **Add Cron Jobs**

   Click "Create Cronjob" for each:

   ```
   Title: Mautic Segments Update
   URL: https://your-app.up.railway.app/s/update/segments
   Schedule: */5 * * * * (every 5 minutes)
   ```

   ```
   Title: Mautic Campaigns Update
   URL: https://your-app.up.railway.app/s/update/campaigns
   Schedule: */5 * * * * (every 5 minutes)
   ```

   ```
   Title: Mautic Campaigns Trigger
   URL: https://your-app.up.railway.app/s/update/triggers
   Schedule: */5 * * * * (every 5 minutes)
   ```

   ```
   Title: Mautic Email Send
   URL: https://your-app.up.railway.app/s/send/emails
   Schedule: */5 * * * * (every 5 minutes)
   ```

4. **Enable Notifications**
   - Set up email alerts for failed cron jobs
   - cron-job.org will notify you if a job fails

---

#### 3. GitHub Actions (Free)

**Why:** Already integrated if you're using the AI monitoring solution
**Free Tier:** 2000 minutes/month
**Cost:** Free for most use cases

**Setup Steps:**

Create `.github/workflows/mautic-cron.yml`:

```yaml
name: Mautic Cron Jobs

on:
  schedule:
    # Runs every 5 minutes
    - cron: '*/5 * * * *'
    # Daily maintenance at 2 AM UTC
    - cron: '0 2 * * *'
  workflow_dispatch:

jobs:
  frequent-tasks:
    if: github.event.schedule == '*/5 * * * *'
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Segments Update
        run: curl -f https://${{ vars.MAUTIC_URL }}/s/update/segments

      - name: Trigger Campaigns Update
        run: curl -f https://${{ vars.MAUTIC_URL }}/s/update/campaigns

      - name: Trigger Campaigns Actions
        run: curl -f https://${{ vars.MAUTIC_URL }}/s/update/triggers

      - name: Send Emails
        run: curl -f https://${{ vars.MAUTIC_URL }}/s/send/emails

      - name: Send Broadcasts
        run: curl -f https://${{ vars.MAUTIC_URL }}/s/send/broadcasts

  daily-tasks:
    if: github.event.schedule == '0 2 * * *'
    runs-on: ubuntu-latest
    steps:
      - name: Generate Scheduled Reports
        run: curl -f https://${{ vars.MAUTIC_URL }}/s/reports/scheduler

      - name: Cleanup Old Data
        run: curl -f https://${{ vars.MAUTIC_URL }}/s/maintenance/cleanup
```

**Benefits:**
- Free
- Already have GitHub account
- Logs available in Actions tab
- Can add error notifications easily

---

## Option 2: Railway Cron Plugin

Railway has experimental support for cron jobs through a separate service.

### Setup Steps

1. **Add New Service to Railway Project**
   - In Railway project, click "+ New"
   - Select "Empty Service"
   - Name it "Mautic Cron"

2. **Deploy Cron Runner**

   Create a new repository with these files:

   **`Dockerfile`:**
   ```dockerfile
   FROM alpine:3.18

   RUN apk add --no-cache curl dcron bash

   COPY crontab /etc/crontabs/root
   COPY entrypoint.sh /entrypoint.sh
   RUN chmod +x /entrypoint.sh

   CMD ["/entrypoint.sh"]
   ```

   **`crontab`:**
   ```cron
   # Mautic Cron Jobs
   */5 * * * * curl -f $MAUTIC_URL/s/update/segments
   */5 * * * * curl -f $MAUTIC_URL/s/update/campaigns
   */5 * * * * curl -f $MAUTIC_URL/s/update/triggers
   */5 * * * * curl -f $MAUTIC_URL/s/send/emails
   */5 * * * * curl -f $MAUTIC_URL/s/send/broadcasts
   0 2 * * * curl -f $MAUTIC_URL/s/reports/scheduler
   0 3 * * * curl -f $MAUTIC_URL/s/maintenance/cleanup
   ```

   **`entrypoint.sh`:**
   ```bash
   #!/bin/bash
   echo "Starting Mautic cron service for $MAUTIC_URL"
   crond -f -l 2
   ```

3. **Connect to Railway**
   - Push this repository to GitHub
   - In Railway "Mautic Cron" service, connect this repository
   - Add environment variable: `MAUTIC_URL` = your Mautic URL

4. **Deploy**
   - Railway will build and deploy the cron service
   - Cron jobs will run automatically

**Cost:** ~$5/month (separate Railway service)

---

## Option 3: In-Container Cron

Run cron inside your Mautic container (not recommended for Railway, but possible).

### Modify Your Dockerfile

Add to your Dockerfile:

```dockerfile
# Install cron
RUN apk add --no-cache dcron

# Add crontab
COPY docker/crontab /etc/crontabs/www-data
```

Create `docker/crontab`:

```cron
*/5 * * * * cd /app/docroot && php bin/console mautic:segments:update
*/5 * * * * cd /app/docroot && php bin/console mautic:campaigns:update
*/5 * * * * cd /app/docroot && php bin/console mautic:campaigns:trigger
*/5 * * * * cd /app/docroot && php bin/console mautic:emails:send
*/5 * * * * cd /app/docroot && php bin/console mautic:broadcasts:send
0 2 * * * cd /app/docroot && php bin/console mautic:reports:scheduler
0 3 * * * cd /app/docroot && php bin/console mautic:maintenance:cleanup
```

Update `docker/supervisor/supervisord.conf`:

```ini
[program:cron]
command=crond -f
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
autorestart=true
```

**Drawback:** If your container restarts, cron jobs are interrupted.

---

## Monitoring Cron Jobs

### 1. Mautic Built-in Monitoring

Check in Mautic:
1. Go to **Settings** > **System Info**
2. Scroll to **Cron Jobs** section
3. Verify "Last Run" timestamps are recent

### 2. External Monitoring with Cronitor

**Setup:**

1. Sign up at https://cronitor.io/
2. Create a new monitor for each cron job
3. Get monitor URL (e.g., `https://cronitor.link/p/abc123/job-name`)
4. Update your cron commands:

   ```bash
   curl https://your-app.up.railway.app/s/update/segments && \
   curl https://cronitor.link/p/abc123/segments
   ```

**Benefits:**
- Get alerts if cron jobs fail
- Historical execution data
- Performance metrics

### 3. Logs

Check execution in Railway logs:
```bash
railway logs --project your-project --service your-service
```

Look for:
```
[2024-10-24 12:00:01] Segments updated: 150 contacts
[2024-10-24 12:05:01] Campaigns triggered: 25 actions
[2024-10-24 12:10:01] Emails sent: 100 messages
```

---

## Recommended Setup for Different Scales

### Small (< 1,000 contacts)
- **Service:** cron-job.org (free)
- **Frequency:** Every 15 minutes
- **Cost:** $0

### Medium (1,000 - 10,000 contacts)
- **Service:** EasyCron or GitHub Actions
- **Frequency:** Every 5 minutes
- **Cost:** $0-2/month

### Large (10,000+ contacts)
- **Service:** Railway Cron Service
- **Frequency:** Every 1-5 minutes
- **Cost:** ~$5/month
- **Bonus:** Add Cronitor monitoring ($10/month)

---

## Troubleshooting

### Cron Jobs Not Running

**Check:**
1. URL is accessible: `curl https://your-app.up.railway.app/s/update/segments`
2. Mautic cron endpoints are enabled in configuration
3. External service has correct credentials
4. Railway service is running

### Emails Not Sending

**Check:**
1. `mautic:emails:send` is running every 5 minutes
2. Email queue in Mautic: Channels > Emails > check pending count
3. MAILER_DSN is correctly configured
4. Check Railway logs for email send errors

### High Database Load

**Solution:**
- Reduce cron frequency to every 15 minutes
- Optimize segment filters
- Add database indexes
- Upgrade Railway plan for better database performance

---

## Quick Start: Recommended Configuration

For most users, use **cron-job.org** with these exact settings:

1. **Sign up:** https://cron-job.org/
2. **Add these 5 cron jobs:**

| Name | URL | Schedule |
|------|-----|----------|
| Segments | `https://YOUR-APP.up.railway.app/s/update/segments` | `*/10 * * * *` |
| Campaigns | `https://YOUR-APP.up.railway.app/s/update/campaigns` | `*/10 * * * *` |
| Triggers | `https://YOUR-APP.up.railway.app/s/update/triggers` | `*/10 * * * *` |
| Emails | `https://YOUR-APP.up.railway.app/s/send/emails` | `*/10 * * * *` |
| Cleanup | `https://YOUR-APP.up.railway.app/s/maintenance/cleanup` | `0 3 * * *` |

3. **Enable email notifications** for all jobs
4. **Done!** Verify in Mautic after 10 minutes

---

**Total Setup Time:** 10 minutes
**Cost:** Free
**Reliability:** High

You're all set! Your Mautic instance will now process campaigns, send emails, and update segments automatically. 🎉
