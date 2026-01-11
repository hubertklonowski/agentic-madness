# Agentic Madness Blog

A blog about agentic AI, powered by Jekyll and hosted on GitHub Pages.

## 🚀 New Features

This blog now includes:

### 📝 Web-Based Post Editor
- **Write posts directly in your browser** with a built-in markdown editor
- Live preview as you type
- Save drafts locally and manage them before publishing
- Automatic download of posts for easy Azure upload
- See [EDITOR.md](EDITOR.md) for complete guide

### 📦 Azure Blob Storage Integration
- **Posts are loaded from Azure Blob Storage** during build time
- No plain text post content stored in the repository
- Keep posts private until you're ready to publish them
- Simply upload to Azure when ready to go live

### 🔐 Encrypted Post Ideas Management
- Store post ideas securely using AES-256-GCM encryption
- Access your ideas through a password-protected admin page
- Client-side decryption (password never leaves your browser)
- Perfect for brainstorming without publicizing your ideas

### 🎨 Proper Post Rendering
- Posts now render within the website's layout
- Beautiful header with date, categories, and tags
- Consistent styling with the rest of the site
- Table of contents support

## 📖 Setup Guide

For detailed setup instructions, see [scripts/README.md](scripts/README.md)

### Quick Start

1. **Set up Azure Blob Storage:**
   ```bash
   cd scripts
   ruby prepare_azure_upload.rb
   # Follow the instructions
   ```

2. **Encrypt your post ideas:**
   ```bash
   cd scripts
   # Create post_ideas.json with your ideas
   ruby encrypt_ideas.rb
   # Add the output to GitHub secrets
   ```

3. **Configure GitHub Secrets:**
   - `AZURE_STORAGE_ACCOUNT`
   - `AZURE_STORAGE_KEY`
   - `AZURE_CONTAINER_NAME`
   - `ENCRYPTED_IDEAS`

4. **Access your ideas:**
   - Visit: `https://yourusername.github.io/agentic-madness/ideas-admin.html`
   - Enter your encryption password

5. **Use the post editor:**
   - Visit: `https://yourusername.github.io/agentic-madness/editor.html`
   - Write and manage posts directly in your browser
   - See [EDITOR.md](EDITOR.md) for complete guide

## 🛠️ Local Development

For local development, keep posts in `_posts/` (they're gitignored) or set environment variables:

```bash
export AZURE_STORAGE_ACCOUNT='your-account'
export AZURE_STORAGE_KEY='your-key'
export AZURE_CONTAINER_NAME='your-container'
export ENCRYPTED_IDEAS='your-encrypted-data'
bundle install
bundle exec jekyll serve
```

## 📝 Writing Posts

Posts should be in standard Jekyll format:

```markdown
---
layout: post
title: "Your Post Title"
date: 2026-01-11 11:00:00 +0100
categories: [category1, category2]
tags: [tag1, tag2, tag3]
---

Your content here...
```

Upload to Azure Blob Storage in the `posts/` directory when ready to publish.

## 🔒 Security

- ✅ Posts not stored in plain text in repository
- ✅ Post ideas encrypted with AES-256-GCM
- ✅ Client-side decryption only
- ✅ Azure credentials stored as GitHub secrets
- ⚠️ Remember your encryption password!

## 📁 Project Structure

```
.
├── _layouts/
│   └── post.html              # Post rendering layout
├── _plugins/
│   ├── azure_posts_loader.rb  # Fetches posts from Azure
│   └── encrypted_ideas.rb     # Generates ideas admin page
├── scripts/
│   ├── README.md              # Detailed setup guide
│   ├── encrypt_ideas.rb       # Encrypt post ideas tool
│   └── prepare_azure_upload.rb # Azure upload helper
└── .github/workflows/
    └── jekyll-gh-pages.yml    # Updated with Azure integration
```

## 🎯 How It Works

1. **On build**, the Jekyll plugin connects to Azure Blob Storage
2. **Downloads** all markdown files from the `posts/` directory
3. **Renders** them using the post layout
4. **Generates** the encrypted ideas admin page
5. **Deploys** to GitHub Pages

Posts and ideas are never stored in plain text in the repository!

## 📚 More Information

- [Jekyll Documentation](https://jekyllrb.com/)
- [Azure Blob Storage](https://azure.microsoft.com/en-us/services/storage/blobs/)
- [GitHub Pages](https://pages.github.com/)

---

Made with ❤️ using Jekyll and Azure
