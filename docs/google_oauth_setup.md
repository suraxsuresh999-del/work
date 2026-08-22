# Google sign-in setup

The Flutter app returns from OAuth with:

`io.supabase.worksphere://login-callback`

## Supabase

1. Open **Authentication → Providers → Google**.
2. Enable Google.
3. Paste this Google OAuth client ID:

   `542534082253-gn8qoo4jglmp3a6ltavbi5eai50tl7d7.apps.googleusercontent.com`

4. Paste the matching Google OAuth **client secret**. Keep that secret in
   Supabase only—never add it to Flutter source control.
5. In **Authentication → URL Configuration**, add this redirect URL:

   `io.supabase.worksphere://login-callback`

## Google Cloud Console

For the same OAuth web client, add this authorised redirect URI:

`https://otzyosfooxaauhzpovam.supabase.co/auth/v1/callback`

Add your production web URL as an authorised JavaScript origin only if you
later release the Flutter app for web.
