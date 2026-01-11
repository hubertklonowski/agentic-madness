# Migration Guide

This guide helps you migrate your existing blog to the new Azure Blob Storage + Encrypted Ideas + Post Editor setup.

## Current State

You currently have posts in the `_posts/` directory that are:
- ✅ Stored in plain text in the repository
- ✅ Publicly visible in the GitHub repo
- ✅ Working with the new post layout

## New Capabilities

After migration, you'll have:
- ✅ Posts stored in Azure Blob Storage (not in repo)
- ✅ Web-based editor at `/editor.html` to write posts
- ✅ Draft management (drafts/ vs posts/ folders)
- ✅ Encrypted post ideas at `/ideas-admin.html`
- ✅ No plain text content in repository

## Migration Steps

### Step 1: Set Up Azure Blob Storage

#### Option A: Azure Portal (Recommended for beginners)

1. Go to [portal.azure.com](https://portal.azure.com)
2. Create a Storage Account or use an existing one
3. Go to your Storage Account → **Containers**
4. Click **+ Container** to create a new container
   - Name: `blog-content` (or your preference)
   - Public access level: **Private**
5. Open your new container
6. Click **Upload** and upload your post files to a `posts/` folder
   - You can drag and drop files
   - Or use the folder upload feature

7. Get your credentials:
   - Go to Storage Account → **Access keys**
   - Copy **Storage account name**
   - Copy **Key** (key1 or key2)

#### Option B: Azure CLI

```bash
# Install Azure CLI: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli

# Login
az login

# Create a storage account (skip if you have one)
az storage account create \
  --name yourstorageaccount \
  --resource-group your-resource-group \
  --location eastus \
  --sku Standard_LRS

# Get the connection string
az storage account show-connection-string \
  --name yourstorageaccount \
  --resource-group your-resource-group

# Create container
az storage container create \
  --name blog-content \
  --account-name yourstorageaccount

# Upload your existing post
az storage blob upload \
  --account-name yourstorageaccount \
  --container-name blog-content \
  --name posts/2026-01-11-what-are-agents.md \
  --file _posts/2026-01-11-what-are-agents.md
```

### Step 2: Configure GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these three secrets:

   **Secret 1:**
   - Name: `AZURE_STORAGE_ACCOUNT`
   - Value: Your storage account name (e.g., `mystorageaccount`)

   **Secret 2:**
   - Name: `AZURE_STORAGE_KEY`
   - Value: Your storage account key (from Access keys)

   **Secret 3:**
   - Name: `AZURE_CONTAINER_NAME`
   - Value: Your container name (e.g., `blog-content`)

### Step 3: Set Up Encrypted Post Ideas

1. Create your ideas file:
   ```bash
   cd scripts
   cp post_ideas.example.json post_ideas.json
   # Edit post_ideas.json with your actual ideas
   ```

2. Encrypt your ideas:
   ```bash
   ruby encrypt_ideas.rb
   ```
   - Enter a strong password (remember it!)
   - Confirm the password
   - Copy the encrypted output

3. Add to GitHub Secrets:
   - Name: `ENCRYPTED_IDEAS`
   - Value: (paste the encrypted string)

### Step 4: Test the Build

1. Push any small change to trigger a build:
   ```bash
   git commit --allow-empty -m "Test Azure integration"
   git push
   ```

2. Go to **Actions** tab in GitHub
3. Watch the build process
4. Check the logs for:
   ```
   🔵 Loading posts from Azure Blob Storage...
     📄 Fetching: posts/2026-01-11-what-are-agents.md
   ✅ Loaded 1 posts from Azure Blob Storage
   🔐 Processing encrypted post ideas...
   ✅ Created encrypted ideas admin page at /ideas-admin.html
   ```

5. Visit your site and verify:
   - Posts render correctly
   - Post layout looks good
   - `/ideas-admin.html` is accessible

### Step 5: Remove Posts from Repository

**⚠️ Only do this after confirming everything works!**

```bash
# The posts are already gitignored, but let's remove the existing one
git rm _posts/2026-01-11-what-are-agents.md
git commit -m "Remove posts from repo (now in Azure Blob Storage)"
git push
```

From now on:
- Posts exist only in Azure Blob Storage
- They're fetched during build time
- No plain text in the repository ✅

### Step 6: Access Your Ideas Admin

1. Visit: `https://yourusername.github.io/agentic-madness/ideas-admin.html`
2. Enter your encryption password
3. View your encrypted post ideas
4. Bookmark this page for easy access

### Step 7: Try the Post Editor

1. Visit: `https://yourusername.github.io/agentic-madness/editor.html`
2. Enter your password (same as ideas admin)
3. Write a test post
4. Save it (will download as .md file)
5. Upload to Azure `drafts/` folder to test
6. See [EDITOR.md](EDITOR.md) for complete guide

## Adding New Posts

You now have **two ways** to add posts:

### Option 1: Using the Web Editor (Recommended)

1. Visit `/editor.html`
2. Enter your password
3. Write your post with live preview
4. Save (downloads .md file)
5. Upload to Azure:
   - `drafts/` - for drafts (not visible)
   - `posts/` - for published (visible)

See [EDITOR.md](EDITOR.md) for detailed instructions.

### Option 2: Manual Creation

For Published Posts

1. Write your post in markdown format:
   ```markdown
   ---
   layout: post
   title: "Your Title"
   date: 2026-02-01 11:00:00 +0100
   categories: [category1, category2]
   tags: [tag1, tag2]
   ---

   Your content...
   ```

2. Upload to Azure:
   - **Portal**: Upload to `posts/` folder in your container
   - **CLI**: 
     ```bash
     az storage blob upload \
       --account-name yourstorageaccount \
       --container-name blog-content \
       --name posts/2026-02-01-your-title.md \
       --file your-post.md
     ```

3. Push a commit to trigger rebuild (or use workflow_dispatch)

### For Draft Posts / Ideas

1. Add to your `scripts/post_ideas.json`
2. Re-encrypt:
   ```bash
   cd scripts
   ruby encrypt_ideas.rb
   ```
3. Update the `ENCRYPTED_IDEAS` secret in GitHub
4. Push to trigger rebuild

## Troubleshooting

### Posts not loading from Azure?

Check GitHub Actions logs:
- Look for "🔵 Loading posts from Azure Blob Storage..."
- Check for error messages
- Verify secrets are set correctly
- Confirm posts are in `posts/` folder with `.md` extension

### Ideas page not working?

- Verify `ENCRYPTED_IDEAS` secret is set
- Check browser console for errors
- Try re-encrypting with the script
- Make sure you're using the correct password

### Post not rendering correctly?

- Ensure front matter has `layout: post`
- Check date format: `YYYY-MM-DD HH:MM:SS +ZONE`
- Verify filename: `YYYY-MM-DD-title.md`

## Benefits After Migration

✅ **Security**: No plain text posts in repository  
✅ **Privacy**: Keep drafts hidden until ready  
✅ **Flexibility**: Easy to manage with Azure Portal  
✅ **Ideas**: Encrypted storage for brainstorming  
✅ **Clean repo**: Only code, no content

## Need Help?

- Check `scripts/README.md` for detailed documentation
- Review GitHub Actions logs for build errors
- Verify all secrets are correctly set
- Make sure Azure container and posts folder exist

Happy blogging! 🚀
