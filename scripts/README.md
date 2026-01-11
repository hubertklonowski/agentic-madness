# Azure Blob Storage & Encrypted Ideas - Setup Guide

This guide explains how to set up Azure Blob Storage for posts and encrypted post ideas management.

> **Migrating existing blog?** See [MIGRATION.md](../MIGRATION.md) for step-by-step migration instructions.

## Overview

This repository now supports:
1. **Loading posts from Azure Blob Storage** - Posts are fetched during build time instead of being stored in the repository
2. **Encrypted post ideas** - Store post ideas securely using client-side encryption
3. **Draft posts** - Keep posts in Azure but hide them until you're ready to release them

## Benefits

- ✅ No plain text post content in the repository
- ✅ Hide posts until you're ready to publish them
- ✅ Secure storage for post ideas
- ✅ Simple authentication for accessing ideas

## Setup Instructions

### Part 1: Azure Blob Storage for Posts

#### Step 1: Create Azure Storage Account

1. Go to [Azure Portal](https://portal.azure.com)
2. Create a new Storage Account (or use existing)
3. Navigate to **Access keys** and copy:
   - Storage account name
   - Key1 or Key2

#### Step 2: Create Container and Upload Posts

**Option A: Using Azure Portal**
1. In your Storage Account, go to **Containers**
2. Create a new container (e.g., `blog-content`)
3. In the container, create a folder called `posts/`
4. Upload your markdown posts to the `posts/` folder

**Option B: Using Azure CLI**
```bash
# Install Azure CLI first: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

# Login
az login

# Set environment variables
export AZURE_STORAGE_ACCOUNT='yourstorageaccount'
export AZURE_STORAGE_KEY='yourstoragekey'

# Create container
az storage container create --name blog-content

# Upload posts
az storage blob upload \
  --container-name blog-content \
  --file _posts/2026-01-11-what-are-agents.md \
  --name posts/2026-01-11-what-are-agents.md
```

**Helper Script:**
```bash
cd scripts
ruby prepare_azure_upload.rb
# Follow the instructions shown
```

#### Step 3: Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Add these secrets:
   - `AZURE_STORAGE_ACCOUNT`: Your storage account name
   - `AZURE_STORAGE_KEY`: Your storage account access key
   - `AZURE_CONTAINER_NAME`: Your container name (e.g., `blog-content`)

### Part 2: Encrypted Post Ideas

#### Step 1: Create Your Ideas File

Create a file `scripts/post_ideas.json` with your post ideas:

```json
[
  {
    "title": "My First Post Idea",
    "description": "What this post will be about",
    "tags": ["tag1", "tag2"],
    "date": "2026-02-01"
  },
  {
    "title": "Another Great Idea",
    "description": "More details here",
    "tags": ["tutorial", "guide"],
    "date": "2026-02-15"
  }
]
```

#### Step 2: Encrypt Your Ideas

```bash
cd scripts
ruby encrypt_ideas.rb
```

This will:
1. Read your `post_ideas.json` file
2. Ask you for an encryption password (remember this!)
3. Generate an encrypted string

#### Step 3: Add Encrypted Ideas to GitHub Secrets

1. Copy the encrypted string from the output
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Add a new secret:
   - Name: `ENCRYPTED_IDEAS`
   - Value: (paste the encrypted string)

### Part 3: Accessing Your Ideas

Once deployed, visit: `https://yourusername.github.io/agentic-madness/ideas-admin.html`

1. Enter the password you used during encryption
2. View your post ideas
3. Click "Lock" to secure them again

## How It Works

### During Build (GitHub Actions)

1. **Jekyll plugin runs** (`_plugins/azure_posts_loader.rb`)
   - Connects to Azure Blob Storage using secrets
   - Downloads all `.md` files from `posts/` folder
   - Places them in `_posts/` directory temporarily
   
2. **Jekyll builds the site**
   - Posts are rendered using the `post` layout
   - Posts display properly in the website

3. **Encrypted ideas page is generated** (`_plugins/encrypted_ideas.rb`)
   - Creates `/ideas-admin.html` page
   - Embeds encrypted data in the page
   - JavaScript handles client-side decryption

### Security Notes

- ✅ Posts are NOT stored in plain text in the repository
- ✅ Post ideas are encrypted with AES-256-GCM
- ✅ Decryption happens client-side (password never leaves your browser)
- ✅ Azure credentials are stored as GitHub secrets (encrypted)
- ⚠️ Remember your encryption password - there's no recovery option!

## Removing Plain Text Posts

After setting up Azure Blob Storage and confirming posts load correctly:

```bash
# Move posts to Azure first, then:
git rm _posts/*.md
git commit -m "Remove plain text posts (now in Azure Blob Storage)"
git push
```

The `.gitignore` file already excludes `_posts/*.md` to prevent accidental commits.

## Troubleshooting

### Posts not loading?

1. Check GitHub Actions logs for errors
2. Verify Azure secrets are set correctly
3. Confirm posts are in `posts/` folder in Azure container
4. Check post filenames match Jekyll format: `YYYY-MM-DD-title.md`

### Can't decrypt ideas?

1. Make sure you're using the correct password
2. Verify the `ENCRYPTED_IDEAS` secret is set
3. Check browser console for errors

### Posts not rendering properly?

1. Ensure posts have proper front matter (YAML between `---`)
2. Check that `layout: post` is in the front matter
3. Verify the post layout exists at `_layouts/post.html`

## Development / Local Testing

For local development, you can:

1. Keep posts in `_posts/` locally (they're gitignored)
2. Set environment variables before building:
   ```bash
   export AZURE_STORAGE_ACCOUNT='...'
   export AZURE_STORAGE_KEY='...'
   export AZURE_CONTAINER_NAME='...'
   export ENCRYPTED_IDEAS='...'
   bundle exec jekyll serve
   ```

## File Structure

```
.
├── _plugins/
│   ├── azure_posts_loader.rb    # Fetches posts from Azure
│   └── encrypted_ideas.rb        # Generates ideas admin page
├── _layouts/
│   └── post.html                 # Post rendering layout
├── scripts/
│   ├── encrypt_ideas.rb          # Encrypt post ideas
│   ├── prepare_azure_upload.rb   # Helper for Azure upload
│   └── post_ideas.json          # Your ideas (gitignored)
└── .github/workflows/
    └── jekyll-gh-pages.yml       # Updated with Azure secrets
```

## Next Steps

1. Upload your posts to Azure Blob Storage
2. Configure GitHub secrets
3. Encrypt and upload your post ideas
4. Remove plain text posts from repository
5. Visit `/ideas-admin.html` to manage ideas
6. Write new posts and upload to Azure when ready to publish!

Enjoy your secure, cloud-powered blog! 🚀
