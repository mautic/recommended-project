# Mautic 6 - Railway Deployment Template

**Production-ready Mautic 6 template optimized for Railway.app deployment**

This is a comprehensive, production-ready Mautic 6 deployment template designed specifically for non-technical email marketers who want to self-host Mautic on Railway.app. It includes all essential configurations, supports all major Email Service Providers (ESPs) via Symfony Mailer, and provides step-by-step deployment guides.

## Quick Start

Deploy Mautic 6 to Railway in 20 minutes: **[→ See Quick Start Guide](./QUICKSTART.md)**

## What's Included

✅ **Production-Ready Mautic 6** with all official plugins and themes
✅ **All Symfony Mailer ESP Integrations** (SendGrid, Mailgun, Postmark, SES, Resend, and 10+ more)
✅ **Railway.app Optimized** with Dockerfile, nginx, and PHP-FPM configuration
✅ **Comprehensive Documentation** for non-technical users
✅ **AI-Powered Monitoring** solution with automated bug fixing
✅ **Database & Redis Support** with automatic configuration
✅ **Cron Job Setup Guides** for multiple platforms
✅ **Step-by-Step Video Guide Outline** for visual learners

## For Email Marketers (Non-Technical Users)

This template was built for you! No coding experience required.

**Start here:**
1. 📖 [Quick Start Guide](./QUICKSTART.md) - Deploy in 20 minutes
2. 📚 [Full Deployment Guide](./DEPLOYMENT_GUIDE.md) - Detailed step-by-step instructions
3. ⏰ [Cron Job Setup](./CRON_SETUP.md) - Set up automated tasks
4. 🤖 [AI Monitoring](./AI_MONITORING_SOLUTION.md) - Automated monitoring and bug fixes

