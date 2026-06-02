/// Supabase Configuration
///
/// This file contains the Supabase project URL and API keys.
/// Make sure to keep the anon key public-safe and never expose the service_role key.
class SupabaseConfig {
  // Project URL
  static const String url = 'https://zvbigvcdddkwixljjypa.supabase.co';

  // Publishable Key (safe to use in client-side code)
  // This is the new format API key from Supabase
  static const String anonKey = 'sb_publishable_BIuM2sCRvvRkB87DUUd9Jg_uQTviaNT';

  // Service Role Key (NEVER expose this in client-side code!)
  // Only use this for admin/backend operations
  // static const String serviceRoleKey = 'YOUR_SERVICE_ROLE_KEY'; // Commented out for safety

  // Region
  static const String region = 'Asia Pacific (Sydney)';
}
