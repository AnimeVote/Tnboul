# TunLine 2.0 — setup guide

This version keeps the TunLine dark/purple poster-grid design and replaces the sample array with Supabase data.

## Included files
- `index.html` — public site + private Admin sign-in/dashboard
- `supabase.sql` — database, Row Level Security, and poster storage policies

## 1. Create the free backend
1. Create a project at https://supabase.com/
2. Open **SQL Editor** in your Supabase project.
3. Paste all of `supabase.sql` and run it.
4. Open **Project Settings → API** (or **API Keys**) and copy:
   - Project URL
   - anon / publishable public key
5. In `index.html`, replace:
   - `YOUR_SUPABASE_PROJECT_URL`
   - `YOUR_SUPABASE_ANON_PUBLIC_KEY`

The anon/publishable key is intended for browser use. Never place a `service_role` or secret key in this HTML file.

## 2. Create your single Admin account
1. In Supabase, open **Authentication → Providers → Email**.
2. Keep public sign-ups disabled. (If the dashboard has an “Allow new users to sign up” setting, turn it OFF.)
3. In **Authentication → Users**, create/invite your own user.
4. Copy your exact email address.
5. In SQL Editor, run this statement after replacing the email:

   ```sql
   update auth.users
   set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}'::jsonb
   where email = 'YOUR_ADMIN_EMAIL';
   ```

6. Sign in to TunLine using that email and password. If you were already signed in before assigning the role, sign out and sign in again so the refreshed token contains the Admin role.

Do not create or promote any other users. The database and storage policies check the role in trusted `app_metadata`; changing a browser variable cannot grant Admin access.

## 3. Test locally
Open `index.html` in a browser after adding the Supabase URL and anon key. For a reliable local test, use a simple local static server, or publish it to GitHub Pages.

## 4. Publish free with GitHub Pages
1. Create a GitHub repository, for example `tunline`.
2. Upload `index.html` to the repository root.
3. Open **Settings → Pages**.
4. Choose **Deploy from a branch**, select `main` and `/ (root)`, then Save.
5. Wait for GitHub Pages to publish the site.

Your public website URL will be shown in the Pages settings.

## How it works
- Visitors can read titles/posters and search by title.
- Only the Admin role can insert, update, or delete entries and manage poster uploads.
- Admin can upload JPG, PNG or WebP images up to 8 MB each.
- Public poster viewing is enabled so images can appear without a login.
- The sample 15 entries have been removed.

## Free-tier notes
Supabase and GitHub Pages offer free tiers, not unlimited free service. Storage, bandwidth, database size, and usage limits apply and can change. A custom domain is optional and usually costs money.

## Important
- Never share your Supabase password or service-role key.
- The public anon/publishable key in the HTML is normal; security comes from Row Level Security and Storage policies.
- Back up your data and posters periodically.
