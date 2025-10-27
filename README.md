# Inbox SOS - Production-Ready Mautic 6 for Railway.com

> **Self-hosted email marketing automation made simple for marketers**

Welcome to Inbox SOS! This is a production-ready Mautic 6 template designed specifically for email marketers who want the power of self-hosted marketing automation without the technical complexity.

Whether you're a solopreneur sending thousands of emails per month or an enterprise sending millions, this template scales with your needs and gives you complete control over your email marketing infrastructure.

---

## 🚀 What is This?

**Inbox SOS** is a turnkey Mautic 6 deployment template for Railway.com that includes:

- ✅ **Mautic 6** - Latest stable version of the open-source marketing automation platform
- ✅ **Pre-configured ESP support** - Amazon SES, Brevo, Mailgun, SendGrid, Postmark
- ✅ **Production-optimized** - PHP 8.2, Apache, Redis caching, automated cron jobs
- ✅ **One-click deployment** - Deploy directly from Railway.com template
- ✅ **Auto-scaling infrastructure** - From small lists to enterprise volumes
- ✅ **Marketer-friendly docs** - Step-by-step guides written for non-technical users

**No command line. No server management. No DevOps required.**

---

## 🎯 Who is This For?

This template is perfect for:

- 📧 **Email marketers** seeking more control and better deliverability
- 💼 **Marketing agencies** managing multiple client campaigns
- 🚀 **SaaS companies** needing transactional + marketing email automation
- 🛍️ **E-commerce businesses** wanting to own their customer data
- 📊 **Data-conscious organizations** requiring self-hosted solutions
- 💰 **Cost-conscious teams** looking for affordable email infrastructure

---

## ✨ Key Features

### Email Service Provider Support

Pre-integrated with all major ESPs:
- **Amazon SES** - Cost-effective, scalable (pre-installed plugin)
- **Brevo** - All-in-one marketing platform
- **Mailgun** - Developer-friendly email API
- **SendGrid** - Enterprise-grade delivery
- **Postmark** - Transactional email specialist

Switch between providers anytime via the Mautic UI. No code changes needed!

### Production-Ready Infrastructure

- **PHP 8.2** with all required extensions
- **Apache** web server with security hardening
- **MySQL** database with automatic provisioning
- **Redis** for high-performance caching and queues
- **Automated cron jobs** for campaigns, segments, and email sending
- **Supervisord** for process management
- **Health checks** for reliability

### Scalability

Built to handle any volume:
- **Solopreneurs**: 0-10K contacts (~$5-10/month on Railway)
- **Small Business**: 10K-50K contacts (~$20-30/month)
- **Mid-Market**: 50K-250K contacts (~$50-100/month)
- **Enterprise**: 250K+ contacts (custom resources)

### Marketer-Friendly Documentation

- 📖 **Deployment Guide** - Step-by-step Railway.com setup
- 📧 **ESP Configuration** - Detailed guides for each email provider
- 🔧 **Troubleshooting** - Common issues and solutions
- 💡 **Best Practices** - Email deliverability tips

---

## 🏃 Quick Start

### Option 1: Deploy from Railway Template (Recommended)

