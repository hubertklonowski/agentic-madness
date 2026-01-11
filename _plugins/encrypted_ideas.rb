require 'json'
require 'base64'

module Jekyll
  class EncryptedIdeasGenerator < Generator
    safe true
    priority :low

    def generate(site)
      # Check if encrypted ideas are available
      return unless ENV['ENCRYPTED_IDEAS']

      puts "🔐 Processing encrypted post ideas..."
      
      # Create a page for the admin interface
      # Using a relative path for the admin page
      admin_page = PageWithoutAFile.new(site, site.source, '', 'ideas-admin.html')
      admin_page.data['layout'] = 'libdoc/page'
      admin_page.data['title'] = 'Post Ideas Admin'
      admin_page.data['description'] = 'Manage your encrypted post ideas'
      admin_page.data['encrypted_data'] = ENV['ENCRYPTED_IDEAS']
      admin_page.data['content_class'] = 'm-grow m-w-1 u-mw-main u-bc-primary-max'
      
      admin_page.content = <<~HTML
        <style>
          .ideas-login {
            max-width: 400px;
            margin: 2rem auto;
            padding: 2rem;
            background: var(--bg-primary-edge, #f5f5f5);
            border-radius: 8px;
          }
          .ideas-content {
            display: none;
          }
          .ideas-content.unlocked {
            display: block;
          }
          .idea-item {
            padding: 1rem;
            margin: 1rem 0;
            background: var(--bg-primary-edge, #f5f5f5);
            border-left: 4px solid var(--c-primary, #556e1e);
            border-radius: 4px;
          }
          .idea-date {
            font-size: 0.875rem;
            opacity: 0.7;
            margin-bottom: 0.5rem;
          }
          .error-message {
            color: #d32f2f;
            margin-top: 0.5rem;
            display: none;
          }
          .error-message.show {
            display: block;
          }
          .form-group {
            margin-bottom: 1rem;
          }
          .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
          }
          .form-group input {
            width: 100%;
            padding: 0.5rem;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 1rem;
          }
          .btn {
            background: var(--bg-primary, #556e1e);
            color: white;
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
            width: 100%;
          }
          .btn:hover {
            opacity: 0.9;
          }
          .logout-btn {
            background: #666;
            margin-top: 1rem;
          }
        </style>

        <div class="ideas-login" id="loginForm">
          <h2>🔐 Access Post Ideas</h2>
          <p>Enter your password to view encrypted post ideas.</p>
          <form onsubmit="unlockIdeas(event)">
            <div class="form-group">
              <label for="password">Password:</label>
              <input type="password" id="password" required autocomplete="current-password">
            </div>
            <button type="submit" class="btn">Unlock Ideas</button>
          </form>
          <div class="error-message" id="errorMessage">Incorrect password. Please try again.</div>
        </div>

        <div class="ideas-content" id="ideasContent">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem;">
            <h2>💡 Post Ideas</h2>
            <button onclick="lockIdeas()" class="btn logout-btn" style="width: auto;">Lock</button>
          </div>
          <div id="ideasList"></div>
        </div>

        <script>
          const ENCRYPTED_DATA = '{{ page.encrypted_data }}';
          
          async function deriveKey(password, salt) {
            const enc = new TextEncoder();
            const keyMaterial = await crypto.subtle.importKey(
              'raw',
              enc.encode(password),
              'PBKDF2',
              false,
              ['deriveKey']
            );
            
            return crypto.subtle.deriveKey(
              {
                name: 'PBKDF2',
                salt: salt,
                iterations: 100000,
                hash: 'SHA-256'
              },
              keyMaterial,
              { name: 'AES-GCM', length: 256 },
              false,
              ['decrypt']
            );
          }
          
          async function decryptData(password, encryptedData) {
            try {
              const data = JSON.parse(atob(encryptedData));
              const salt = new Uint8Array(data.salt);
              const iv = new Uint8Array(data.iv);
              const ciphertext = new Uint8Array(data.ciphertext);
              
              const key = await deriveKey(password, salt);
              
              const decrypted = await crypto.subtle.decrypt(
                { name: 'AES-GCM', iv: iv },
                key,
                ciphertext
              );
              
              const decoder = new TextDecoder();
              return JSON.parse(decoder.decode(decrypted));
            } catch (e) {
              console.error('Decryption error:', e);
              return null;
            }
          }
          
          async function unlockIdeas(event) {
            event.preventDefault();
            const password = document.getElementById('password').value;
            const errorMsg = document.getElementById('errorMessage');
            
            errorMsg.classList.remove('show');
            
            if (!ENCRYPTED_DATA) {
              errorMsg.textContent = 'No encrypted data available.';
              errorMsg.classList.add('show');
              return;
            }
            
            const ideas = await decryptData(password, ENCRYPTED_DATA);
            
            if (ideas) {
              displayIdeas(ideas);
              document.getElementById('loginForm').style.display = 'none';
              document.getElementById('ideasContent').classList.add('unlocked');
              document.getElementById('password').value = '';
            } else {
              errorMsg.classList.add('show');
            }
          }
          
          function displayIdeas(ideas) {
            const list = document.getElementById('ideasList');
            if (ideas.length === 0) {
              list.innerHTML = '<p>No post ideas yet. Add some to your encrypted storage!</p>';
              return;
            }
            
            list.innerHTML = ideas.map(idea => `
              <div class="idea-item">
                <div class="idea-date">${idea.date || 'No date'}</div>
                <h3>${idea.title}</h3>
                <p>${idea.description || ''}</p>
                ${idea.tags ? '<p><small>Tags: ' + idea.tags.join(', ') + '</small></p>' : ''}
              </div>
            `).join('');
          }
          
          function lockIdeas() {
            document.getElementById('loginForm').style.display = 'block';
            document.getElementById('ideasContent').classList.remove('unlocked');
            document.getElementById('ideasList').innerHTML = '';
          }
        </script>
      HTML

      site.pages << admin_page
      
      puts "✅ Created encrypted ideas admin page at /ideas-admin.html"
    rescue => e
      puts "⚠️  Error creating encrypted ideas page: #{e.message}"
    end
  end
end
