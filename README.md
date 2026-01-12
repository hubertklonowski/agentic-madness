# Agentic Madness

A blog exploring the world of AI agents and autonomous systems, built with Jekyll and GitHub Pages.

## 🚀 Features

- Jekyll-powered blog with LibDoc theme
- Markdown-based posts
- Draft post management
- **Hidden admin post editor** with GitHub API integration

## 📝 Admin Post Editor

This repository includes a hidden, password-protected post editor accessible only to the admin. The editor allows you to:

- ✅ Create draft posts with live Markdown preview
- ✅ Edit existing drafts and published posts
- ✅ Publish drafts to make them live
- ✅ Delete posts
- ✅ All changes push directly to GitHub via API

### Access the Editor

**URL**: [https://hubertklonowski.github.io/agentic-madness/post-editor.html](https://hubertklonowski.github.io/agentic-madness/post-editor.html)

**Requirements**:
- GitHub username: `hubertklonowski`
- GitHub Personal Access Token with `repo` scope

See [EDITOR_GUIDE.md](./EDITOR_GUIDE.md) for detailed usage instructions.

### Security

- 🔒 Protected by GitHub Personal Access Token authentication
- 🔒 Editor excluded from built site and search engines
- 🔒 Draft posts stored in `_drafts/` folder (not publicly visible)
- 🔒 All operations go directly to GitHub API (no localStorage)

## 🛠️ Local Development

### Prerequisites

- Ruby 3.x
- Bundler

### Setup

```bash
# Install dependencies
bundle install

# Serve locally
bundle exec jekyll serve

# Serve with drafts visible (for testing)
bundle exec jekyll serve --drafts
```

Visit `http://localhost:4000` to view the site.

## 📂 Project Structure

```
.
├── _drafts/              # Draft posts (not published)
├── _posts/               # Published posts
├── _includes/            # Reusable components
├── _layouts/             # Page layouts
├── assets/               # CSS, JS, images
├── post-editor.html      # Hidden admin editor
├── _config.yml           # Jekyll configuration
├── EDITOR_GUIDE.md       # Editor documentation
└── index.md              # Homepage
```

## 📄 Writing Posts

### Using the Editor (Recommended)

Use the [post editor](https://hubertklonowski.github.io/agentic-madness/post-editor.html) for the easiest experience.

### Manual Method

Create a new file in `_drafts/` or `_posts/`:

```markdown
---
layout: libdoc/post
title: "Your Post Title"
date: 2026-01-12 12:00:00 +0100
categories: [ai, llm]
tags: [agents, automation]
description: "Short description"
---

Your content here...
```

**Draft vs Published**:
- `_drafts/`: Not visible on the live site
- `_posts/`: Visible on the live site

## 🚢 Deployment

The site automatically deploys to GitHub Pages when changes are pushed to the `main` branch.

**GitHub Actions Workflow**: `.github/workflows/jekyll-gh-pages.yml`

## 📚 Theme

This site uses the [LibDoc](https://github.com/olivier3lanc/Jekyll-LibDoc) Jekyll theme.

## 📜 License

MIT License - See individual components for their respective licenses.

## 🤝 Contributing

This is a personal blog. The admin post editor is intended for the repository owner only.

## 📧 Contact

For questions or feedback, please open an issue or visit [hubertklonowski on GitHub](https://github.com/hubertklonowski).
