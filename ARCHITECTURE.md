# System Architecture

This document explains how the blog system works with Azure Blob Storage, encrypted ideas, and the post editor.

## Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     GitHub Repository                            │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  • Jekyll configuration                                     │ │
│  │  • Layouts and includes                                     │ │
│  │  • Plugins (Ruby)                                           │ │
│  │  • GitHub Actions workflows                                 │ │
│  │  • NO plain text posts or ideas                            │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Push to main
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   GitHub Actions Build                           │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  1. Checkout code                                          │ │
│  │  2. Load secrets (Azure credentials, encrypted ideas)      │ │
│  │  3. Run Jekyll plugins:                                    │ │
│  │     • azure_posts_loader.rb → Download posts from Azure   │ │
│  │     • encrypted_ideas.rb → Generate ideas-admin.html      │ │
│  │     • post_editor.rb → Generate editor.html               │ │
│  │  4. Build static site                                      │ │
│  │  5. Deploy to GitHub Pages                                 │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
         │                                      │
         │                                      │ Fetch posts
         ▼                                      ▼
┌──────────────────────┐          ┌────────────────────────────┐
│   GitHub Pages       │          │  Azure Blob Storage        │
│   (Static Site)      │          │                            │
│                      │          │  Container:                │
│  • Posts rendered    │          │  ├── posts/                │
│  • Ideas admin page  │          │  │   └── *.md (published)  │
│  • Post editor page  │          │  └── drafts/               │
│  • All pages/assets  │          │      └── *.md (hidden)     │
│                      │          │                            │
└──────────────────────┘          └────────────────────────────┘
         │                                      ▲
         │                                      │
         │                                      │ Manual upload
         │                                      │ or via workflow
         ▼                                      │
┌─────────────────────────────────────────────────────────────────┐
│                        Website Visitor                           │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Browse:                                                    │ │
│  │  • Home page with post list                                │ │
│  │  • Individual post pages (from posts/ folder only)         │ │
│  │                                                             │ │
│  │  Admin Tools (password protected):                         │ │
│  │  • /ideas-admin.html → View encrypted post ideas          │ │
│  │  • /editor.html → Write and manage posts                  │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Post Creation Flow

```
Author writes post in /editor.html
         │
         ▼
Post saved to browser localStorage (backup)
         │
         ▼
Post downloaded as .md file
         │
         ▼
Author uploads to Azure Blob Storage
         │
         ├─→ drafts/ folder → NOT visible on website
         │
         └─→ posts/ folder → Will be visible after build
                    │
                    ▼
            Push to GitHub (any change) triggers build
                    │
                    ▼
            Jekyll plugin downloads from posts/ folder
                    │
                    ▼
            Site rebuilds and deploys
                    │
                    ▼
            Post is now LIVE on website! 🎉
```

### 2. Draft to Published Flow

```
Draft exists in drafts/ folder in Azure
         │
         ▼
Author moves/copies file to posts/ folder
         │
         ▼
Next build automatically picks it up
         │
         ▼
Post becomes visible on website
```

### 3. Post Ideas Flow

```
Author creates post_ideas.json
         │
         ▼
Run scripts/encrypt_ideas.rb
         │
         ▼
Encrypted data added to GitHub secrets
         │
         ▼
Build generates /ideas-admin.html with encrypted data
         │
         ▼
Author visits /ideas-admin.html
         │
         ▼
Enter password → Client-side decryption
         │
         ▼
View post ideas (never sent to server)
```

## Component Responsibilities

### Jekyll Plugins

**azure_posts_loader.rb**
- Runs during build (priority: highest)
- Connects to Azure Blob Storage using GitHub secrets
- Lists blobs in `posts/` folder (NOT drafts/)
- Downloads .md files
- Writes to temporary `_posts/` directory
- Security: Validates filenames, rejects traversal attacks

**encrypted_ideas.rb**
- Runs during build (priority: low)
- Reads `ENCRYPTED_IDEAS` from environment
- Generates `/ideas-admin.html` page
- Embeds encrypted data in page
- Provides JavaScript for client-side decryption

**post_editor.rb**
- Runs during build (priority: low)
- Generates `/editor.html` page
- Creates web-based markdown editor interface
- Handles local storage of drafts
- Auto-downloads posts as .md files

### GitHub Actions Workflows

**jekyll-gh-pages.yml**
- Main build and deploy workflow
- Triggered on push to main
- Sets environment variables from secrets
- Runs Jekyll build
- Deploys to GitHub Pages

**upload-post.yml**
- Manual workflow (workflow_dispatch)
- Allows uploading a post to Azure from GitHub UI
- Takes file path and draft/published flag as inputs
- Uses Azure CLI to upload

