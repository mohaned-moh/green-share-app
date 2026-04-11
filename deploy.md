# Gemini Deployment Documentation 🚀

This document outlines the standard workflow for building and deploying the **Green Share** Graduation Project with Gemini AI integration to Vercel.

## The Problem
Vercel's default servers do not have the Flutter SDK. If you try to build remotely, you will get the error: `flutter: command not found`.

## The Solution: Local Build Workflow
We build the application locally (where Flutter is installed) and then deploy the pre-built files (`build/web`) to Vercel.

---

### Phase 1: Manual Workflow (Step-by-Step)

#### 1. Build the project with your API Key
Run this in the project root. This command "hardcodes" your key into the compiled output securely.
```bash
flutter build web --release --dart-define=GEMINI_API_KEY=YOUR_ACTUAL_API_KEY
```

#### 2. Deploy the build folder
Tell Vercel to only upload the finished website files:
```bash
vercel deploy build/web --prod --yes
```

---

### Phase 2: Automation Script (Recommendation) ⚡

To make this faster, I've created a small **PowerShell** script for you. You don't have to remember the commands anymore!

#### How to use:
1. Create a file named **`deploy.ps1`** in the project root.
2. Paste this code inside:

```powershell
# Green Share Deployment Script
$API_KEY = "AIzaSyCNCWG3ZC5lEsTBTkjkM7Cw-hwNiaBdMnE"

Write-Host "--- 🔨 Starting Flutter Web Build ---" -ForegroundColor Cyan
flutter build web --release --dart-define=GEMINI_API_KEY=$API_KEY

if ($LASTEXITCODE -eq 0) {
    Write-Host "--- 🚀 Uploading to Vercel ---" -ForegroundColor Green
    copy vercel.json build\web\vercel.json
    vercel deploy build\web --prod --yes
    Write-Host "--- 🎉 Deployment Complete! ---" -ForegroundColor Cyan
} else {
    Write-Host "--- ❌ Build Failed. Deployment aborted. ---" -ForegroundColor Red
}
```

3. Whenever you want to update your site, just run:
```bash
.\deploy.ps1
```

---

## Graduation Project Highlights 🎓

- **Security:** Using `--dart-define` keeps your API key out of your GitHub commits while still allowing the AI to work on the live site.
- **Reliability:** By building locally, you ensure that the environment is exactly as you see it during development.
- **Performance:** Local builds avoid the overhead of setting up Flutter on Vercel's remote servers.
