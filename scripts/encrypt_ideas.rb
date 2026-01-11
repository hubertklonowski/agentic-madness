#!/usr/bin/env ruby

require 'json'
require 'openssl'
require 'base64'
require 'io/console'

def encrypt_data(password, data_json)
  # Generate salt and IV
  salt = OpenSSL::Random.random_bytes(16)
  iv = OpenSSL::Random.random_bytes(12)
  
  # Derive key using PBKDF2
  key = OpenSSL::PKCS5.pbkdf2_hmac(
    password,
    salt,
    100000,
    32,
    'sha256'
  )
  
  # Encrypt using AES-GCM
  cipher = OpenSSL::Cipher.new('aes-256-gcm')
  cipher.encrypt
  cipher.key = key
  cipher.iv = iv
  
  ciphertext = cipher.update(data_json) + cipher.final
  auth_tag = cipher.auth_tag
  
  # Combine ciphertext and auth tag
  encrypted = ciphertext + auth_tag
  
  # Return as base64-encoded JSON
  result = {
    salt: salt.bytes,
    iv: iv.bytes,
    ciphertext: encrypted.bytes
  }
  
  Base64.strict_encode64(result.to_json)
end

# Example post ideas data structure
example_ideas = [
  {
    title: "Introduction to Machine Learning",
    description: "A beginner-friendly guide to ML concepts and practical applications",
    tags: ["ai", "ml", "tutorial"],
    date: "2026-01-15"
  },
  {
    title: "Building Scalable APIs",
    description: "Best practices for designing and implementing scalable REST APIs",
    tags: ["api", "backend", "scalability"],
    date: "2026-02-01"
  }
]

puts "🔐 Post Ideas Encryption Tool"
puts "=" * 50
puts "\nThis tool will help you encrypt your post ideas."
puts "The encrypted data can be stored as a GitHub secret."
puts "\n"

# Load existing ideas file or use example
ideas_file = File.expand_path(File.join(__dir__, 'post_ideas.json'))
if File.exist?(ideas_file)
  puts "📄 Loading existing ideas from post_ideas.json"
  begin
    ideas = JSON.parse(File.read(ideas_file))
  rescue JSON::ParserError => e
    puts "❌ Error parsing post_ideas.json: #{e.message}"
    puts "Please check that your JSON file is valid."
    exit 1
  end
else
  puts "📝 Using example ideas (create post_ideas.json to use your own)"
  ideas = example_ideas
end

puts "\nPost ideas to encrypt:"
puts JSON.pretty_generate(ideas)
puts "\n"

# Get password
print "Enter encryption password: "
password = STDIN.noecho(&:gets).chomp
puts ""
print "Confirm password: "
password_confirm = STDIN.noecho(&:gets).chomp
puts "\n"

if password != password_confirm
  puts "❌ Passwords don't match!"
  exit 1
end

if password.length < 12
  puts "❌ Password must be at least 12 characters long for better security!"
  exit 1
end

# Encrypt
encrypted = encrypt_data(password, ideas.to_json)

puts "✅ Encryption successful!"
puts "\n" + "=" * 50
puts "Add this as a GitHub secret named 'ENCRYPTED_IDEAS':"
puts "=" * 50
puts encrypted
puts "=" * 50
puts "\nTo add this secret to GitHub:"
puts "1. Go to your repository settings"
puts "2. Navigate to Secrets and variables > Actions"
puts "3. Click 'New repository secret'"
puts "4. Name: ENCRYPTED_IDEAS"
puts "5. Value: (paste the encrypted string above)"
puts "\nDone! 🎉"