**Estimated Monthly Cost:** $5-40 depending on email volume (see [cost estimates](./DEPLOYMENT_GUIDE.md#cost-estimates))

---

## For Developers

This is a Composer-based project template for managing Mautic 6 dependencies with production-ready deployment configurations.

## Railway Deployment (Recommended)

### Prerequisites
- GitHub account
- Railway.app account
- Email service provider account (SendGrid, Mailgun, etc.)

### Deployment Steps

1. **Fork this repository** to your GitHub account

2. **Deploy to Railway:**
   - Go to [Railway.app](https://railway.app/)
   - Click "New Project" → "Deploy from GitHub repo"
   - Select your forked repository
   - Add MySQL/MariaDB database
   - Add Redis (optional but recommended)

3. **Configure environment variables:**
   - See [.env.example](.env.example) for all options
   - Required: `APP_SECRET`, `MAUTIC_URL`, `MAILER_DSN`, `MAILER_FROM_EMAIL`

4. **Complete installation:**
   - Visit your Railway URL
   - Follow the Mautic setup wizard

5. **Set up cron jobs:**
   - See [CRON_SETUP.md](./CRON_SETUP.md) for detailed instructions

**Full guide:** [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)

---

## Traditional Composer Installation

First you need to install [Composer v2](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx).

> Note: The instructions below refer to the [global composer installation](https://getcomposer.org/doc/00-intro.md#globally).
You might need to replace `composer` with `php composer.phar` (or similar)
for your setup.

After that you can create the project:

```
composer create-project mautic/recommended-project:^7.0 some-dir --no-interaction
```

With `composer require ...` you can download new dependencies to your installation.

Example of installing a plugin:
```
cd some-dir
composer require mautic/helloworld-bundle
```

The `composer create-project` command passes ownership of all files to the
project that is created. You should create a new git repository, and commit
all files not excluded by the .gitignore file.

## Key Features of This Template

### Email Service Provider Support

This template includes all Symfony Mailer bridges for seamless ESP integration:

| Provider | Package | Configuration |
|----------|---------|---------------|
| **SendGrid** | symfony/sendgrid-mailer | See [.env.example](.env.example#L75) |
| **Mailgun** | symfony/mailgun-mailer | See [.env.example](.env.example#L87) |
| **Postmark** | symfony/postmark-mailer | See [.env.example](.env.example#L99) |
| **Amazon SES** | symfony/amazon-mailer | See [.env.example](.env.example#L107) |
| **Mailjet** | symfony/mailjet-mailer | See [.env.example](.env.example#L119) |
| **SparkPost** | symfony/sparkpost-mailer | See [.env.example](.env.example#L128) |
| **Brevo** | symfony/brevo-mailer | See [.env.example](.env.example#L137) |
| **Resend** | symfony/resend-mailer | See [.env.example](.env.example#L154) |
| And 8+ more | | Full list in [.env.example](.env.example) |

### Production Optimizations

- **Nginx + PHP-FPM** configuration for optimal performance
- **OpCache** enabled with production settings
- **Redis support** for caching and sessions
- **Automated health checks** for Railway
- **Security headers** and best practices
- **Docker multi-stage builds** for smaller image sizes

### Automated Background Tasks

- **Supervisor** manages nginx and PHP-FPM
- **Cron job guides** for multiple platforms
- **Health monitoring** and automatic recovery
- **AI-powered bug detection** and fixing (optional)

## What does the template do?

When installing the given `composer.json` some tasks are taken care of:

* Mautic will be installed in the `docroot`-directory.
* Autoloader is implemented to use the generated composer autoloader in `vendor/autoload.php`,
  instead of the one provided by Mautic (`docroot/vendor/autoload.php`).
* Plugins (packages of type `mautic-plugin`) will be placed in `docroot/plugins/`
* Themes (packages of type `mautic-theme`) will be placed in `docroot/themes/`
* All 16 Symfony Mailer ESP integrations are pre-installed
* Creates `docroot/media`-directory.
* Creates environment variables based on your .env file. See [.env.example](.env.example).
* Docker configuration for Railway deployment included

## Updating Mautic Core

This project will attempt to keep all of your Mautic Core files up-to-date; the
project [mautic/core-composer-scaffold](https://github.com/mautic/core-composer-scaffold)
is used to ensure that your scaffold files are updated every time mautic/core is
updated. If you customize any of the "scaffolding" files (commonly .htaccess),
you may need to merge conflicts if any of your modified files are updated in a
new release of Mautic core.

Follow the steps below to update your core files.

1. Run `composer update mautic/core --with-dependencies` to update Mautic Core and its dependencies.
2. Run `git diff` to determine if any of the scaffolding files have changed.
   Review the files for any changes and restore any customizations to
  `.htaccess` or others.
1. Commit everything all together in a single commit, so `docroot` will remain in
   sync with the `core` when checking out branches or running `git bisect`.
1. In the event that there are non-trivial conflicts in step 2, you may wish
   to perform these steps on a branch, and use `git merge` to combine the
   updated core files with your customized files. This facilitates the use
   of a [three-way merge tool such as kdiff3](http://www.gitshah.com/2010/12/how-to-setup-kdiff-as-diff-tool-for-git.html). This setup is not necessary if your changes are simple;
   keeping all of your modifications at the beginning or end of the file is a
   good strategy to keep merges easy.

## FAQ

### Should I commit the contributed plugins I download?

Composer recommends **no**. They provide [argumentation against but also
workrounds if a project decides to do it anyway](https://getcomposer.org/doc/faqs/should-i-commit-the-dependencies-in-my-vendor-directory.md).

### Should I commit the scaffolding files?

The [Mautic Composer Scaffold](https://github.com/mautic/core-composer-scaffold) plugin can download the scaffold files (like
index.php, .htaccess, …) to the docroot/ directory of your project. If you have not customized those files you could choose
to not check them into your version control system (e.g. git). If that is the case for your project it might be
convenient to automatically run the mautic-scaffold plugin after every install or update of your project. You can
achieve that by registering `@composer mautic:scaffold` as post-install and post-update command in your composer.json:

```json
"scripts": {
    "post-install-cmd": [
        "@composer mautic:scaffold",
        "..."
    ],
    "post-update-cmd": [
        "@composer mautic:scaffold",
        "..."
    ]
},
```
### How can I apply patches to downloaded plugins?

If you need to apply patches (depending on the project being modified, a pull
request is often a better solution), you can do so with the
[composer-patches](https://github.com/cweagans/composer-patches) plugin.

To add a patch to Mautic plugin foobar insert the patches section in the extra
section of composer.json:
```json
"extra": {
    "patches": {
        "mautic/foobar": {
            "Patch description": "URL or local path to patch"
        }
    }
}
```

### How do I specify a PHP version?

This project supports PHP 8.2 as the minimum version (see [Mautic requirements](https://mautic.org/mautic-requirements/)). However, running a `composer update` may upgrade some package that will require a higher PHP version.

To prevent this, you can specify the PHP version in the `config` section of `composer.json` by adding the following code:
```json
"config": {
    "sort-packages": true,
    "platform": {
        "php": "8.2"
    }
},
```

Alternatively, you can run the following command:
```bash
composer config platform.php 8.2
```


### How do I use another folder than docroot as webroot?

By default the composer.json file is configures to put all Mautic core, plugin and theme files in the `docroot` folder.  
It is possible to change this folder to your own needs.

In following examples, we will change `docroot` into `public`.

#### New installations

* Run the `create-project` command without installing  
  ```bash
  composer create-project mautic/recommended-project:^7.0 some-dir --no-interaction --no-install
  ```
* Do a find and replace in the `composer.json` file to change `docroot/` into `public/`.
* Review the changes in the `composer.json` file to ensure there are no unintentional replacements.
* Run `composer install` to install all dependencies in the correct location.

#### Existing installations

* move the `docroot/` to `public/`
  ```bash
  mv docroot public
  ```
* Do a find and replace in the `composer.json` file to change `docroot/` into `public/`.
* review the changes in the `composer.json` file to ensure there are no unintentional replacements.
* run `composer update --lock` to ensure the autoloader is aware of the changed folder.

---

## Email Service Provider Configuration

This template supports all major ESPs out of the box. Simply configure your `MAILER_DSN` environment variable.

### Popular ESP Examples

**SendGrid (Recommended for beginners):**
```env
MAILER_DSN=sendgrid+api://YOUR_API_KEY@default
```

**Mailgun:**
```env
MAILER_DSN=mailgun+https://API_KEY:DOMAIN@default?region=us
```

**Amazon SES:**
```env
MAILER_DSN=ses+smtp://ACCESS_KEY:SECRET_KEY@default?region=us-east-1
```

**Generic SMTP (any provider):**
```env
MAILER_DSN=smtp://username:password@smtp.example.com:587?encryption=tls
```

See [.env.example](.env.example) for all 16+ supported providers with detailed configuration.

---

## AI-Powered Monitoring (Optional)

Set up automated monitoring and bug fixing with AI:

### Option 1: GitHub Actions + Claude AI (Recommended)
- Monitors your Railway deployment every 15 minutes
- Analyzes logs when issues are detected
- Creates pull requests with automatic fixes
- **Cost:** ~$20/month
- **Setup:** [AI_MONITORING_SOLUTION.md](./AI_MONITORING_SOLUTION.md)

### Option 2: Railway Webhooks
- Simple webhook-based monitoring
- Automatic restarts and rollbacks
- **Cost:** ~$10/month
- **Setup:** [AI_MONITORING_SOLUTION.md#option-2](./AI_MONITORING_SOLUTION.md#option-2-railway-monitoring--webhook-automation)

---

## Documentation

| Document | Description | Audience |
|----------|-------------|----------|
| [QUICKSTART.md](./QUICKSTART.md) | Deploy in 20 minutes | Everyone |
| [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) | Comprehensive deployment guide | Non-technical users |
| [CRON_SETUP.md](./CRON_SETUP.md) | Background task configuration | Everyone |
| [AI_MONITORING_SOLUTION.md](./AI_MONITORING_SOLUTION.md) | Automated monitoring & fixes | Advanced users |
| [.env.example](.env.example) | All environment variables | Everyone |
| README.md (this file) | Project overview | Everyone |

---

## Project Structure

```
recommended-project-6/
├── .env.example                    # Environment configuration template
├── .gitignore                      # Git ignore rules
├── composer.json                   # Composer dependencies (includes all ESP packages)
├── Dockerfile                      # Railway-optimized Docker image
├── railway.json                    # Railway deployment config
├── nixpacks.toml                   # Alternative build config
├── railway.toml                    # Railway advanced config
├── docker/
│   ├── nginx/
│   │   ├── nginx.conf             # Nginx main configuration
│   │   └── default.conf           # Mautic site configuration
│   ├── php-fpm/
│   │   └── www.conf               # PHP-FPM pool configuration
│   ├── supervisor/
│   │   └── supervisord.conf       # Process manager config
│   └── docker-entrypoint.sh       # Container startup script
├── QUICKSTART.md                   # 20-minute deployment guide
├── DEPLOYMENT_GUIDE.md             # Full deployment guide
├── CRON_SETUP.md                   # Cron job setup guide
├── AI_MONITORING_SOLUTION.md       # AI monitoring guide
└── README.md                       # This file
```

---

## Support

### Community Resources
- **Mautic Documentation:** https://docs.mautic.org/
- **Mautic Forum:** https://forum.mautic.org/
- **Mautic Slack:** https://www.mautic.org/slack
- **Railway Documentation:** https://docs.railway.app/

### Getting Help
- **General Mautic Questions:** [Mautic Forum](https://forum.mautic.org/)
- **Deployment Issues:** [Railway Support](https://railway.app/help)
- **ESP Configuration:** Check [.env.example](.env.example)
- **Bugs:** [GitHub Issues](../../issues)

---

## Contributing

Contributions are welcome! Please:
1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## License

GPL-2.0-or-later (same as Mautic)

---

## Credits

**Created for email marketers seeking control over their email marketing automation.**

- Based on official [Mautic Recommended Project](https://github.com/mautic/recommended-project)
- Optimized for [Railway.app](https://railway.app/) deployment
- Includes all [Symfony Mailer](https://symfony.com/doc/current/mailer.html) integrations
- AI monitoring powered by [Anthropic Claude](https://www.anthropic.com/)

---

**Ready to deploy?** → [Start with the Quick Start Guide](./QUICKSTART.md)
