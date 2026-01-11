# GitHub Secrets Configuration

This repository requires the following GitHub secrets to be configured for the build process.

## Required Secrets

### Azure Blob Storage Secrets

These secrets are used to fetch blog posts from Azure Blob Storage during the build process.

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AZURE_STORAGE_ACCOUNT` | Your Azure Storage Account name | `myblogstorageaccount` |
| `AZURE_STORAGE_KEY` | Your Azure Storage Account access key | `abcdef123456...` |
| `AZURE_CONTAINER_NAME` | The container name where posts are stored | `blog-content` |

### Post Ideas Secret

This secret stores encrypted post ideas that can be accessed via the admin interface.

| Secret Name | Description | How to Generate |
|-------------|-------------|-----------------|
| `ENCRYPTED_IDEAS` | Encrypted JSON of post ideas | Run `scripts/encrypt_ideas.rb` |

## How to Add Secrets

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Enter the secret name and value
5. Click **Add secret**

## Secrets are Optional

- **Without Azure secrets**: Posts will not be loaded from Azure (you can keep posts in `_posts/` locally for development)
- **Without ENCRYPTED_IDEAS**: The ideas admin page will not be generated

## Security Notes

- ✅ Secrets are encrypted by GitHub
- ✅ Secrets are only available during workflow execution
- ✅ Secret values are never exposed in logs
- ⚠️ Only repository admins can add/modify secrets
- ⚠️ Store your encryption password separately (not in GitHub)

## More Information

- See [MIGRATION.md](../MIGRATION.md) for setup instructions
- See [scripts/README.md](../scripts/README.md) for detailed documentation
