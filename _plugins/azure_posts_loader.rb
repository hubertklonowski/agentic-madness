require 'net/http'
require 'uri'
require 'json'
require 'openssl'
require 'base64'

module Jekyll
  class AzureBlobPostsLoader < Generator
    safe true
    priority :highest

    def generate(site)
      # Only fetch from Azure if credentials are available
      return unless ENV['AZURE_STORAGE_ACCOUNT'] && ENV['AZURE_STORAGE_KEY'] && ENV['AZURE_CONTAINER_NAME']

      puts "🔵 Loading posts from Azure Blob Storage..."
      
      storage_account = ENV['AZURE_STORAGE_ACCOUNT']
      storage_key = ENV['AZURE_STORAGE_KEY']
      container_name = ENV['AZURE_CONTAINER_NAME']
      
      # List all blobs in the posts directory
      blobs = list_blobs(storage_account, storage_key, container_name, 'posts/')
      
      blobs.each do |blob_name|
        next unless blob_name.end_with?('.md') || blob_name.end_with?('.markdown')
        
        puts "  📄 Fetching: #{blob_name}"
        content = download_blob(storage_account, storage_key, container_name, blob_name)
        
        if content
          # Extract filename from blob path
          filename = File.basename(blob_name)
          
          # Create a temporary file-like object for Jekyll to process
          post_file_path = File.join(site.source, '_posts', filename)
          
          # Ensure _posts directory exists
          FileUtils.mkdir_p(File.dirname(post_file_path))
          
          # Write content temporarily
          File.write(post_file_path, content)
        end
      end
      
      puts "✅ Loaded #{blobs.count} posts from Azure Blob Storage"
    rescue => e
      puts "⚠️  Error loading posts from Azure: #{e.message}"
      puts e.backtrace.first(5).join("\n")
    end

    private

    def list_blobs(storage_account, storage_key, container_name, prefix)
      date = Time.now.httpdate
      version = '2020-10-02'
      
      url = "https://#{storage_account}.blob.core.windows.net/#{container_name}?restype=container&comp=list&prefix=#{prefix}"
      uri = URI(url)
      
      string_to_sign = "GET\n\n\n\n\n\n\n\n\n\n\n\nx-ms-date:#{date}\nx-ms-version:#{version}\n/#{storage_account}/#{container_name}\ncomp:list\nprefix:#{prefix}\nrestype:container"
      
      signature = sign_string(string_to_sign, storage_key)
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Get.new(uri.request_uri)
      request['x-ms-date'] = date
      request['x-ms-version'] = version
      request['Authorization'] = "SharedKey #{storage_account}:#{signature}"
      
      response = http.request(request)
      
      if response.code == '200'
        # Parse XML response to extract blob names
        blob_names = []
        response.body.scan(/<Name>(.*?)<\/Name>/).each do |match|
          blob_names << match[0]
        end
        blob_names
      else
        puts "Error listing blobs: #{response.code} - #{response.body}"
        []
      end
    end

    def download_blob(storage_account, storage_key, container_name, blob_name)
      date = Time.now.httpdate
      version = '2020-10-02'
      
      url = "https://#{storage_account}.blob.core.windows.net/#{container_name}/#{blob_name}"
      uri = URI(url)
      
      string_to_sign = "GET\n\n\n\n\n\n\n\n\n\n\n\nx-ms-date:#{date}\nx-ms-version:#{version}\n/#{storage_account}/#{container_name}/#{blob_name}"
      
      signature = sign_string(string_to_sign, storage_key)
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Get.new(uri.request_uri)
      request['x-ms-date'] = date
      request['x-ms-version'] = version
      request['Authorization'] = "SharedKey #{storage_account}:#{signature}"
      
      response = http.request(request)
      
      if response.code == '200'
        response.body
      else
        puts "Error downloading blob: #{response.code}"
        nil
      end
    end

    def sign_string(string_to_sign, storage_key)
      decoded_key = Base64.decode64(storage_key)
      hmac = OpenSSL::HMAC.digest('sha256', decoded_key, string_to_sign)
      Base64.encode64(hmac).strip
    end
  end
end
