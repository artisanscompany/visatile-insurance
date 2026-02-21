# Cloudflare R2 Image Proxy Guide for Rails ActiveStorage

## Table of Contents
1. [Overview](#overview)
2. [The Problem](#the-problem)
3. [Why This Happens](#why-this-happens)
4. [The Solution](#the-solution)
5. [Step-by-Step Fix](#step-by-step-fix)
6. [Testing & Verification](#testing--verification)
7. [Prevention Tips](#prevention-tips)
8. [Related Resources](#related-resources)

---

## Overview

This guide documents a common issue when using **Rails ActiveStorage** with **Cloudflare R2** (S3-compatible storage): images stored in R2 fail to display in views when referenced directly. This affects applications using external cloud storage for ActiveStorage attachments.

**Affected Setup**:
- Rails 7.x or 8.x
- ActiveStorage configured with Cloudflare R2 (or any S3-compatible storage)
- Images/files stored remotely (not local disk)

**Impact**: Images display as broken or fail to load entirely, despite being successfully uploaded and stored in R2.

---

## The Problem

### Symptoms

**What You See**:
- 🔴 Flag images, avatars, logos not displaying
- 🔴 Broken image icons in browser
- 🔴 Browser DevTools show 403 Forbidden or network errors
- 🔴 Images work fine in admin views but not public/applicants/officers views
- 🔴 Images work in development (local storage) but fail in production (R2)

**Example Broken View**:
```erb
<!-- app/views/public/countries/show.html.erb -->
<div class="country-header">
  <% if @country.flag.attached? %>
    <%= image_tag @country.flag,
        class: "w-12 h-8 rounded object-cover",
        alt: "#{@country.name} flag" %>
  <% end %>
  <h1><%= @country.name %></h1>
</div>
```

**Browser Output**:
- Image element renders: `<img src="https://account-id.r2.cloudflarestorage.com/blob/..." />`
- But image fails to load (403 Forbidden or CORS error)

### What's Happening Behind the Scenes

When you write `image_tag country.flag`, Rails tries to generate a direct URL to the blob stored in Cloudflare R2:

```
https://your-account-id.r2.cloudflarestorage.com/your-bucket/blobs/xyz123...
```

**Problem**: This URL bypasses Rails' ActiveStorage proxy, which is required to:
1. Authenticate requests
2. Handle proper routing
3. Serve files with correct headers
4. Work with external storage providers

---

## Why This Happens

### Technical Explanation

Rails ActiveStorage has two ways to serve files:

#### 1. Direct URLs (Broken with R2)
```ruby
image_tag country.flag
# Generates: https://account-id.r2.cloudflarestorage.com/bucket/blob/xyz...
# Result: ❌ 403 Forbidden (R2 bucket not publicly accessible)
```

#### 2. Proxy URLs (Works with R2)
```ruby
image_tag rails_storage_proxy_path(country.flag)
# Generates: /rails/active_storage/blobs/proxy/xyz.../flag.png
# Result: ✅ Rails serves file through ActiveStorage proxy
```

### Why Proxy is Required

**Cloudflare R2 Buckets** are typically:
- **Private** (not publicly accessible)
- **Require signed URLs** for access
- **Need authentication** to serve files

Rails' ActiveStorage proxy:
1. Receives request at `/rails/active_storage/blobs/proxy/...`
2. Looks up blob in database
3. Authenticates request
4. Generates signed URL for R2
5. Streams file to user
6. Handles caching headers

Without the proxy, the browser tries to fetch directly from R2 and gets denied.

### Why Admin Views Worked

In the original codebase, admin views already used `rails_storage_proxy_path()`:

```erb
<!-- app/views/admin/countries/index.html.erb -->
<%= image_tag rails_storage_proxy_path(country.flag), ... %>
```

This is why admins could see images while public users couldn't. The fix was to apply this same pattern across all views.

---

## The Solution

### The Fix: Use `rails_storage_proxy_path()`

**Pattern to Change**:
```erb
<!-- ❌ BROKEN: Direct attachment reference -->
<%= image_tag country.flag, class: "..." %>

<!-- ✅ FIXED: Wrapped with proxy path -->
<%= image_tag rails_storage_proxy_path(country.flag), class: "..." %>
```

### When to Use This Pattern

**Always use `rails_storage_proxy_path()` when**:
- Using external storage (Cloudflare R2, AWS S3, Google Cloud Storage)
- Serving private attachments
- Need authentication/authorization for files
- Want Rails to handle caching and headers

**You can skip it when**:
- Using local disk storage (`:local` service)
- Files are in `public/` directory (static files)
- Using direct uploads with public CDN

---

## Step-by-Step Fix

### Step 1: Identify Affected Files

Search your codebase for direct attachment references:

```bash
# Find all image_tag calls with attachments
grep -r "image_tag.*\.flag" app/views/
grep -r "image_tag.*\.avatar" app/views/
grep -r "image_tag.*\.logo" app/views/
grep -r "image_tag.*\.photo" app/views/
grep -r "image_tag.*\.image" app/views/

# Example output:
# app/views/public/countries/show.html.erb:  <%= image_tag @country.flag,
# app/views/applicants/profiles/show.html.erb:  <%= image_tag @user.avatar,
```

### Step 2: Review Each File

For each file found, check if it's using direct attachment reference:

```erb
<!-- BROKEN PATTERN -->
<%= image_tag record.attachment, ... %>
<%= image_tag @user.avatar, ... %>
<%= image_tag company.logo, ... %>
```

### Step 3: Apply the Fix

Wrap each attachment with `rails_storage_proxy_path()`:

```erb
<!-- FIXED PATTERN -->
<%= image_tag rails_storage_proxy_path(record.attachment), ... %>
<%= image_tag rails_storage_proxy_path(@user.avatar), ... %>
<%= image_tag rails_storage_proxy_path(company.logo), ... %>
```

### Step 4: Handle Conditional Rendering

When using `.attached?` checks, maintain the same pattern:

**Before**:
```erb
<% if @country.flag.attached? %>
  <%= image_tag @country.flag,
      class: "w-12 h-8",
      alt: "#{@country.name} flag" %>
<% end %>
```

**After**:
```erb
<% if @country.flag.attached? %>
  <%= image_tag rails_storage_proxy_path(@country.flag),
      class: "w-12 h-8",
      alt: "#{@country.name} flag" %>
<% end %>
```

### Step 5: Handle Collections

When iterating over records with attachments:

**Before**:
```erb
<% @countries.each do |country| %>
  <% if country.flag.attached? %>
    <%= image_tag country.flag, class: "w-6 h-4" %>
  <% end %>
<% end %>
```

**After**:
```erb
<% @countries.each do |country| %>
  <% if country.flag.attached? %>
    <%= image_tag rails_storage_proxy_path(country.flag), class: "w-6 h-4" %>
  <% end %>
<% end %>
```

### Step 6: Bulk Fix with sed (Advanced)

**⚠️ Warning**: Test this on a branch first! Always review changes before committing.

```bash
# Backup your views
cp -r app/views app/views.backup

# Apply fix to all .erb files
find app/views -name "*.erb" -type f -exec sed -i '' \
  's/image_tag \([a-z_@]*\.\(flag\|avatar\|logo\|photo\|image\)\)/image_tag rails_storage_proxy_path(\1)/g' {} +

# Review changes
git diff app/views/

# If satisfied, commit
git add app/views/
git commit -m "Fix: Wrap ActiveStorage attachments with rails_storage_proxy_path for R2 compatibility"
```

**Note**: The `sed` command above works on macOS. On Linux, remove the `''` after `-i`:
```bash
sed -i 's/...' file.erb
```

---

## Testing & Verification

### Local Testing

1. **Start Rails server**:
```bash
bin/rails server
```

2. **Visit pages with images**:
   - Navigate to pages displaying flags, avatars, logos
   - Open browser DevTools (F12) → Network tab
   - Reload page

3. **Check image URLs**:
   - Look for image requests in Network tab
   - URLs should be: `/rails/active_storage/blobs/proxy/...`
   - Status should be: `200 OK`

4. **Verify images display**:
   - Images should load correctly
   - No broken image icons
   - No CORS errors in console

### Production Testing

1. **Deploy to staging/production**:
```bash
git push origin main
# Wait for Coolify deployment
```

2. **Visit application in browser**:
```bash
open https://your-app.com/countries
```

3. **Test multiple views**:
   - Public views (visitor-facing pages)
   - Authenticated views (applicants, officers)
   - Admin views (should continue working)

4. **Check for regressions**:
   - Verify other images still work
   - Test file uploads still work
   - Check direct upload progress bars

### Automated Testing

Add system tests for image display:

```ruby
# test/system/country_images_test.rb
require "application_system_test_case"

class CountryImagesTest < ApplicationSystemTestCase
  test "displays country flag on show page" do
    country = countries(:nigeria)
    country.flag.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "flag.png")),
      filename: "flag.png",
      content_type: "image/png"
    )

    visit country_path(country)

    # Image should be present and loaded
    assert_selector "img[alt='#{country.name} flag']"

    # Image URL should go through proxy
    img = find("img[alt='#{country.name} flag']")
    assert img[:src].include?("rails/active_storage/blobs/proxy")
  end
end
```

---

## Prevention Tips

### 1. Code Review Checklist

Add this to your PR review checklist:

```markdown
- [ ] All ActiveStorage attachments use `rails_storage_proxy_path()`
- [ ] Tested image display in development
- [ ] Tested image display in staging/production
- [ ] No direct attachment references in views
```

### 2. Linter Rule

Create a custom RuboCop rule or grep hook:

```bash
# .git/hooks/pre-commit
#!/bin/bash

# Check for direct attachment references
if git diff --cached --name-only | grep -q "\.erb$"; then
  if git diff --cached | grep -E "image_tag.*\.(flag|avatar|logo|photo|image)" | grep -v "rails_storage_proxy_path"; then
    echo "⚠️  Warning: Found direct ActiveStorage attachment reference"
    echo "Use: image_tag rails_storage_proxy_path(record.attachment)"
    exit 1
  fi
fi
```

### 3. Team Documentation

Document this pattern in your team wiki/README:

```markdown
## ActiveStorage Image Display

When displaying images from Cloudflare R2, always use:

```erb
<%= image_tag rails_storage_proxy_path(record.attachment), ... %>
```

**DO NOT** use direct references:
```erb
<%= image_tag record.attachment, ... %>  # ❌ BROKEN with R2
```
```

### 4. Generator Template

Create a view generator template with the correct pattern:

```ruby
# lib/templates/erb/scaffold/show.html.erb
<% if attribute.attachment? %>
  <% if <%= singular_table_name %>.<%= attribute.column_name %>.attached? %>
    <%= image_tag rails_storage_proxy_path(<%= singular_table_name %>.<%= attribute.column_name %>),
        class: "w-32 h-32 object-cover" %>
  <% end %>
<% end %>
```

### 5. Test Coverage

Ensure system tests cover image display:

```ruby
# Include in every feature test that displays images
assert_selector "img[src*='rails/active_storage/blobs/proxy']"
```

---

## Related Resources

### Official Documentation
- [Rails ActiveStorage Overview](https://guides.rubyonrails.org/active_storage_overview.html)
- [ActiveStorage Proxy Mode](https://edgeguides.rubyonrails.org/active_storage_overview.html#proxy-mode)
- [Cloudflare R2 Documentation](https://developers.cloudflare.com/r2/)

### Related Files in This Project
- See commit `40e8e3d` for the complete fix
- [COOLIFY_DEPLOYMENT_GUIDE.md](./COOLIFY_DEPLOYMENT_GUIDE.md) - Issue 9
- [DATABASE_EXPORT_IMPORT_GUIDE.md](./DATABASE_EXPORT_IMPORT_GUIDE.md) - R2 CORS configuration

### Affected Files in Commit 40e8e3d

**20 files updated, 27 instances fixed**:

**Public Views (10 files)**:
- `app/views/public/visa_rules/show.html.erb` (2 instances)
- `app/views/public/visa_rules/_visa_odds_inline_form.html.erb` (2 instances)
- `app/views/public/countries/show.html.erb` (3 instances)
- `app/views/public/countries/_destinations_grid.html.erb` (1 instance)
- `app/views/public/countries/_destinations_carousel.html.erb` (1 instance)
- `app/views/public/relocation_routes/index.html.erb` (1 instance)
- `app/views/public/relocation_routes/show.html.erb` (1 instance)
- `app/views/public/shared/_country_list_item.html.erb` (1 instance)
- `app/views/public/shared/_visa_rule_result.html.erb` (2 instances)

**Applicants Views (5 files)**:
- `app/views/applicants/tourist_visa_applications/index.html.erb` (2 instances)
- `app/views/applicants/tourist_visa_document_generations/index.html.erb` (2 instances)
- `app/views/applicants/relocation_visa_applications/index.html.erb` (1 instance)
- `app/views/applicants/relocation_visa_applications/show.html.erb` (1 instance)
- `app/views/applicants/relocation_visa_applications/new.html.erb` (1 instance)

**Officers Views (2 files)**:
- `app/views/officers/tourist_visa_applications/index.html.erb` (1 instance)
- `app/views/officers/visa_odds_assessments/index.html.erb` (1 instance)

**Admin Views (3 files)**:
- `app/views/admin/relocation_routes/index.html.erb` (1 instance)
- `app/views/admin/visa_odds_assessments/index.html.erb` (1 instance)
- `app/views/admin/relocation_visa_applications/index.html.erb` (1 instance)
- `app/views/admin/relocation_visa_applications/show.html.erb` (1 instance)

### Configuration References

**ActiveStorage Configuration** (`config/storage.yml`):
```yaml
cloudflare:
  service: S3
  access_key_id: <%= ENV['CLOUDFLARE_R2_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['CLOUDFLARE_R2_SECRET_ACCESS_KEY'] %>
  region: auto
  bucket: <%= ENV['CLOUDFLARE_R2_BUCKET'] %>
  endpoint: <%= ENV['CLOUDFLARE_R2_ENDPOINT'] %>
  force_path_style: true
```

**Production Environment** (`config/environments/production.rb`):
```ruby
config.active_storage.service = :cloudflare
```

---

## Troubleshooting

### Q: Images still not loading after fix

**A**: Check these items:
1. Verify `config/storage.yml` has correct R2 credentials
2. Ensure `CLOUDFLARE_R2_*` environment variables are set
3. Check R2 bucket exists and is accessible
4. Verify ActiveStorage tables exist: `active_storage_blobs`, `active_storage_attachments`
5. Test direct Rails console:
   ```ruby
   Country.first.flag.attached?
   # Should return: true

   rails_blob_path(Country.first.flag)
   # Should return: /rails/active_storage/blobs/...
   ```

### Q: Images work in development but not production

**A**: Different storage services configured:
- Development likely uses `:local` (disk storage)
- Production uses `:cloudflare` (R2 storage)

**Fix**: Test with production-like storage in development:
```ruby
# config/environments/development.rb
config.active_storage.service = :cloudflare  # Temporarily use R2
```

### Q: Getting CORS errors

**A**: Configure CORS on R2 bucket:
```json
{
  "AllowedOrigins": ["https://your-domain.com"],
  "AllowedMethods": ["GET", "PUT", "POST", "DELETE", "HEAD"],
  "AllowedHeaders": ["*"],
  "ExposeHeaders": ["ETag"],
  "MaxAgeSeconds": 3600
}
```

See [DATABASE_EXPORT_IMPORT_GUIDE.md](./DATABASE_EXPORT_IMPORT_GUIDE.md#cloudflare-r2-configuration) for CORS setup.

### Q: Can I use direct URLs instead of proxy?

**A**: Yes, but requires:
1. Making R2 bucket **public** (security risk)
2. Configuring custom domain for R2
3. Using `url_for(attachment)` instead of proxy path
4. Handling authentication separately

**Recommendation**: Stick with `rails_storage_proxy_path()` for security and simplicity.

---

## Summary

### Key Takeaways

✅ **Always use `rails_storage_proxy_path()`** for external storage (R2, S3)
✅ **Direct attachment references fail** with private cloud storage
✅ **Rails proxy handles authentication** and signed URLs automatically
✅ **Test image display** in production-like environment before deploying
✅ **Add linting/tests** to prevent regression

### Quick Reference

```erb
<!-- ❌ BROKEN -->
<%= image_tag record.attachment %>

<!-- ✅ FIXED -->
<%= image_tag rails_storage_proxy_path(record.attachment) %>
```

### One-Line Fix

```bash
# Search and replace across all views
find app/views -name "*.erb" -exec sed -i '' \
  's/image_tag \([a-z_@]*\.\(flag\|avatar\|logo\)\)/image_tag rails_storage_proxy_path(\1)/g' {} +
```

---

**Document Version**: 1.0
**Last Updated**: 2025-11-21
**Related Commit**: 40e8e3d
**Tested With**: Rails 8.0.2, Cloudflare R2
