# Railway.com Deployment Setup - IMPORTANT

If Railway tries to auto-detect this as a PHP project (Railpack) instead of using the Dockerfile, follow these steps:

## Solution 1: Manual Builder Selection (Recommended)

1. **In Railway Dashboard**: Go to your service
2. **Click Settings** tab
3. **Scroll to "Build"** section
4. **Change Builder** from "Nixpacks" or "Railpack" to **"Dockerfile"**
5. **Save changes**
6. **Trigger a new deployment**

## Solution 2: Set Environment Variable Before Deploy

Before deploying, add this environment variable:

```
RAILWAY_DOCKERFILE_PATH=Dockerfile
```

## Solution 3: Deploy from Dockerfile Explicitly

When creating the service:

1. Go to Railway dashboard
2. Click **"New"** → **"GitHub Repo"**
3. Select this repository
4. **IMPORTANT**: When Railway asks "How do you want to build this?", select **"Dockerfile"**
5. Proceed with deployment

## What Went Wrong?

Railway detected the `composer.json` file and assumed this was a standalone PHP project. It tried to use its PHP buildpack (Railpack/Nixpacks) which doesn't have all the required PHP extensions and configurations.

Our Dockerfile has everything properly configured, so Railway needs to use that instead.

## Verify It's Working

Once you switch to Dockerfile builder, you should see in the build logs:

```
Step 1/25 : FROM php:8.2-apache
```

NOT:

```
↳ Detected Php
Packages
──────────
php  │  8.4.14  │  railpack default (8.4)
```

## Need Help?

If you're still having issues, you can:
1. Delete the service in Railway
2. Start fresh and explicitly choose "Dockerfile" as the builder
3. Or contact Railway support to manually set the builder
