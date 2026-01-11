#!/usr/bin/env ruby

require 'json'
require 'fileutils'

puts "📦 Azure Blob Storage Post Upload Helper"
puts "=" * 50
puts "\nThis script helps you prepare posts for Azure Blob Storage."
puts "Posts in _posts/ will be identified for upload.\n"

posts_dir = File.expand_path(File.join(__dir__, '..', '_posts'))
unless Dir.exist?(posts_dir)
  puts "❌ No _posts directory found!"
  exit 1
end

# Find all markdown files in _posts
post_files = Dir.glob(File.join(posts_dir, '*.{md,markdown}'))

if post_files.empty?
  puts "❌ No post files found in _posts directory!"
  exit 1
end

puts "📄 Found #{post_files.length} post(s):\n"
post_files.each do |file|
  puts "  - #{File.basename(file)}"
end

puts "\n" + "=" * 50
puts "To upload these posts to Azure Blob Storage:"
puts "=" * 50
puts "\n1. Install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
puts "\n2. Login to Azure:"
puts "   az login"
puts "\n3. Set your storage account variables:"
puts "   export AZURE_STORAGE_ACCOUNT='yourstorageaccount'"
puts "   export AZURE_STORAGE_KEY='yourstoragekey'"
puts "\n4. Create a container (if not exists):"
puts "   az storage container create --name your-container-name"
puts "\n5. Upload posts to the 'posts/' directory in your container:"
post_files.each do |file|
  filename = File.basename(file)
  puts "   az storage blob upload --container-name your-container-name --file '#{file}' --name 'posts/#{filename}'"
end
puts "\n6. Add these GitHub secrets to your repository:"
puts "   - AZURE_STORAGE_ACCOUNT: Your storage account name"
puts "   - AZURE_STORAGE_KEY: Your storage account key"
puts "   - AZURE_CONTAINER_NAME: Your container name"
puts "\n7. Once uploaded and secrets are set, you can remove posts from the repository"
puts "   (They will be fetched from Azure during build)"
puts "\n" + "=" * 50
puts "\nAlternatively, use the Azure Portal:"
puts "1. Go to portal.azure.com"
puts "2. Navigate to your Storage Account"
puts "3. Go to Containers and create/select your container"
puts "4. Upload files to a 'posts/' folder"
puts "5. Get your storage account key from 'Access keys'"
puts "\nDone! 🎉"
