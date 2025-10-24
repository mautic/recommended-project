# AI-Powered Monitoring and Auto-Fix Solution for Mautic on Railway

This guide provides comprehensive solutions for implementing AI-powered monitoring and automated bug fixing for your Mautic deployment on Railway.app.

## Table of Contents

1. [Solution Overview](#solution-overview)
2. [Option 1: GitHub Actions + Claude Code (Recommended)](#option-1-github-actions--claude-code-recommended)
3. [Option 2: Railway Monitoring + Webhook Automation](#option-2-railway-monitoring--webhook-automation)
4. [Option 3: Self-Hosted AI Agent](#option-3-self-hosted-ai-agent)
5. [Monitoring Best Practices](#monitoring-best-practices)
6. [Cost Comparison](#cost-comparison)

---

## Solution Overview

For automated monitoring and bug fixing of your Mautic deployment, you have several options ranging from simple (webhook-based) to advanced (full AI agent). Here's what each solution provides:

| Feature | GitHub Actions + Claude | Railway + Webhooks | Self-Hosted Agent |
|---------|------------------------|--------------------|--------------------|
| **Cost** | ~$20/month | ~$10/month | ~$50-100/month |
| **Complexity** | Medium | Low | High |
| **Auto-Fix Capability** | Yes (with human approval) | Limited | Yes |
| **Monitoring Depth** | Deep (code-level) | Service-level | Deep (code-level) |
| **Setup Time** | 2 hours | 30 minutes | 8+ hours |
| **Maintenance** | Low | Very Low | High |

**Our Recommendation:** Start with **Option 1 (GitHub Actions + Claude Code)** for the best balance of features, cost, and ease of use.

---

## Option 1: GitHub Actions + Claude Code (Recommended)

This solution uses GitHub Actions to monitor your deployment and Claude Code (Anthropic's AI) to analyze and fix issues automatically.

### How It Works

1. **Monitoring**: GitHub Actions runs health checks every 15 minutes
2. **Detection**: When an issue is detected, logs are collected
3. **Analysis**: Claude AI analyzes the logs and repository
4. **Fix Proposal**: Claude creates a pull request with the fix
5. **Review**: You review and merge the fix (or it auto-merges if configured)
6. **Deployment**: Railway auto-deploys the fix

### Implementation Steps

#### Step 1: Get an Anthropic API Key

1. Sign up at: https://console.anthropic.com/
2. Go to "API Keys" and create a new key
3. Copy your API key (starts with `sk-ant-`)

**Cost:** ~$20/month for typical usage (monitoring + fixes)

#### Step 2: Add Secrets to Your GitHub Repository

1. Go to your repository on GitHub
2. Click "Settings" > "Secrets and variables" > "Actions"
3. Click "New repository secret"
4. Add these secrets:

   | Name | Value | Description |
   |------|-------|-------------|
   | `ANTHROPIC_API_KEY` | Your Anthropic API key | For Claude AI |
   | `RAILWAY_TOKEN` | Your Railway API token | To fetch logs |
   | `RAILWAY_PROJECT_ID` | Your project ID | Found in Railway project settings |
   | `RAILWAY_SERVICE_ID` | Your service ID | Found in Railway service settings |

5. To get Railway API token:
   - Go to Railway.app > Account Settings > Tokens
   - Click "Create Token" and copy it

#### Step 3: Create GitHub Actions Workflow

Create this file in your repository: `.github/workflows/ai-monitor.yml`

```yaml
name: AI-Powered Mautic Monitoring

on:
  schedule:
    # Run every 15 minutes
    - cron: '*/15 * * * *'
  workflow_dispatch: # Allow manual triggers

jobs:
  monitor-and-fix:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Check Mautic health
        id: health_check
        env:
          MAUTIC_URL: ${{ vars.MAUTIC_URL }}
        run: |
          # Check if Mautic is responding
          HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $MAUTIC_URL/s/login)

          if [ $HTTP_STATUS -eq 200 ]; then
            echo "status=healthy" >> $GITHUB_OUTPUT
            echo "✅ Mautic is healthy (HTTP $HTTP_STATUS)"
          else
            echo "status=unhealthy" >> $GITHUB_OUTPUT
            echo "❌ Mautic is unhealthy (HTTP $HTTP_STATUS)"
          fi

      - name: Fetch Railway logs if unhealthy
        if: steps.health_check.outputs.status == 'unhealthy'
        id: fetch_logs
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
          RAILWAY_PROJECT_ID: ${{ secrets.RAILWAY_PROJECT_ID }}
          RAILWAY_SERVICE_ID: ${{ secrets.RAILWAY_SERVICE_ID }}
        run: |
          # Install Railway CLI
          npm install -g @railway/cli

          # Fetch last 500 lines of logs
          railway logs --project $RAILWAY_PROJECT_ID --service $RAILWAY_SERVICE_ID > railway-logs.txt

          echo "Logs fetched ($(wc -l < railway-logs.txt) lines)"

      - name: Analyze with Claude AI
        if: steps.health_check.outputs.status == 'unhealthy'
        id: claude_analysis
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          # Create analysis prompt
          cat > prompt.txt << 'EOF'
          You are an expert Mautic and PHP developer analyzing a production issue.

          System logs:
          $(cat railway-logs.txt)

          Repository structure:
          $(find . -type f -name "*.php" -o -name "*.json" -o -name "*.yml" -o -name "Dockerfile" | head -50)

          Task: Analyze the logs and identify the root cause of the issue. Then:
          1. Explain the issue in simple terms
          2. Propose a fix with specific file changes
          3. Provide the exact code changes needed

          Format your response as JSON:
          {
            "issue_summary": "Brief description",
            "root_cause": "Detailed explanation",
            "proposed_fix": "What needs to be changed",
            "file_changes": [
              {
                "file": "path/to/file",
                "old_content": "content to replace",
                "new_content": "new content"
              }
            ]
          }
          EOF

          # Call Claude API
          curl -X POST https://api.anthropic.com/v1/messages \
            -H "Content-Type: application/json" \
            -H "x-api-key: $ANTHROPIC_API_KEY" \
            -H "anthropic-version: 2023-06-01" \
            -d @- > claude-response.json << EOF
          {
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 4096,
            "messages": [
              {
                "role": "user",
                "content": "$(cat prompt.txt)"
              }
            ]
          }
          EOF

          # Extract analysis from response
          cat claude-response.json | jq -r '.content[0].text' > analysis.json

          echo "analysis=$(cat analysis.json | jq -c .)" >> $GITHUB_OUTPUT

      - name: Create fix branch
        if: steps.health_check.outputs.status == 'unhealthy'
        run: |
          # Create a new branch for the fix
          BRANCH_NAME="ai-fix-$(date +%Y%m%d-%H%M%S)"
          git checkout -b $BRANCH_NAME
          echo "branch=$BRANCH_NAME" >> $GITHUB_ENV

      - name: Apply fixes
        if: steps.health_check.outputs.status == 'unhealthy'
        env:
          ANALYSIS: ${{ steps.claude_analysis.outputs.analysis }}
        run: |
          # Parse file changes from Claude's analysis
          echo "$ANALYSIS" | jq -r '.file_changes[] | @json' | while read change; do
            FILE=$(echo $change | jq -r '.file')
            OLD_CONTENT=$(echo $change | jq -r '.old_content')
            NEW_CONTENT=$(echo $change | jq -r '.new_content')

            # Apply the change
            if [ -f "$FILE" ]; then
              # Use sed to replace old content with new content
              # This is a simplified version - you may need more robust replacement
              sed -i "s|$OLD_CONTENT|$NEW_CONTENT|g" "$FILE"
              echo "✅ Updated $FILE"
            fi
          done

      - name: Commit and push fixes
        if: steps.health_check.outputs.status == 'unhealthy'
        env:
          ANALYSIS: ${{ steps.claude_analysis.outputs.analysis }}
        run: |
          git config user.name "Mautic AI Bot"
          git config user.email "ai-bot@mautic-railway.app"

          ISSUE_SUMMARY=$(echo "$ANALYSIS" | jq -r '.issue_summary')

          git add -A
          git commit -m "🤖 AI Fix: $ISSUE_SUMMARY

          Root cause: $(echo "$ANALYSIS" | jq -r '.root_cause')

          Proposed fix: $(echo "$ANALYSIS" | jq -r '.proposed_fix')

          This fix was automatically generated by Claude AI based on error log analysis."

          git push origin ${{ env.branch }}

      - name: Create Pull Request
        if: steps.health_check.outputs.status == 'unhealthy'
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          ANALYSIS: ${{ steps.claude_analysis.outputs.analysis }}
        run: |
          ISSUE_SUMMARY=$(echo "$ANALYSIS" | jq -r '.issue_summary')
          ROOT_CAUSE=$(echo "$ANALYSIS" | jq -r '.root_cause')
          PROPOSED_FIX=$(echo "$ANALYSIS" | jq -r '.proposed_fix')

          gh pr create \
            --title "🤖 AI Fix: $ISSUE_SUMMARY" \
            --body "## Issue Detected

          **Summary:** $ISSUE_SUMMARY

          **Root Cause:**
          $ROOT_CAUSE

          **Proposed Fix:**
          $PROPOSED_FIX

          **Analysis:**
          This pull request was automatically created by the AI monitoring system after detecting an issue with the Mautic deployment.

          **Review Instructions:**
          1. Review the code changes carefully
          2. Test in a staging environment if possible
          3. Merge to deploy the fix to production

          **Logs:**
          See attached Railway logs in the workflow artifacts.

          ---
          *Generated by AI Monitoring System*
          *Timestamp: $(date -u +"%Y-%m-%d %H:%M:%S UTC")*" \
            --base main \
            --head ${{ env.branch }}

      - name: Upload logs as artifact
        if: steps.health_check.outputs.status == 'unhealthy'
        uses: actions/upload-artifact@v4
        with:
          name: railway-logs-${{ github.run_number }}
          path: railway-logs.txt

      - name: Send notification
        if: steps.health_check.outputs.status == 'unhealthy'
        run: |
          echo "🚨 Issue detected and fix proposed. Check the pull request."
```

#### Step 4: Configure Repository Variables

1. Go to Settings > Secrets and variables > Actions > Variables
2. Add:
   - `MAUTIC_URL`: Your Mautic URL (e.g., `https://your-app.up.railway.app`)

#### Step 5: Enable Workflow Permissions

1. Go to Settings > Actions > General
2. Scroll to "Workflow permissions"
3. Select "Read and write permissions"
4. Check "Allow GitHub Actions to create and approve pull requests"
5. Save

#### Step 6: Test the System

1. Go to Actions tab in your repository
2. Click "AI-Powered Mautic Monitoring"
3. Click "Run workflow" to test manually
4. The workflow will run and report the health status

### Auto-Merge Configuration (Optional)

To enable automatic merging of low-risk fixes:

Create `.github/workflows/auto-merge.yml`:

```yaml
name: Auto-merge AI fixes

on:
  pull_request:
    types: [opened]

jobs:
  auto-merge:
    runs-on: ubuntu-latest
    if: startsWith(github.head_ref, 'ai-fix-')

    steps:
      - name: Auto-approve
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh pr review ${{ github.event.pull_request.number }} --approve

      - name: Enable auto-merge
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh pr merge ${{ github.event.pull_request.number }} --auto --squash
```

---

## Option 2: Railway Monitoring + Webhook Automation

This is a simpler solution using Railway's built-in monitoring and webhooks to trigger automated responses.

### How It Works

1. Railway monitors your service health
2. When health check fails, Railway triggers a webhook
3. Your webhook handler analyzes the issue
4. Automated responses are triggered (restart, rollback, etc.)

### Implementation Steps

#### Step 1: Create a Health Check Endpoint

This is already configured in the Railway deployment (nginx `/health` endpoint).

#### Step 2: Set Up Railway Health Checks

1. In Railway, go to your Mautic service
2. Click "Settings"
3. Scroll to "Health Check"
4. Enable health check with:
   - Path: `/health`
   - Interval: 30 seconds
   - Timeout: 10 seconds
   - Success codes: 200

#### Step 3: Create a Webhook Handler

Deploy this simple Node.js service on Railway to handle incidents:

```javascript
// incident-handler.js
const express = require('express');
const axios = require('axios');
const app = express();
app.use(express.json());

app.post('/webhook/railway', async (req, res) => {
  const { event, service, status } = req.body;

  if (event === 'deployment.failed' || status === 'unhealthy') {
    console.log(`🚨 Incident detected for ${service}`);

    // Option 1: Trigger automatic rollback
    await triggerRollback(service);

    // Option 2: Restart the service
    await restartService(service);

    // Option 3: Send alert
    await sendAlert({
      service,
      status,
      message: 'Service unhealthy - automated recovery initiated'
    });
  }

  res.status(200).send('OK');
});

async function triggerRollback(serviceId) {
  // Use Railway API to rollback to last healthy deployment
  await axios.post(`https://backboard.railway.app/graphql`, {
    query: `
      mutation {
        deploymentRollback(id: "${serviceId}") {
          id
        }
      }
    `,
    headers: {
      'Authorization': `Bearer ${process.env.RAILWAY_TOKEN}`
    }
  });
}

async function restartService(serviceId) {
  // Restart the service
  await axios.post(`https://backboard.railway.app/graphql`, {
    query: `
      mutation {
        serviceRestart(id: "${serviceId}") {
          id
        }
      }
    `,
    headers: {
      'Authorization': `Bearer ${process.env.RAILWAY_TOKEN}`
    }
  });
}

async function sendAlert(details) {
  // Send to Slack, Discord, email, etc.
  console.log('Alert:', details);
}

app.listen(process.env.PORT || 3000);
```

#### Step 4: Configure Railway Webhooks

1. In Railway project settings
2. Go to "Webhooks"
3. Add webhook URL: Your incident handler URL
4. Select events: `deployment.failed`, `deployment.crashed`

---

## Option 3: Self-Hosted AI Agent

For advanced users who want full control, you can deploy a self-hosted AI agent that continuously monitors and fixes issues.

### Architecture

```
┌─────────────────┐
│   Mautic on     │
│   Railway       │◄────── Monitors
└────────┬────────┘
         │
         │ Logs
         ▼
┌─────────────────┐      ┌──────────────┐
│  Log Aggregator │─────►│  AI Agent    │
│  (Loki/ELK)     │      │  (LangChain) │
└─────────────────┘      └──────┬───────┘
                                │
                                │ Fixes
                                ▼
                         ┌──────────────┐
                         │   GitHub     │
                         │   Auto-PR    │
                         └──────────────┘
```

### Components Needed

1. **Log Aggregator**: Grafana Loki or ELK Stack
2. **AI Agent**: Python + LangChain + Claude/GPT-4
3. **Scheduler**: Airflow or cron
4. **Storage**: PostgreSQL for agent state

**Estimated Setup Cost**: $50-100/month
**Setup Time**: 8-16 hours
**Complexity**: High (requires DevOps experience)

### Quick Start

If you're interested in this option, I can provide:
1. Docker Compose configuration for all components
2. Python agent code with LangChain
3. Deployment instructions

Let me know if you'd like the full implementation.

---

## Monitoring Best Practices

Regardless of which solution you choose, follow these best practices:

### 1. Multi-Layer Monitoring

Monitor at multiple levels:
- **Application**: Mautic health endpoint
- **Server**: CPU, memory, disk usage
- **Database**: Query performance, connections
- **Email**: Delivery rates, bounce rates
- **User Experience**: Response times, error rates

### 2. Set Up Alerts

Configure alerts for:
- Service downtime (> 1 minute)
- High error rates (> 5% of requests)
- Database connection issues
- Email delivery failures
- Disk space warnings (> 80% full)

### 3. Log Everything

Ensure comprehensive logging:
```php
// In your Mautic configuration
'monolog' => [
    'handlers' => [
        'main' => [
            'type' => 'rotating_file',
            'path' => '%kernel.logs_dir%/mautic_%kernel.environment%.log',
            'level' => 'info',
            'max_files' => 14,
        ],
    ],
],
```

### 4. Regular Health Checks

Test these endpoints regularly:
- `/s/login` - Application availability
- `/api/users` - API functionality
- `/email/preview/...` - Email rendering

### 5. Performance Baselines

Establish baselines for:
- Average response time
- Database query time
- Email send rate
- Cache hit rate

---

## Cost Comparison

### Total Monthly Cost Estimates

| Solution | Infrastructure | AI/Monitoring | Total |
|----------|----------------|---------------|-------|
| **Option 1: GitHub Actions + Claude** | $0 (2000 min free) | ~$20 (Anthropic) | **$20** |
| **Option 2: Railway Webhooks** | $5 (webhook service) | $5 (monitoring) | **$10** |
| **Option 3: Self-Hosted Agent** | $30 (additional services) | $20-50 (AI API) | **$50-80** |

### Recommendations by Use Case

- **Hobby/Testing**: Option 2 (Railway Webhooks)
- **Production/SMB**: Option 1 (GitHub Actions + Claude) ⭐ **Recommended**
- **Enterprise/Custom**: Option 3 (Self-Hosted Agent)

---

## Advanced: Predictive Monitoring

For the ultimate setup, combine multiple approaches:

1. **Real-time**: Railway webhooks for immediate issues
2. **Proactive**: GitHub Actions for scheduled deep analysis
3. **Predictive**: ML model to predict failures before they happen

Example prediction targets:
- Database disk space exhaustion
- Memory leak detection
- Performance degradation trends
- Email deliverability decline

---

## Support and Resources

- **Anthropic Claude Documentation**: https://docs.anthropic.com/
- **Railway API Documentation**: https://docs.railway.app/develop/api
- **GitHub Actions Documentation**: https://docs.github.com/en/actions
- **Mautic Developer Docs**: https://developer.mautic.org/

---

## Conclusion

For most users, **Option 1 (GitHub Actions + Claude Code)** provides the best balance of:
- ✅ Automated issue detection
- ✅ AI-powered root cause analysis
- ✅ Automatic fix proposals
- ✅ Human-in-the-loop review
- ✅ Affordable monthly cost (~$20)
- ✅ Easy to set up and maintain

Start with this option, and you can always upgrade to a more sophisticated solution as your needs grow.

**Next Steps:**
1. Implement Option 1 using the steps above
2. Test with a manual workflow run
3. Monitor for 1-2 weeks to establish baselines
4. Fine-tune alert thresholds
5. Enable auto-merge for low-risk fixes (optional)

Happy monitoring! 🚀
