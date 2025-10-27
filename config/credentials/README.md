# Rails Encrypted Credentials

## Overview

This project uses Rails encrypted credentials to store sensitive configuration. All secrets are stored in **encrypted files** that are safe to commit to Git.

## Files Structure

```
config/credentials/
  development.key         ← Decryption key (gitignored, keep secret!)
  development.yml.enc     ← Encrypted secrets (safe to commit)
  production.key          ← Decryption key (gitignored, keep secret!)
  production.yml.enc      ← Encrypted secrets (safe to commit)
  README.md              ← This file
```

## Key Concepts

### Two Types of Keys - Don't Confuse Them!

**1. Master Keys (`.key` files)** - Different per environment
- Purpose: Decrypt the credentials files
- Location: `config/credentials/[environment].key`
- Storage: Local file + password manager + deployment env vars
- Can rotate: Yes (recreate credentials file)

**2. Active Record Encryption Keys** - Same across all environments
- Purpose: Encrypt database fields (e.g., `User.database_password`)
- Location: Inside each credentials file
- Storage: Inside the encrypted credentials
- Can rotate: NO! (would lose all encrypted data)

### What Goes in Credentials vs Environment Variables

**✅ In Credentials (Encrypted):**
- API keys (Stripe, AWS, SendGrid, etc.)
- OAuth secrets
- Service credentials
- Active Record encryption keys
- secret_key_base

**✅ In Environment Variables (Plain text):**
- `RAILS_ENV` (development, production)
- `RAILS_MASTER_KEY` (the master key itself)
- Database URLs (or in credentials)
- Non-sensitive configuration

## Common Tasks

### View Credentials (Read-only)
```bash
# Development
EDITOR="cat" bin/rails credentials:show --environment development

# Production
EDITOR="cat" bin/rails credentials:show --environment production
```

### Edit Credentials
```bash
# Development
bin/rails credentials:edit --environment development

# Production  
bin/rails credentials:edit --environment production
```

### Access in Code
```ruby
# Get a value
Rails.application.credentials.stripe[:secret_key]

# Nested value
Rails.application.credentials.dig(:aws, :access_key_id)

# Active Record encryption keys (used automatically)
Rails.application.credentials.active_record_encryption[:primary_key]
```

## Setup for New Developers

### 1. Get the Master Keys
Ask a team member for:
- `development.key` - Store at `config/credentials/development.key`
- `production.key` - Store at `config/credentials/production.key`

**Store these in your password manager immediately!**

### 2. Verify Access
```bash
# Should show decrypted content
EDITOR="cat" bin/rails credentials:show --environment development
```

### 3. Optional: Configure Git Diff
To see decrypted diffs in terminal:
```bash
git config diff.rails_credentials.textconv "bin/rails credentials:show --environment"
```

## Updating Credentials

### Workflow
1. **Edit locally:**
   ```bash
   bin/rails credentials:edit --environment production
   # Make your changes, save, and close editor
   ```

2. **Verify the change:**
   ```bash
   EDITOR="cat" bin/rails credentials:show --environment production
   ```

3. **Commit the encrypted file:**
   ```bash
   git add config/credentials/production.yml.enc
   git commit -m "Add Stripe API keys"
   git push
   ```

4. **Create PR with description:**
   ```markdown
   ## Credentials Changes
   - Added: `stripe.secret_key` for payment processing
   - Updated: `aws.s3_bucket` to new bucket name
   ```

5. **Deploy:**
   - Server pulls updated `.yml.enc` from Git
   - Uses existing `RAILS_MASTER_KEY` env var to decrypt
   - No manual server changes needed!

## Deployment Setup

### DigitalOcean Environment Variables

**Development/Staging:**
- Not needed (uses local `.key` files)

**Production:**
```bash
RAILS_ENV=production
RAILS_MASTER_KEY=<value from config/credentials/production.key>
```

That's it! Only one environment variable needed.

## Critical Security Rules

### ✅ DO:
- ✅ Commit `.yml.enc` files (encrypted, safe)
- ✅ Store `.key` files in password manager
- ✅ Use same Active Record encryption keys everywhere
- ✅ Use different master keys per environment
- ✅ Document changes in PR descriptions

### ❌ DON'T:
- ❌ Commit `.key` files (gitignored)
- ❌ Share `.key` files in Slack/email
- ❌ Change Active Record encryption keys (data loss!)
- ❌ Use same master key across environments
- ❌ Store credentials in regular environment variables

## Backup Strategy

### Master Keys (Can be regenerated)
- Store in 1Password/LastPass team vault
- Document who has access

### Active Record Encryption Keys (CANNOT be regenerated)
- **CRITICAL:** Losing these = permanent data loss!
- Store in multiple secure locations:
  - Team password manager
  - Secure company safe/vault
  - Encrypted backup drive
- **Never change these keys!**

## Troubleshooting

### "ActiveSupport::MessageEncryptor::InvalidMessage"
**Cause:** Wrong `RAILS_MASTER_KEY` or missing key

**Fix:**
```bash
# Verify you have the right key
cat config/credentials/production.key

# Update deployment env var to match
RAILS_MASTER_KEY=<correct value>
```

### Can't decrypt credentials locally
**Cause:** Missing `.key` file

**Fix:**
```bash
# Get the key from a team member
# Save to the right location
echo "your-key-here" > config/credentials/development.key
chmod 600 config/credentials/development.key
```

### Lost encryption keys
**Impact:** Can't decrypt `User.database_password` - permanent data loss

**Prevention:** Keep multiple secure backups!

## Reference

### File Contents Example

```yaml
# config/credentials/production.yml.enc (encrypted)
# When decrypted, contains:

# ⚠️ CRITICAL: Never change these! Used for database field encryption
active_record_encryption:
  primary_key: NI4XwvoxJ4sj37sxw5W09zLa7ceb603R
  deterministic_key: WmGIYbV3FAmx1JHHAPUst7YSmZh2SAX6
  key_derivation_salt: obx2ibc2NpYEhE6GQWk58mu7rOaE0Kme

# Used for session cookies, CSRF tokens (unique per environment)
secret_key_base: bf31ff7600f4d141d3607622dc425248...

# Your application secrets
# to be added
```
