# Agentic Madness

A blog exploring the world of AI agents and autonomous systems, built with Jekyll and the LibDoc theme.

## About

This is a static site hosted on GitHub Pages, featuring articles and insights about AI agents, autonomous systems, and related technologies.

**Live Site:** https://agenticmadness.com

## Features

- **LibDoc Theme**: Clean, documentation-style layout
- **Giscus Comments**: GitHub Discussions-powered comments on posts
- **Search**: Built-in search functionality
- **Syntax Highlighting**: Code blocks with Prism.js
- **Responsive Design**: Mobile-friendly layout

## Prerequisites

- Ruby (version 2.7 or higher)
- RubyGems
- Bundler

## Installation

1. Clone this repository:
```bash
git clone https://github.com/hubertklonowski/agentic-madness.git
cd agentic-madness
```

2. Install dependencies:
```bash
bundle install
```

## Running Locally

### Development Server

Start the Jekyll development server:

```bash
bundle exec jekyll serve
```

The site will be available at `http://localhost:4000`

### Live Reload

For automatic rebuilding when files change:

```bash
bundle exec jekyll serve --livereload
```

### Drafts Mode

To preview draft posts:

```bash
bundle exec jekyll serve --drafts
```

## Project Structure

```
├── _config.yml           # Jekyll configuration
├── _posts/               # Blog posts (YYYY-MM-DD-title.md format)
├── _drafts/              # Draft posts (not published)
├── _layouts/             # Page templates
├── _includes/            # Reusable components
├── _data/                # Data files (e.g., comments)
├── assets/               # CSS, JavaScript, images
├── _site/                # Generated site (don't edit directly)
├── post-editor.html      # Hidden admin editor
├── EDITOR_GUIDE.md       # Editor documentation
└── index.md              # Homepage
```

## Creating New Posts

1. Create a new file in `_posts/` with the naming format:
   ```
   YYYY-MM-DD-title-of-post.md
   ```

2. Add front matter at the top:
   ```yaml
   ---
   layout: libdoc/page
   title: "Your Post Title"
   description: "Brief description"
   categories: [AI, Agents]
   tags: [automation, machine-learning]
   ---
   ```

3. Write your content in Markdown below the front matter

4. Preview locally with `bundle exec jekyll serve`

**Draft vs Published**:
- `_drafts/`: Not visible on the live site
- `_posts/`: Visible on the live site

## Deployment

This site is configured for GitHub Pages deployment. Commits to the main branch will automatically trigger a rebuild and deploy.

**GitHub Actions Workflow**: `.github/workflows/jekyll-gh-pages.yml`

### Manual GitHub Pages Setup

1. Go to repository Settings → Pages
2. Set source to "Deploy from a branch"
3. Select the branch (usually `main` or `gh-pages`)
4. Save settings

## Configuration

Key configuration options in `_config.yml`:

- `title`: Site title
- `description`: Site description
- `url`: Your site URL (update for production)
- `baseurl`: Subpath if not at domain root
- `permalink`: URL structure for posts
- `giscus`: Comments configuration

## Customization

- **Styles**: Edit `assets/libdoc/css/custom.css`
- **Sidebar**: Configure in `_config.yml` under `sidebar`
- **Layouts**: Modify files in `_layouts/libdoc/`
- **Includes**: Edit reusable components in `_includes/`

## Troubleshooting

### Common Issues

**Port already in use:**
```bash
bundle exec jekyll serve --port 4001
```

**Dependencies out of date:**
```bash
bundle update
```

**Changes not appearing:**
- Check `exclude` list in `_config.yml`
- Restart the server (config changes require restart)

## Resources

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [LibDoc Theme](https://github.com/olivier3lanc/Jekyll-LibDoc)
- [Markdown Guide](https://www.markdownguide.org/)

## Comments System

This blog uses [Giscus](https://giscus.app/) powered by GitHub Discussions. Comments are configured in `_config.yml` and will appear on blog posts automatically.

## Building for Production

To build the site for production:

```bash
bundle exec jekyll build
```

The built site will be in the `_site/` directory.

## License

MIT License - See individual components for their respective licenses.

## Contributing

This is a personal blog.

## Contact

For questions or feedback, visit [hubertklonowski on GitHub](https://github.com/hubertklonowski).