1. **Create Railway account** at [railway.app](https://railway.app)
2. **Search for "Inbox SOS Mautic"** in Railway templates
3. **Click "Deploy Now"**
4. **Wait 5-10 minutes** for deployment
5. **Access your Mautic URL** and complete setup wizard

That's it! Railway automatically provisions MySQL, Redis, and all infrastructure.

### Option 2: Deploy from This Repository

1. **Fork this repository** to your GitHub account
2. **Create Railway account** at [railway.app](https://railway.app)
3. **New Project** > **Deploy from GitHub repo**
4. **Select this repository**
5. **Add MySQL service** (Railway > New > Database > MySQL)
6. **Add Redis service** (Railway > New > Database > Redis)
7. **Configure environment variables** (see [.env.example](.env.example))
8. **Deploy and wait** 5-10 minutes
9. **Access your Mautic URL** and complete setup

---

## 📚 Documentation

All documentation is written for **non-technical marketers**:

- **[🚀 Deployment Guide](docs/DEPLOYMENT_GUIDE.md)** - Complete Railway.com setup walkthrough
- **[📧 ESP Configuration Guide](docs/ESP_CONFIGURATION.md)** - Configure Amazon SES, Brevo, Mailgun, SendGrid, Postmark
- **[⚙️ Environment Variables](.env.example)** - Configuration options explained

---

## 🔧 What's Included?

### Core Components

```
├── Dockerfile                    # Production-ready PHP 8.2 + Apache container
├── docker/
│   ├── apache-vhost.conf        # Apache security + performance config
│   ├── supervisord.conf         # Process manager (Apache + cron + queues)
│   ├── mautic-cron              # Automated background jobs
│   └── startup.sh               # Initialization script
├── railway.toml                 # Railway deployment configuration
├── railway.json                 # Railway template metadata
├── composer.json                # PHP dependencies + ESP packages
├── .env.example                 # Environment variable template
└── docs/
    ├── DEPLOYMENT_GUIDE.md      # Step-by-step Railway setup
    └── ESP_CONFIGURATION.md     # Email provider setup guides
```

### Pre-Installed Email Service Provider Packages

- `symfony/amazon-mailer` - Amazon SES support
- `symfony/brevo-mailer` - Brevo (Sendinblue) support
- `symfony/mailgun-mailer` - Mailgun support
- `symfony/sendgrid-mailer` - SendGrid support
- `symfony/postmark-mailer` - Postmark support
- `pm-pmaas/etailors_amazon_ses` - Enhanced Amazon SES Bundle (auto-installed)

### Performance Optimizations

- **Redis caching** - Speeds up segment updates and campaign processing
- **OPcache** - PHP bytecode caching for faster execution
- **Apache compression** - Reduces bandwidth usage
- **Image optimization** - Efficient media handling
- **Queue workers** - Background processing for high-volume sending

### Security Features

- **HTTPS by default** - Railway provides SSL automatically
- **Security headers** - XSS protection, frame options, etc.
- **Trusted proxies** - Configured for Railway infrastructure
- **Session security** - HttpOnly, Secure, SameSite cookies
- **Directory protection** - Vendor and config directories locked down

---

## 💰 Cost Breakdown

### Railway.com Costs

**Free Tier**: $5 credit/month (hobby projects)

**Small Deployment** (0-50K contacts):
- Mautic service: ~$3-5/month
- MySQL: ~$2-3/month
- Redis: ~$1-2/month
- **Total: $6-10/month**

**Medium Deployment** (50K-250K contacts):
- Mautic service: ~$15-25/month
- MySQL: ~$5-10/month
- Redis: ~$3-5/month
- **Total: $23-40/month**

**Enterprise Deployment** (250K+ contacts):
- Custom resources
- **Estimated: $75-200+/month**

### Email Service Provider Costs

- **Amazon SES**: $0.10 per 1,000 emails
- **Brevo**: Free tier (300 emails/day), paid from $25/month
- **Mailgun**: Free tier (5,000 emails/month), paid from $35/month
- **SendGrid**: Free tier (100 emails/day), paid from $15/month
- **Postmark**: $10 per 10,000 emails

**Total Cost Example** (100K contacts, 500K emails/month):
- Railway: ~$30-40/month
- Amazon SES: ~$50/month
- **Total: $80-90/month**

Compare to hosted solutions like Mailchimp (~$300+/month for same volume)!

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Railway.com                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Mautic Service (Docker Container)               │   │
│  │  ┌────────────┐  ┌────────────┐  ┌───────────┐  │   │
│  │  │   Apache   │  │   Cron     │  │  Queue    │  │   │
│  │  │  (Web UI)  │  │ (Background│  │ (Workers) │  │   │
│  │  │  Port 80   │  │   Jobs)    │  │           │  │   │
│  │  └────────────┘  └────────────┘  └───────────┘  │   │
│  │         │              │                │         │   │
│  │         └──────────────┴────────────────┘         │   │
│  │                        │                          │   │
│  │           ┌────────────┴────────────┐             │   │
│  │           │                         │             │   │
│  │     ┌─────▼─────┐            ┌─────▼─────┐       │   │
│  │     │   MySQL   │            │   Redis   │       │   │
│  │     │ (Database)│            │  (Cache)  │       │   │
│  │     │           │            │           │       │   │
│  │     └───────────┘            └───────────┘       │   │
│  └──────────────────────────────────────────────────┘   │
│                         │                                │
│                         ▼                                │
│           ┌──────────────────────────┐                   │
│           │   Public HTTPS Domain    │                   │
│           │ your-app.railway.app     │                   │
│           └──────────────────────────┘                   │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │   Email Provider      │
              │ (SES/Brevo/Mailgun)   │
              └───────────────────────┘
                          │
                          ▼
                  ┌───────────────┐
                  │  Recipients   │
                  └───────────────┘
```

---

## 🔒 Security Best Practices

- ✅ **Use strong passwords** - 20+ characters for admin account
- ✅ **Enable 2FA** - If available in Mautic
- ✅ **Custom domain** - Use your own domain for better trust
- ✅ **Regular updates** - Keep Mautic updated for security patches
- ✅ **Secure API keys** - Never commit secrets to Git
- ✅ **Monitor logs** - Check for suspicious activity
- ✅ **Backup database** - Use Railway's backup features

---

## 📊 Monitoring & Maintenance

### Health Checks

Railway automatically monitors:
- HTTP health endpoint (`/s/health`)
- Service uptime
- Resource usage (CPU, memory, network)

### Logs

Access logs in Railway:
1. Go to your Mautic service
2. Click **Logs** tab
3. Monitor for errors or warnings

### Updates

To update Mautic:
1. Pull latest changes from this repository
2. Railway will automatically rebuild and deploy
3. Database migrations run automatically

---

## 🆘 Troubleshooting

### Common Issues

**Problem**: Can't access Mautic URL after deployment

**Solution**:
- Wait 2-3 minutes after deployment completes
- Check Railway Logs for errors
- Verify MySQL and Redis services are running

---

**Problem**: Emails not sending

**Solution**:
- Verify ESP credentials in Configuration > Email Settings
- Send test email from Mautic UI
- Check ESP account for sending limits
- Review [ESP Configuration Guide](docs/ESP_CONFIGURATION.md)

---

**Problem**: Slow performance

**Solution**:
- Verify Redis is connected (check REDIS_URL variable)
- Check Railway Metrics for resource usage
- Consider upgrading Railway plan
- Review cron job frequency settings

---

For more troubleshooting help, see [Deployment Guide](docs/DEPLOYMENT_GUIDE.md#troubleshooting).

---

## 🤝 Getting Help

### Documentation

- **Mautic Docs**: [docs.mautic.org](https://docs.mautic.org)
- **Railway Docs**: [docs.railway.app](https://docs.railway.app)
- **Deployment Guide**: [docs/DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md)
- **ESP Configuration**: [docs/ESP_CONFIGURATION.md](docs/ESP_CONFIGURATION.md)

### Community

- **Mautic Community**: [mautic.org/community](https://www.mautic.org/community)
- **Mautic Slack**: [mautic.org/slack](https://www.mautic.org/slack)
- **Mautic Forums**: [forum.mautic.org](https://forum.mautic.org)

### Professional Support

- **Mautic Partners**: [mautic.org/service-providers](https://www.mautic.org/service-providers)

---

## 🚀 What's Next?

After deployment, check out:

1. 📖 **[Complete the Deployment Guide](docs/DEPLOYMENT_GUIDE.md)** - Full setup walkthrough
2. 📧 **[Configure Your ESP](docs/ESP_CONFIGURATION.md)** - Set up email sending
3. 🎓 **[Mautic Documentation](https://docs.mautic.org)** - Learn Mautic features
4. 🎨 **Create email templates** - Design beautiful emails
5. 👥 **Import contacts** - Upload your contact list
6. 🤖 **Build campaigns** - Automate your marketing

---

## 📜 License

This project inherits the Mautic license:

- **Mautic Core**: GPL-2.0-or-later
- **This Template**: GPL-2.0-or-later

See Mautic's [LICENSE](https://github.com/mautic/mautic/blob/6.x/LICENSE.txt) for details.

---

## 🙏 Credits

Built with:
- **[Mautic](https://mautic.org)** - Open-source marketing automation
- **[Railway.com](https://railway.app)** - Modern hosting platform
- **[Amazon SES Bundle](https://github.com/pm-pmaas/etailors_amazon_ses)** - Enhanced SES integration

---

## 📮 Support This Project

If this template saves you time and money:
- ⭐ **Star this repository**
- 🐦 **Share with other marketers**
- 💖 **Contribute to [Mautic](https://opencollective.com/mautic)**

---

## 🎯 About Inbox SOS

**Inbox SOS** is dedicated to making self-hosted email marketing accessible to all marketers, regardless of technical skill level. We believe marketers should have full control over their email infrastructure without needing a computer science degree.

---

**Ready to get started?**

👉 **[Deploy Now on Railway.com](https://railway.app)** or follow the **[Deployment Guide](docs/DEPLOYMENT_GUIDE.md)**

---

*Questions? Check the [Deployment Guide](docs/DEPLOYMENT_GUIDE.md) or reach out to the [Mautic Community](https://mautic.org/community).*
