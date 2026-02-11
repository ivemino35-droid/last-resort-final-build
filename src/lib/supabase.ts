import { createClient, SupabaseClient, User as SupabaseUser } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    'Missing Supabase environment variables. Please check your .env file.'
  )
}

export const supabase: SupabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
    storage: typeof window !== 'undefined' ? window.localStorage : undefined,
  },
  db: {
    schema: 'public',
  },
  global: {
    headers: {
      'X-Client-Info': 'ubuntu-pools-web@1.0.0',
    },
  },
})

// Helper function to handle Supabase errors
export const handleSupabaseError = (error: any): string => {
  if (error?.message) {
    return error.message
  }
  if (error?.error_description) {
    return error.error_description
  }
  return 'An unexpected error occurred'
}

// Helper function to check if Supabase is configured
export const isSupabaseConfigured = (): boolean => {
  return Boolean(supabaseUrl && supabaseAnonKey)
}

// Export types
export type { SupabaseClient, SupabaseUser }
