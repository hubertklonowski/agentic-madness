# Draft Post Editor

This repository includes a hidden post editor for admin use only. The editor integrates directly with GitHub API to save drafts and publish posts.

## Setup

### 1. Create a GitHub Personal Access Token

1. Go to GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a descriptive name (e.g., "Blog Post Editor")
4. Set expiration as needed
5. Select scopes:
   - ✅ **repo** (Full control of private repositories) - this gives access to create/edit/delete files
6. Click "Generate token"
7. **IMPORTANT**: Copy the token immediately - you won't be able to see it again!

### 2. Access the Editor

1. Navigate to: `https://hubertklonowski.github.io/agentic-madness/post-editor.html`
2. Login with:
   - **Username**: `hubertklonowski` (your GitHub username)
   - **Password**: Your GitHub Personal Access Token (from step 1)

**Security Note**: The token is stored in your browser's session storage and is cleared when you logout or close the tab.

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
3. Click "Save as Draft"
4. The editor will:
   - Create/update the file in `_drafts/` folder via GitHub API
   - Commit the change automatically
   - Reload the posts list

### Publishing a Draft

1. Select a draft from the left sidebar
2. Review and edit if needed
3. Click "Publish" button
4. The editor will:
   - Move the file from `_drafts/` to `_posts/`
   - Delete the draft version
   - Commit the changes
   - Trigger GitHub Pages to rebuild (published posts are visible after ~1-2 minutes)

### Editing Posts

1. Select any post (draft or published) from the sidebar
2. Make your changes
3. Click "Save as Draft" or "Publish" depending on the desired state
4. Changes are committed immediately to GitHub

### Deleting Posts

1. Select a post from the sidebar
2. Click "Delete" button
3. Confirm the deletion
4. The file is deleted from GitHub immediately

## How It Works

The editor uses the [GitHub Contents API](https://docs.github.com/en/rest/repos/contents) to:

- **Load posts**: Fetches files from `_drafts/` and `_posts/` folders
- **Create/Update**: Uses `PUT` request to create or update files
- **Delete**: Uses `DELETE` request to remove files

All changes are committed directly to the `main` branch with descriptive commit messages.

## Draft Posts vs Published Posts

- **Drafts**: Stored in `_drafts/` folder
  - Excluded from the built site (configured in `_config.yml`)
  - NOT visible on the live website
  - Can be edited and worked on over time
  
- **Published**: Stored in `_posts/` folder
  - Included in the built site
  - Visible on the live website after GitHub Pages deploys
  - Can still be edited or unpublished (move back to drafts)

## Security Features

- ✅ Post editor excluded from built site (`_config.yml`)
- ✅ `noindex, nofollow` meta tags prevent search engine indexing
- ✅ Authentication required via GitHub Personal Access Token
- ✅ Token stored in session storage (not persistent)
- ✅ Direct communication with GitHub API (no localStorage)
- ✅ All commits are attributed to your GitHub account

## Markdown Features

The editor supports full Markdown syntax with real-time preview:

- Headers: `# H1`, `## H2`, etc.
- **Bold**: `**text**`
- *Italic*: `*text*`
- Lists: `- item` or `1. item`
- Links: `[text](url)`
- Images: `![alt](url)`
- Code: `` `inline` `` or ` ```language\nblock\n``` `
- And more...

## Troubleshooting

### "Invalid credentials or GitHub token"
- Verify your GitHub username is correct
- Ensure your Personal Access Token has `repo` scope
- Check if the token hasn't expired
- Try generating a new token

### "Error loading posts from GitHub"
- Check your internet connection
- Verify the token has correct permissions
- Check browser console for detailed error messages

### "Error saving draft/post"
- Ensure you have write access to the repository
- Check if the token is still valid
- Verify the file name doesn't contain invalid characters

## File Naming Convention

Files are automatically named based on the date and title:
- Format: `YYYY-MM-DD-title-slug.md`
- Example: `2026-01-12-my-first-post.md`

The title is automatically converted to a URL-friendly slug.
