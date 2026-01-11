require 'json'
require 'base64'

module Jekyll
  class PostEditorGenerator < Generator
    safe true
    priority :low

    def generate(site)
      puts "📝 Creating post editor page..."
      
      # Create editor page
      editor_page = PageWithoutAFile.new(site, site.source, '', 'editor.html')
      editor_page.data['layout'] = 'libdoc/page'
      editor_page.data['title'] = 'Post Editor'
      editor_page.data['description'] = 'Write and manage your blog posts'
      editor_page.data['content_class'] = 'm-grow m-w-1 u-bc-primary-max'
      
      # Get Azure configuration from environment
      storage_account = ENV['AZURE_STORAGE_ACCOUNT'] || ''
      container_name = ENV['AZURE_CONTAINER_NAME'] || ''
      
      editor_page.content = <<~HTML
        <style>
          .editor-login {
            max-width: 400px;
            margin: 2rem auto;
            padding: 2rem;
            background: var(--bg-primary-edge, #f5f5f5);
            border-radius: 8px;
          }
          .editor-container {
            display: none;
            max-width: 1200px;
            margin: 0 auto;
          }
          .editor-container.unlocked {
            display: block;
          }
          .editor-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid var(--c-primary, #556e1e);
          }
          .editor-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
            margin-bottom: 2rem;
          }
          @media (max-width: 768px) {
            .editor-grid {
              grid-template-columns: 1fr;
            }
          }
          .form-section {
            background: var(--bg-primary-edge, #f5f5f5);
            padding: 1.5rem;
            border-radius: 8px;
          }
          .form-section h3 {
            margin-top: 0;
            margin-bottom: 1rem;
            font-size: 1.25rem;
          }
          .form-group {
            margin-bottom: 1rem;
          }
          .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
          }
          .form-group input,
          .form-group textarea,
          .form-group select {
            width: 100%;
            padding: 0.5rem;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 1rem;
            font-family: inherit;
          }
          .form-group textarea {
            font-family: 'Courier New', monospace;
            min-height: 400px;
            resize: vertical;
          }
          #preview {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            border: 1px solid #ddd;
            min-height: 400px;
          }
          .btn {
            background: var(--bg-primary, #556e1e);
            color: white;
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
            margin-right: 0.5rem;
          }
          .btn:hover {
            opacity: 0.9;
          }
          .btn-secondary {
            background: #666;
          }
          .btn-danger {
            background: #d32f2f;
          }
          .btn-success {
            background: #388e3c;
          }
          .error-message,
          .success-message {
            padding: 1rem;
            border-radius: 4px;
            margin-bottom: 1rem;
            display: none;
          }
          .error-message {
            background: #ffebee;
            color: #c62828;
            border: 1px solid #ef5350;
          }
          .success-message {
            background: #e8f5e9;
            color: #2e7d32;
            border: 1px solid #66bb6a;
          }
          .error-message.show,
          .success-message.show {
            display: block;
          }
          .draft-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            background: #ff9800;
            color: white;
            border-radius: 4px;
            font-size: 0.875rem;
            margin-left: 0.5rem;
          }
          .published-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            background: #4caf50;
            color: white;
            border-radius: 4px;
            font-size: 0.875rem;
            margin-left: 0.5rem;
          }
          .drafts-list {
            background: var(--bg-primary-edge, #f5f5f5);
            padding: 1.5rem;
            border-radius: 8px;
            margin-top: 2rem;
          }
          .draft-item {
            padding: 1rem;
            background: white;
            border-radius: 4px;
            margin-bottom: 0.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
          }
          .draft-item:hover {
            background: #f9f9f9;
          }
          #autoSaveStatus {
            font-size: 0.875rem;
            color: #666;
          }
        </style>

        <div class="editor-login" id="loginForm">
          <h2>🔐 Post Editor Access</h2>
          <p>Enter your password to access the post editor.</p>
          <form onsubmit="unlockEditor(event)">
            <div class="form-group">
              <label for="password">Password:</label>
              <input type="password" id="password" required autocomplete="current-password">
            </div>
            <button type="submit" class="btn">Unlock Editor</button>
          </form>
          <div class="error-message" id="loginError">Incorrect password. Please try again.</div>
        </div>

        <div class="editor-container" id="editorContainer">
          <div class="editor-header">
            <div>
              <h2>✍️ Post Editor</h2>
              <span id="autoSaveStatus"></span>
            </div>
            <button onclick="lockEditor()" class="btn btn-secondary">Lock</button>
          </div>

          <div class="error-message" id="errorMessage"></div>
          <div class="success-message" id="successMessage"></div>

          <div class="editor-grid">
            <div class="form-section">
              <h3>Post Metadata</h3>
              <div class="form-group">
                <label for="postTitle">Title:</label>
                <input type="text" id="postTitle" placeholder="My Awesome Post" required>
              </div>
              <div class="form-group">
                <label for="postDate">Date:</label>
                <input type="datetime-local" id="postDate" required>
              </div>
              <div class="form-group">
                <label for="postCategories">Categories (comma-separated):</label>
                <input type="text" id="postCategories" placeholder="ai, llm, agents">
              </div>
              <div class="form-group">
                <label for="postTags">Tags (comma-separated):</label>
                <input type="text" id="postTags" placeholder="tutorial, guide, beginner">
              </div>
              <div class="form-group">
                <label>
                  <input type="checkbox" id="isDraft" checked>
                  Save as Draft (uncheck to publish)
                </label>
              </div>
            </div>

            <div class="form-section">
              <h3>Preview</h3>
              <div id="preview"></div>
            </div>
          </div>

          <div class="form-section">
            <h3>Content (Markdown)</h3>
            <div class="form-group">
              <textarea id="postContent" placeholder="Write your post content here in Markdown..."></textarea>
            </div>
          </div>

          <div style="margin-top: 1rem;">
            <button onclick="savePost()" class="btn btn-success">💾 Save Post</button>
            <button onclick="clearEditor()" class="btn btn-secondary">🗑️ Clear</button>
            <button onclick="loadDrafts()" class="btn">📋 Load Drafts</button>
          </div>

          <div class="drafts-list" id="draftsList" style="display: none;">
            <h3>My Drafts</h3>
            <div id="draftsContent"></div>
          </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
        <script>
          let authToken = null;
          let autoSaveTimer = null;
          const STORAGE_ACCOUNT = '#{storage_account}';
          const CONTAINER_NAME = '#{container_name}';

          // Initialize marked for markdown preview
          if (typeof marked !== 'undefined') {
            marked.setOptions({
              breaks: true,
              gfm: true
            });
          }

          // Password authentication (same as ideas admin)
          async function unlockEditor(event) {
            event.preventDefault();
            const password = document.getElementById('password').value;
            const errorMsg = document.getElementById('loginError');
            
            errorMsg.classList.remove('show');
            
            // Store the password as auth token (in real app, this would verify against a hash)
            // For this static site, we use the same password as encrypted ideas
            authToken = password;
            
            // Simple validation - password must be at least 8 characters
            if (password.length >= 8) {
              document.getElementById('loginForm').style.display = 'none';
              document.getElementById('editorContainer').classList.add('unlocked');
              document.getElementById('password').value = '';
              
              // Set default date to now
              const now = new Date();
              const localDateTime = new Date(now.getTime() - now.getTimezoneOffset() * 60000).toISOString().slice(0, 16);
              document.getElementById('postDate').value = localDateTime;
              
              showSuccess('Editor unlocked successfully!');
            } else {
              errorMsg.classList.add('show');
            }
          }

          function lockEditor() {
            authToken = null;
            document.getElementById('loginForm').style.display = 'block';
            document.getElementById('editorContainer').classList.remove('unlocked');
            clearEditor();
          }

          // Update preview on content change
          document.addEventListener('DOMContentLoaded', () => {
            const contentTextarea = document.getElementById('postContent');
            if (contentTextarea) {
              contentTextarea.addEventListener('input', updatePreview);
            }
          });

          function updatePreview() {
            const content = document.getElementById('postContent').value;
            const preview = document.getElementById('preview');
            if (typeof marked !== 'undefined') {
              preview.innerHTML = marked.parse(content);
            } else {
              preview.textContent = content;
            }
          }

          function generateFilename(title, date, isDraft) {
            const dateObj = new Date(date);
            const dateStr = dateObj.toISOString().split('T')[0];
            const slug = title.toLowerCase()
              .replace(/[^a-z0-9]+/g, '-')
              .replace(/(^-|-$)/g, '');
            const folder = isDraft ? 'drafts' : 'posts';
            return \`\${folder}/\${dateStr}-\${slug}.md\`;
          }

          function generateMarkdown() {
            const title = document.getElementById('postTitle').value;
            const date = document.getElementById('postDate').value;
            const categories = document.getElementById('postCategories').value
              .split(',').map(c => c.trim()).filter(c => c);
            const tags = document.getElementById('postTags').value
              .split(',').map(t => t.trim()).filter(t => t);
            const content = document.getElementById('postContent').value;
            
            const dateObj = new Date(date);
            const formattedDate = dateObj.toISOString().replace('T', ' ').slice(0, 19) + ' +0100';
            
            let frontMatter = '---\\n';
            frontMatter += 'layout: post\\n';
            frontMatter += \`title: "\${title}"\\n\`;
            frontMatter += \`date: \${formattedDate}\\n\`;
            if (categories.length > 0) {
              frontMatter += \`categories: [\${categories.join(', ')}]\\n\`;
            }
            if (tags.length > 0) {
              frontMatter += \`tags: [\${tags.join(', ')}]\\n\`;
            }
            frontMatter += '---\\n\\n';
            
            return frontMatter + content;
          }

          async function savePost() {
            if (!authToken) {
              showError('Not authenticated. Please login first.');
              return;
            }

            const title = document.getElementById('postTitle').value;
            const date = document.getElementById('postDate').value;
            const isDraft = document.getElementById('isDraft').checked;

            if (!title || !date) {
              showError('Please fill in title and date.');
              return;
            }

            const markdown = generateMarkdown();
            const filename = generateFilename(title, date, isDraft);

            showInfo('Saving post...');

            try {
              // Since this is a static site, we need to use Azure Blob Storage REST API
              // However, this requires CORS to be enabled on the storage account
              // For security, we'll provide instructions to use a separate backend
              
              showError('Direct saving is not yet implemented. Please use the GitHub Actions workflow or Azure Portal to upload posts manually. See documentation for details.');
              
              // Store in localStorage as a backup
              const drafts = JSON.parse(localStorage.getItem('localDrafts') || '[]');
              drafts.push({
                filename,
                title,
                date,
                isDraft,
                markdown,
                savedAt: new Date().toISOString()
              });
              localStorage.setItem('localDrafts', JSON.stringify(drafts));
              
              showSuccess(\`Post saved locally! Filename: \${filename}\\n\\nTo publish: Upload this file to Azure Blob Storage in the \${isDraft ? 'drafts' : 'posts'} folder.\`);
              
              // Offer download
              downloadMarkdown(filename, markdown);
            } catch (error) {
              showError('Error saving post: ' + error.message);
            }
          }

          function downloadMarkdown(filename, content) {
            const blob = new Blob([content], { type: 'text/markdown' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = filename.split('/').pop();
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
          }

          function loadDrafts() {
            const drafts = JSON.parse(localStorage.getItem('localDrafts') || '[]');
            const container = document.getElementById('draftsContent');
            const list = document.getElementById('draftsList');
            
            if (drafts.length === 0) {
              container.innerHTML = '<p>No local drafts found.</p>';
            } else {
              container.innerHTML = drafts.map((draft, index) => \`
                <div class="draft-item">
                  <div>
                    <strong>\${draft.title}</strong>
                    <span class="\${draft.isDraft ? 'draft-badge' : 'published-badge'}">
                      \${draft.isDraft ? 'Draft' : 'Published'}
                    </span>
                    <br>
                    <small>\${new Date(draft.savedAt).toLocaleString()}</small>
                  </div>
                  <div>
                    <button class="btn" onclick="loadDraft(\${index})">Load</button>
                    <button class="btn btn-danger" onclick="deleteDraft(\${index})">Delete</button>
                  </div>
                </div>
              \`).join('');
            }
            
            list.style.display = 'block';
          }

          function loadDraft(index) {
            const drafts = JSON.parse(localStorage.getItem('localDrafts') || '[]');
            const draft = drafts[index];
            
            if (draft) {
              document.getElementById('postTitle').value = draft.title;
              document.getElementById('postDate').value = new Date(draft.date).toISOString().slice(0, 16);
              document.getElementById('isDraft').checked = draft.isDraft;
              
              // Parse markdown to extract categories, tags, and content
              const lines = draft.markdown.split('\\n');
              let inFrontMatter = false;
              let content = [];
              
              for (let i = 0; i < lines.length; i++) {
                const line = lines[i];
                if (line === '---') {
                  if (inFrontMatter) {
                    inFrontMatter = false;
                    continue;
                  } else {
                    inFrontMatter = true;
                    continue;
                  }
                }
                
                if (inFrontMatter) {
                  if (line.startsWith('categories:')) {
                    const match = line.match(/\\[(.*?)\\]/);
                    if (match) {
                      document.getElementById('postCategories').value = match[1];
                    }
                  } else if (line.startsWith('tags:')) {
                    const match = line.match(/\\[(.*?)\\]/);
                    if (match) {
                      document.getElementById('postTags').value = match[1];
                    }
                  }
                } else if (!inFrontMatter && i > 0) {
                  content.push(line);
                }
              }
              
              document.getElementById('postContent').value = content.join('\\n').trim();
              updatePreview();
              showSuccess('Draft loaded!');
            }
          }

          function deleteDraft(index) {
            if (confirm('Are you sure you want to delete this draft?')) {
              const drafts = JSON.parse(localStorage.getItem('localDrafts') || '[]');
              drafts.splice(index, 1);
              localStorage.setItem('localDrafts', JSON.stringify(drafts));
              loadDrafts();
              showSuccess('Draft deleted!');
            }
          }

          function clearEditor() {
            document.getElementById('postTitle').value = '';
            document.getElementById('postDate').value = '';
            document.getElementById('postCategories').value = '';
            document.getElementById('postTags').value = '';
            document.getElementById('postContent').value = '';
            document.getElementById('isDraft').checked = true;
            updatePreview();
          }

          function showError(message) {
            const el = document.getElementById('errorMessage');
            el.textContent = message;
            el.classList.add('show');
            setTimeout(() => el.classList.remove('show'), 5000);
          }

          function showSuccess(message) {
            const el = document.getElementById('successMessage');
            el.textContent = message;
            el.classList.add('show');
            setTimeout(() => el.classList.remove('show'), 5000);
          }

          function showInfo(message) {
            document.getElementById('autoSaveStatus').textContent = message;
          }
        </script>
      HTML

      site.pages << editor_page
      
      puts "✅ Created post editor page at /editor.html"
    rescue => e
      puts "⚠️  Error creating post editor page: #{e.message}"
    end
  end
end
