# Draft Post Editor

This repository includes a hidden post editor for admin use only.

## Setup

1. **Set Admin Password**: 
   - Go to repository Settings > Secrets and variables > Actions
   - Create a new secret named `ADMIN_PASSWORD`
   - Set a strong password value

2. **Access the Editor**:
   - Navigate to: `https://[your-site-url]/post-editor.html`
   - Login with:
     - Username: Your GitHub username (auto-filled)
     - Password: The password you set in secrets

## Using the Editor

### Creating a Draft Post

1. Click "+ New Draft" button
2. Fill in the post details:
   - **Title**: Post title (required)
   - **Date**: Publication date (required)
   - **Categories**: Comma-separated list (e.g., `ai, llm, agents`)
   - **Tags**: Comma-separated list (e.g., `agentic-ai, assistants`)
   - **Description**: Short description for SEO/preview
   - **Content**: Write your post in Markdown
3. Click "Save as Draft" - this saves to browser localStorage
4. The markdown preview updates in real-time

### Publishing a Draft

1. Select a draft from the left sidebar
2. Review and edit if needed
3. Click "Publish" button
4. The post moves to the Published section

### Syncing with GitHub

Posts are saved in your browser's localStorage. To persist them to GitHub:

#### Option 1: Manual Sync (Simplest)

1. Open the browser console (F12)
2. Run: `console.log(JSON.stringify(window.getPendingChanges(), null, 2))`
3. Copy the output
4. For each change:
   - Navigate to the appropriate folder (`_drafts/` or `_posts/`)
   - Create/edit/delete the file as indicated
   - Commit the changes

#### Option 2: Automated Sync (Advanced)

If you have a personal access token with repo access:

1. Edit `post-editor.html`
2. Add your GitHub token to enable automatic file creation
3. The editor will automatically create/update files via GitHub API

## Draft Posts vs Published Posts

- **Drafts**: Stored in `_drafts/` folder - NOT visible on the live site
- **Published**: Stored in `_posts/` folder - Visible on the live site after deployment

Jekyll automatically excludes the `_drafts` folder from the built site, so draft posts remain private.

## Security Notes

- The `post-editor.html` page is excluded from the built site (`_config.yml`)
- Add `robots.txt` meta tag prevents search engine indexing
- The editor is protected by password authentication
- Never commit the admin password to the repository
- Use GitHub Secrets for production passwords

## Markdown Features

The editor supports full Markdown syntax:

- Headers: `# H1`, `## H2`, etc.
- **Bold**: `**text**`
- *Italic*: `*text*`
- Lists: `- item` or `1. item`
- Links: `[text](url)`
- Images: `![alt](url)`
- Code: `` `inline` `` or ` ```language\nblock\n``` `
- And more...

The preview pane shows how your content will look on the published site.
