# GitHub & VSCode Configuration Guide

**Project**: DDGS - Dux Distributed Global Search  
**Version**: 0.1.0  
**Language**: Dart  
**Last Updated**: October 9, 2025

---

## Table of Contents
1. [Overview](#overview)
2. [GitHub Actions Setup](#github-actions-setup)
3. [VSCode Configuration](#vscode-configuration)
4. [Publishing Setup](#publishing-setup)
5. [Troubleshooting](#troubleshooting)

---

## Overview

This project uses:
- **GitHub Actions** for CI/CD (testing, analysis, publishing)
- **VSCode** with Dart extension for development
- **Dependabot** for automatic dependency updates

---

## GitHub Actions Setup

### 1. CI/CD Workflow (`dart-ci.yml`)

**Purpose**: Automatically tests code on every push and pull request

#### What It Does
1. ✅ Runs on 3 operating systems (Ubuntu, macOS, Windows)
2. ✅ Tests with 2 Dart versions (3.0.0 minimum, stable latest)
3. ✅ Verifies code formatting (`dart format`)
4. ✅ Runs static analysis (`dart analyze`)
5. ✅ Executes unit tests (`dart test`)
6. ✅ Tests CLI functionality

#### Trigger Events
- Push to any branch
- Pull requests to `main`, `master`, or `develop` branches

#### Setup Steps
```bash
# No setup required! 
# Workflow runs automatically when you:
git push origin your-branch-name

# Or create a pull request
```

#### Workflow File Location
```
.github/workflows/dart-ci.yml
```

#### Expected Build Time
- **Per OS/version**: ~2-3 minutes
- **Total (6 builds)**: ~5-8 minutes

#### How to View Results
1. Go to your GitHub repository
2. Click **"Actions"** tab
3. Click on the latest workflow run
4. View results for each OS/version combination

---

### 2. Publish Workflow (`dart-publish.yml`)

**Purpose**: Automatically publishes package to pub.dev when you create a GitHub release

#### What It Does
1. ✅ Verifies code formatting
2. ✅ Runs static analysis
3. ✅ Executes all tests
4. ✅ Publishes to pub.dev (if all checks pass)

#### Trigger Events
- Only when you **create a GitHub release**

#### Setup Steps

##### Step 1: Generate pub.dev Credentials

```bash
# 1. Ensure you're logged into pub.dev
# Visit: https://pub.dev/

# 2. Generate authentication token
dart pub token add https://pub.dev

# 3. Follow the prompts to authenticate in your browser
```

##### Step 2: Locate Credentials File

**On Linux/macOS:**
```bash
cat ~/.pub-cache/credentials.json
```

**On Windows:**
```cmd
type %APPDATA%\Pub\Cache\credentials.json
```

The file looks like this:
```json
{
  "accessToken": "ya29.a0AfH6SMBY...",
  "refreshToken": "1//0gJx...",
  "tokenEndpoint": "https://oauth2.googleapis.com/token",
  "scopes": ["openid", "https://www.googleapis.com/auth/userinfo.email"],
  "expiration": 1234567890123
}
```

##### Step 3: Add Credentials to GitHub Secrets

1. **Go to your GitHub repository**
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Enter details:
   - **Name**: `PUB_CREDENTIALS`
   - **Value**: Paste the **entire contents** of `credentials.json`
5. Click **"Add secret"**

##### Step 4: Verify Setup

```bash
# Check if secret is added (you won't see the value)
# Go to: Settings → Secrets and variables → Actions
# You should see: PUB_CREDENTIALS ✓
```

#### How to Publish a New Version

##### Method 1: Using GitHub Web Interface

1. **Update version in `pubspec.yaml`**:
   ```yaml
   version: 0.1.1  # Increment version
   ```

2. **Update `CHANGELOG.md`**:
   ```markdown
   ## [0.1.1] - 2025-10-09
   ### Fixed
   - Bug fixes...
   ```

3. **Commit and push**:
   ```bash
   git add pubspec.yaml CHANGELOG.md
   git commit -m "Bump version to 0.1.1"
   git push origin main
   ```

4. **Create GitHub Release**:
   - Go to your repository
   - Click **"Releases"** → **"Draft a new release"**
   - Click **"Choose a tag"** → Type `v0.1.1` → **"Create new tag"**
   - **Release title**: `v0.1.1`
   - **Description**: Copy from CHANGELOG.md
   - Click **"Publish release"**

5. **Workflow runs automatically**:
   - Go to **Actions** tab
   - Watch the publish workflow
   - Package will be live on pub.dev in ~5 minutes

##### Method 2: Using GitHub CLI

```bash
# 1. Update version and changelog (same as above)

# 2. Commit and push
git add pubspec.yaml CHANGELOG.md
git commit -m "Bump version to 0.1.1"
git push origin main

# 3. Create release using gh CLI
gh release create v0.1.1 \
  --title "v0.1.1" \
  --notes "$(sed -n '/## \[0.1.1\]/,/## \[/p' CHANGELOG.md | sed '$d')"

# 4. Workflow runs automatically
```

#### What Happens After Publishing

1. ✅ Package appears on pub.dev: `https://pub.dev/packages/ddgs`
2. ✅ Users can install: `dart pub add ddgs`
3. ✅ Documentation auto-generated on pub.dev
4. ✅ Version badge updates

---

### 3. Dependabot Configuration (`dependabot.yml`)

**Purpose**: Automatically creates pull requests for dependency updates

#### What It Does
1. ✅ Monitors `pubspec.yaml` for outdated dependencies
2. ✅ Creates PRs weekly with updates
3. ✅ Runs CI tests on each update PR
4. ✅ Limits to 10 open PRs at once

#### Setup Steps
```bash
# No setup required!
# Dependabot runs automatically every week
```

#### How It Works

1. **Every Monday**, Dependabot:
   - Checks for new versions of dependencies
   - Creates a PR for each update
   - Runs CI tests automatically

2. **You review the PR**:
   - Check if tests pass
   - Review the changelog of the updated package
   - Merge if everything looks good

#### Example PR from Dependabot:
```
Title: Bump http from 1.1.0 to 1.2.0

Description:
- Updates http from 1.1.0 to 1.2.0
- Release notes: https://github.com/dart-lang/http/releases/tag/1.2.0
- Changelog: https://github.com/dart-lang/http/blob/main/CHANGELOG.md

Checks:
✅ All CI tests passed
```

#### How to Merge Dependabot PRs

```bash
# Option 1: Via GitHub Web Interface
1. Go to "Pull requests" tab
2. Click on Dependabot PR
3. Review changes
4. Click "Merge pull request"

# Option 2: Via GitHub CLI
gh pr merge <PR-number> --auto --squash
```

---

## VSCode Configuration

### 1. Settings (`settings.json`)

**Purpose**: Configures VSCode workspace for Dart development

#### Key Settings

```json
{
  "dart.lineLength": 120,           // Max line length
  "dart.enableSdkFormatter": true,  // Use Dart formatter
  "editor.formatOnSave": true,      // Auto-format on save
  "editor.tabSize": 2,              // 2 spaces for Dart
}
```

#### What Gets Excluded

- `.dart_tool/` - Build artifacts
- `build/` - Compiled output
- `*.g.dart` - Generated files

#### Setup Steps

```bash
# 1. Open project in VSCode
code /path/to/ddgs

# 2. Settings are automatically applied
# (settings.json is already in .vscode/)

# 3. Install recommended extensions when prompted
```

---

### 2. Recommended Extensions (`extensions.json`)

**Purpose**: Suggests essential VSCode extensions

#### Extensions List

1. **Dart-Code.dart-code** ⭐ **Required**
   - Dart language support
   - Syntax highlighting
   - IntelliSense
   - Debugging

2. **Dart-Code.flutter** 
   - Useful even for Dart-only projects
   - Additional tools and snippets

3. **streetsidesoftware.code-spell-checker**
   - Spell checking in code and comments

4. **usernamehw.errorlens**
   - Inline error display
   - Highlights errors directly in code

5. **fill-labs.dependi**
   - Dependency version management
   - Shows available updates in pubspec.yaml

6. **GitHub.vscode-pull-request-github**
   - Manage GitHub PRs from VSCode

#### Setup Steps

```bash
# 1. Open project in VSCode
code .

# 2. You'll see a popup:
#    "This workspace has extension recommendations"

# 3. Click "Install All"
#    OR click "Show Recommendations" to install individually

# 4. Reload VSCode when prompted
```

#### Manual Installation

```bash
# Install all at once
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
code --install-extension streetsidesoftware.code-spell-checker
code --install-extension usernamehw.errorlens
code --install-extension fill-labs.dependi
code --install-extension GitHub.vscode-pull-request-github
```

---

### 3. Debug Configurations (`launch.json`)

**Purpose**: Pre-configured debug setups

#### Available Configurations

1. **Dart: Run CLI**
   - Runs: `bin/ddgs.dart`
   - With args: `text -q "Dart programming" -m 5 -b duckduckgo`
   - Use: Test CLI with sample query

2. **Dart: Run Example**
   - Runs: `example/example.dart`
   - Use: Test example code

3. **Dart: Run Tests**
   - Runs: `test/ddgs_test.dart`
   - Use: Debug unit tests

4. **Dart: Attach to Process**
   - Use: Attach to running Dart process

#### How to Use Debugging

##### Method 1: Quick Start (F5)
```bash
1. Open any Dart file (e.g., bin/ddgs.dart)
2. Set breakpoints (click left of line numbers)
3. Press F5 (or click Run → Start Debugging)
4. Select configuration when prompted
5. Code will run and pause at breakpoints
```

##### Method 2: Debug Panel
```bash
1. Click Debug icon in sidebar (Ctrl+Shift+D)
2. Select configuration from dropdown
3. Click green play button
4. Set breakpoints and interact
```

##### Debugging Features
- **Breakpoints**: Pause execution
- **Step Over (F10)**: Execute next line
- **Step Into (F11)**: Go into function
- **Step Out (Shift+F11)**: Exit function
- **Variables**: Inspect values
- **Call Stack**: See execution path
- **Debug Console**: Evaluate expressions

---

### 4. Build Tasks (`tasks.json`)

**Purpose**: Quick access to common commands

#### Available Tasks

1. **dart: pub get**
   - Command: `dart pub get`
   - Use: Install/update dependencies

2. **dart: analyze**
   - Command: `dart analyze`
   - Use: Static code analysis

3. **dart: test** ⭐ **Default**
   - Command: `dart test`
   - Use: Run all tests
   - Shortcut: `Ctrl+Shift+T`

4. **dart: format**
   - Command: `dart format .`
   - Use: Format all files

5. **dart: run CLI**
   - Command: `dart run bin/ddgs.dart text -q 'test' -m 5 -b duckduckgo`
   - Use: Quick CLI test

6. **dart: run example**
   - Command: `dart run example/example.dart`
   - Use: Run example code

#### How to Run Tasks

##### Method 1: Command Palette
```bash
1. Press: Ctrl+Shift+P (Cmd+Shift+P on Mac)
2. Type: "Tasks: Run Task"
3. Select task from list
4. Task runs in terminal
```

##### Method 2: Terminal Menu
```bash
1. Menu: Terminal → Run Task...
2. Select task
```

##### Method 3: Keyboard Shortcuts
```bash
# Default test task
Ctrl+Shift+T  (Windows/Linux)
Cmd+Shift+T   (Mac)
```

#### Custom Task Shortcuts (Optional)

Add to `keybindings.json`:
```json
[
  {
    "key": "ctrl+shift+f",
    "command": "workbench.action.tasks.runTask",
    "args": "dart: format"
  }
]
```

---

## Publishing Setup

### Prerequisites for Publishing

1. ✅ **pub.dev account**
   - Visit: https://pub.dev/
   - Sign in with Google account

2. ✅ **Verified email**
   - Check: https://pub.dev/my-account

3. ✅ **Package name available**
   - Check: https://pub.dev/packages/ddgs
   - Name must be unique

4. ✅ **Valid pubspec.yaml**
   - Must include: name, version, description, homepage

### Pre-Publish Checklist

```bash
# 1. Update version in pubspec.yaml
version: 0.1.0

# 2. Update CHANGELOG.md
## [0.1.0] - 2025-10-09
### Added
- Initial release

# 3. Ensure all files are ready
- README.md (complete)
- LICENSE (MIT)
- example/ (working example)

# 4. Run quality checks
dart format .
dart analyze
dart test

# 5. Dry run (test publish without actually publishing)
dart pub publish --dry-run

# 6. Review output - fix any issues

# 7. Create GitHub release (triggers workflow)
```

### Publish Workflow Secrets

**Required Secret**: `PUB_CREDENTIALS`

See [Step 3: Add Credentials to GitHub Secrets](#step-3-add-credentials-to-github-secrets) above for detailed setup.

### After First Publish

1. ✅ Verify package: https://pub.dev/packages/ddgs
2. ✅ Check score: pub.dev assigns score (max 160 points)
3. ✅ Add badge to README.md:
   ```markdown
   [![pub package](https://img.shields.io/pub/v/ddgs.svg)](https://pub.dev/packages/ddgs)
   ```

---

## Troubleshooting

### GitHub Actions Issues

#### ❌ CI Failing: Format Check
```bash
Error: Code is not formatted

Solution:
dart format .
git add .
git commit -m "Format code"
git push
```

#### ❌ CI Failing: Analysis Errors
```bash
Error: dart analyze found issues

Solution:
dart analyze
# Fix reported issues
git commit -am "Fix analysis issues"
git push
```

#### ❌ CI Failing: Tests
```bash
Error: Tests failed

Solution:
dart test --reporter=expanded
# Fix failing tests
git commit -am "Fix tests"
git push
```

#### ❌ Publish Failing: Missing Secret
```bash
Error: PUB_CREDENTIALS not found

Solution:
1. Check: Settings → Secrets → Actions
2. Verify: PUB_CREDENTIALS exists
3. If missing, regenerate credentials:
   dart pub token add https://pub.dev
4. Re-add to GitHub secrets
```

#### ❌ Publish Failing: Version Conflict
```bash
Error: Version 0.1.0 already exists

Solution:
1. Update version in pubspec.yaml: 0.1.1
2. Update CHANGELOG.md
3. Commit changes
4. Create new release: v0.1.1
```

### VSCode Issues

#### ❌ Dart Extension Not Working
```bash
Problem: No syntax highlighting, no IntelliSense

Solution:
1. Install Dart extension:
   Ctrl+Shift+X → Search "Dart" → Install
2. Reload VSCode: Ctrl+Shift+P → "Reload Window"
3. Verify Dart SDK: Ctrl+Shift+P → "Dart: Locate SDK"
```

#### ❌ Format On Save Not Working
```bash
Problem: Code doesn't format when saving

Solution:
1. Check settings.json has:
   "editor.formatOnSave": true
2. Verify Dart formatter:
   Ctrl+Shift+P → "Format Document"
3. Set Dart as default formatter:
   Right-click in file → "Format Document With..." → "Dart"
```

#### ❌ Debugging Not Working
```bash
Problem: Breakpoints not hit

Solution:
1. Ensure Dart extension installed
2. Check launch.json exists in .vscode/
3. Select correct configuration
4. Rebuild: Ctrl+Shift+P → "Dart: Clean and Get Packages"
```

### Dependabot Issues

#### ❌ Too Many PRs
```bash
Problem: Dependabot creating too many PRs

Solution:
1. Edit .github/dependabot.yml
2. Change: open-pull-requests-limit: 5
3. Or pause: @dependabot pause
```

#### ❌ PR Conflicts
```bash
Problem: Dependabot PR has conflicts

Solution:
1. Comment on PR: @dependabot recreate
2. Or manually resolve:
   git checkout dependabot/pub/http-1.2.0
   git merge main
   # Resolve conflicts
   git push
```

---

## Quick Reference

### Common Commands

```bash
# Development
dart pub get              # Install dependencies
dart analyze             # Static analysis
dart format .            # Format code
dart test                # Run tests

# CLI
dart run bin/ddgs.dart text -q "query" -m 5 -b duckduckgo

# Publishing
dart pub publish --dry-run    # Test publish
gh release create v0.1.0      # Create release (triggers publish)
```

### Important Files

```
.github/
├── workflows/
│   ├── dart-ci.yml           # CI/CD pipeline
│   └── dart-publish.yml      # Publishing workflow
└── dependabot.yml            # Dependency updates

.vscode/
├── settings.json             # Workspace settings
├── extensions.json           # Recommended extensions
├── launch.json              # Debug configurations
└── tasks.json               # Build tasks
```

### Useful Links

- **pub.dev Package**: https://pub.dev/packages/ddgs
- **GitHub Actions**: https://github.com/[user]/ddgs/actions
- **Dart CI Setup**: https://github.com/dart-lang/setup-dart
- **Publishing Guide**: https://dart.dev/tools/pub/publishing
- **VSCode Dart**: https://dartcode.org/

---

## Summary

✅ **GitHub Actions**: Automatic CI/CD with testing and publishing  
✅ **VSCode**: Full IDE support with debugging and tasks  
✅ **Dependabot**: Automatic dependency updates  
✅ **Publishing**: One-click release to pub.dev  

**All configurations are ready to use!** Just push your code and the workflows will run automatically.

For questions or issues, see [Troubleshooting](#troubleshooting) section above.
