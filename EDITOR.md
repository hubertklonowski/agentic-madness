# Post Editor Guide

The post editor allows you to write and manage blog posts directly from your website, with automatic saving to Azure Blob Storage.

## Features

✅ **Web-based Editor** - Write posts directly in your browser
✅ **Markdown Support** - Live preview as you type
✅ **Draft Management** - Save drafts before publishing
✅ **Local Storage** - Automatic local backup of your work
✅ **Auto-download** - Downloads posts as .md files for easy Azure upload
✅ **Metadata Editor** - Easy front matter editing (title, date, categories, tags)

## Accessing the Editor

Visit: `https://yourusername.github.io/agentic-madness/editor.html`

Enter your editor password (same as the one used for encrypted ideas).

## How to Use

### 1. Writing a New Post

1. **Access the editor** at `/editor.html`
2. **Enter your password** to unlock
3. **Fill in metadata:**
   - Title
   - Date/Time
   - Categories (comma-separated)
   - Tags (comma-separated)
4. **Write content** in the markdown textarea
5. **See live preview** as you type
6. **Check "Save as Draft"** to keep it private (default)
7. **Click "Save Post"**

### 2. What Happens When You Save

The editor will:
1. Generate a properly formatted markdown file with front matter
2. Save a backup copy in your browser's localStorage
3. **Automatically download the .md file** to your computer

### 3. Publishing Your Post

Since this is a static site, posts need to be uploaded to Azure Blob Storage. You have three options:

#### Option A: Manual Upload (Azure Portal)

1. Go to [portal.azure.com](https://portal.azure.com)
2. Navigate to your Storage Account → Containers
3. Open your container
4. Upload the downloaded .md file to:
   - `drafts/` folder - for drafts (not publicly visible)
   - `posts/` folder - for published posts (visible on site)

#### Option B: Azure CLI

```bash
# For drafts
az storage blob upload \
  --account-name yourstorageaccount \
  --container-name blog-content \
  --file 2026-01-15-my-post.md \
  --name drafts/2026-01-15-my-post.md

# For published posts
az storage blob upload \
  --account-name yourstorageaccount \
  --container-name blog-content \
  --file 2026-01-15-my-post.md \
  --name posts/2026-01-15-my-post.md
```

#### Option C: GitHub Actions Workflow

1. Commit the downloaded .md file to your repository
2. Go to **Actions** tab → **Upload Post to Azure Blob Storage**
3. Click **Run workflow**
4. Enter the file path (e.g., `my-post.md`)
5. Select draft=true or false
6. Click **Run**

### 4. Managing Drafts

#### View Local Drafts

1. Click **"Load Drafts"** button in the editor
2. See all posts saved locally in your browser
3. Click **"Load"** to edit an existing draft
4. Click **"Delete"** to remove from local storage

#### Move Draft to Published

**Option 1: Via Azure Portal**
- Simply move/copy the file from `drafts/` folder to `posts/` folder

**Option 2: Via Azure CLI**
```bash
# Copy draft to posts
az storage blob copy start \
  --account-name yourstorageaccount \
  --destination-blob posts/2026-01-15-my-post.md \
  --destination-container blog-content \
  --source-account-name yourstorageaccount \
  --source-blob drafts/2026-01-15-my-post.md \
  --source-container blog-content

# Delete from drafts (optional)
az storage blob delete \
  --account-name yourstorageaccount \
  --container-name blog-content \
  --name drafts/2026-01-15-my-post.md
```

**Option 3: Via GitHub Actions**
1. Re-upload with `is_draft=false` using the workflow

## Understanding the Folder Structure

```
Azure Blob Storage Container:
├── drafts/              ← Draft posts (NOT visible on website)
│   ├── 2026-01-15-draft-idea.md
│   └── 2026-02-01-work-in-progress.md
└── posts/               ← Published posts (visible on website)
    ├── 2026-01-11-what-are-agents.md
    └── 2026-01-20-react-pattern.md
```

**Important:**
- Only files in `posts/` folder are loaded and displayed on the website
- Files in `drafts/` folder are stored safely but not shown publicly
- You can work on drafts until ready, then move to `posts/` to publish

## Editor Features

### Live Preview
- See how your markdown renders in real-time
- Preview updates as you type

### Auto-Download
- Post automatically downloads when you click "Save"
- Filename follows Jekyll convention: `YYYY-MM-DD-title.md`

### Local Backup
- Every save creates a backup in browser localStorage
- Access old versions via "Load Drafts"
- Persists even if you close the browser

### Clear Button
- Clears all fields to start fresh
- Doesn't delete local backups

## Workflow Example

### Writing and Publishing a Post

1. **Write** the post in the editor
2. **Save as draft** (checkbox checked)
3. **Download** the .md file
4. **Upload to Azure** `drafts/` folder
5. **Review** and edit as needed (can re-load from local drafts)
6. When ready: **Move file** from `drafts/` to `posts/` in Azure
7. **Site rebuilds** automatically (GitHub Actions)
8. **Post is live!** 🎉

### Editing an Existing Post

Since posts are in Azure Blob Storage:

1. **Download** the post from Azure (drafts/ or posts/)
2. **Copy content** into the editor
3. **Make changes**
4. **Save** (downloads updated file)
5. **Re-upload** to Azure (same filename)
6. **Overwrite** existing file

## Tips & Best Practices

### 1. Use Descriptive Filenames
The editor automatically generates filenames from your title and date:
- Good: `2026-01-15-react-pattern-explained.md`
- Avoid special characters in titles

### 2. Save Frequently
Click "Save" often to:
- Create local backups
- Download the latest version

### 3. Keep Drafts
Use the draft system for:
- Posts you're still researching
- Ideas you want to develop
- Content that needs review

### 4. Preview Before Publishing
Always check the preview pane to ensure:
- Markdown renders correctly
- Links work
- Code blocks format properly

### 5. Backup Your Work
- Local drafts are stored in browser
- Clearing browser data will delete them
- Keep important posts backed up externally

## Security Notes

- ✅ Editor requires password authentication
- ✅ Password same as encrypted ideas admin
- ✅ Posts saved locally in your browser only
- ✅ No server-side storage of credentials
- ⚠️ Anyone with the password can access the editor
- ⚠️ Local drafts stored in browser can be accessed by others using same computer

## Troubleshooting

### "Direct saving not implemented" message
This is expected! The editor works by:
1. Generating the markdown file
2. Downloading it to your computer
3. You upload manually to Azure

This approach is more secure as it doesn't expose Azure credentials to the browser.

### Lost local drafts
Local drafts are stored in browser localStorage:
- Clearing browser data deletes them
- Different browsers have separate storage
- Private/incognito mode doesn't persist

### Preview not working
Make sure the page loaded correctly and marked.js library is available.
Refresh the page if needed.

### Can't log in
The password must be:
- At least 8 characters long
- The same password used for ideas admin

## Future Enhancements

Possible improvements for future versions:
- [ ] Direct Azure Blob Storage API integration
- [ ] Rich text editor option
- [ ] Image upload support
- [ ] Scheduled publishing
- [ ] Multi-user authentication
- [ ] Draft collaboration

## Related Documentation

- [Main README](../README.md) - Feature overview
- [Migration Guide](../MIGRATION.md) - Setup instructions
- [Scripts README](../scripts/README.md) - Helper tools
- [GitHub Secrets](../.github/SECRETS.md) - Secrets configuration

---

Happy writing! ✍️