**save-post-api.yml**
- Repository dispatch workflow (future enhancement)
- Would allow programmatic post saving
- Currently not used by editor (security reasons)

### Azure Blob Storage Structure

```
Container: blog-content (or your choice)
│
├── posts/                    ← Published posts
│   ├── 2026-01-11-what-are-agents.md
│   ├── 2026-01-20-react-pattern.md
│   └── 2026-02-01-mcp-servers.md
│
└── drafts/                   ← Draft posts (not public)
    ├── 2026-02-15-future-idea.md
    └── 2026-03-01-work-in-progress.md
```

### GitHub Secrets

| Secret | Purpose | Used By |
|--------|---------|---------|
| `AZURE_STORAGE_ACCOUNT` | Storage account name | azure_posts_loader.rb |
| `AZURE_STORAGE_KEY` | Storage account key | azure_posts_loader.rb |
| `AZURE_CONTAINER_NAME` | Container name | azure_posts_loader.rb |
| `ENCRYPTED_IDEAS` | Encrypted post ideas | encrypted_ideas.rb |

## Security Model

### Authentication Layers

1. **GitHub Secrets** - Encrypted at rest, only available during builds
2. **Azure Storage** - Private container, requires key for access
3. **Editor Password** - Client-side only, 8+ characters required
4. **Ideas Encryption** - AES-256-GCM with PBKDF2 key derivation

### Security Features

✅ **No credentials in code** - All sensitive data in secrets
✅ **No plain text posts** - All content in Azure
✅ **Client-side encryption** - Password never leaves browser
✅ **Path validation** - Prevents directory traversal
✅ **Input sanitization** - Blob names validated before use
✅ **Separate draft/publish** - Explicit folder separation

### Attack Surface

**Low Risk:**
- Static site reduces attack surface
- No server-side execution in production
- No database to compromise

**Medium Risk:**
- Browser localStorage can be accessed locally
- Password is stored in browser memory when unlocked

**Mitigation:**
- Lock editor when done
- Use strong passwords
- Clear browser data on shared computers
- Don't expose Azure credentials

## Deployment Flow

```
1. Developer makes changes
         │
         ▼
2. Commit & push to GitHub
         │
         ▼
3. GitHub Actions triggered
         │
         ├─→ 4a. Load secrets from repo settings
         │
         ├─→ 4b. Run Jekyll with plugins
         │        │
         │        ├─→ Plugin: azure_posts_loader
         │        │   └─→ Fetch from Azure
         │        │
         │        ├─→ Plugin: encrypted_ideas
         │        │   └─→ Generate admin page
         │        │
         │        └─→ Plugin: post_editor
         │            └─→ Generate editor page
         │
         ▼
5. Build static site
         │
         ▼
6. Deploy to GitHub Pages
         │
         ▼
7. Site is LIVE! 🚀
```

## Performance Considerations

### Build Time
- Azure API calls add ~2-5 seconds to build
- Scales with number of posts
- Cached by GitHub Actions between steps

### Client Side
- Static HTML loads fast
- Marked.js for markdown preview (~50KB)
- localStorage for draft backup (instant)
- No runtime dependencies

### Azure Costs
- Blob storage very cheap (~$0.02/GB/month)
- API calls included in storage account
- Minimal egress for downloads during build

## Extensibility

### Adding Features

**New Plugin:**
1. Create `_plugins/your_plugin.rb`
2. Inherit from `Jekyll::Generator`
3. Implement `generate(site)` method
4. Add to repository

**New Workflow:**
1. Create `.github/workflows/your-workflow.yml`
2. Define triggers and jobs
3. Use secrets as needed
4. Commit and push

**New Admin Page:**
1. Create in plugin using `PageWithoutAFile`
2. Add authentication
3. Include necessary JavaScript
4. Generate during build

## Troubleshooting

### Build Fails
- Check GitHub Actions logs
- Verify all secrets are set
- Check Azure credentials are valid

### Posts Not Loading
- Verify posts are in `posts/` folder
- Check filename format: `YYYY-MM-DD-title.md`
- Verify Azure container permissions

### Editor Not Working
- Check browser console for errors
- Verify marked.js loaded
- Test in different browser

## Best Practices

1. **Always use drafts first** - Test before publishing
2. **Backup locally** - Download posts regularly
3. **Strong passwords** - 12+ characters recommended
4. **Lock when done** - Don't leave editor unlocked
5. **Test builds** - Use workflow_dispatch to test before pushing
6. **Monitor costs** - Check Azure usage monthly
7. **Version control** - Keep important posts in multiple places

---

For more details, see:
- [README.md](README.md) - Feature overview
- [MIGRATION.md](MIGRATION.md) - Setup guide
- [EDITOR.md](EDITOR.md) - Editor usage
- [scripts/README.md](scripts/README.md) - Helper scripts
