import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react'
import { User as SupabaseUser, AuthError } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'
import type { User, TrustScore } from '@/types'

interface AuthContextType {
  user: User | null
  supabaseUser: SupabaseUser | null
  isLoading: boolean
  isAuthenticated: boolean
  signIn: (email: string, password: string) => Promise<void>
  signUp: (email: string, password: string, name: string) => Promise<void>
  signOut: () => Promise<void>
  updateProfile: (data: Partial<User>) => Promise<void>
  resetPassword: (email: string) => Promise<void>
}

const AuthContext = createContext<AuthContextType | null>(null)

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null)
  const [supabaseUser, setSupabaseUser] = useState<SupabaseUser | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    // Check active session
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session?.user) {
        setSupabaseUser(session.user)
        fetchUserProfile(session.user.id)
      } else {
        setIsLoading(false)
      }
    })

    // Listen for auth changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(async (event, session) => {
      console.log('Auth state changed:', event)
      
      if (event === 'SIGNED_IN' && session?.user) {
        setSupabaseUser(session.user)
        await fetchUserProfile(session.user.id)
      } else if (event === 'SIGNED_OUT') {
        setUser(null)
        setSupabaseUser(null)
      } else if (event === 'TOKEN_REFRESHED') {
        console.log('Token refreshed')
      }
    })

    return () => {
      subscription.unsubscribe()
    }
  }, [])

  const fetchUserProfile = async (userId: string) => {
    try {
      const { data, error } = await supabase
        .from('users')
        .select(`
          *,
          trust_score:trust_metrics(*)
        `)
        .eq('id', userId)
        .single()

      if (error) throw error

      // Transform the data to match User interface
      const userData: User = {
        ...data,
        trust_score: data.trust_score?.[0] || {
          score: 500,
          rating: 'fair' as const,
          metrics: {
            on_time_payment_rate: 0,
            years_active: 0,
            pools_completed: 0,
            defaults_count: 0,
          },
          updated_at: new Date().toISOString(),
        },
      }

      setUser(userData)
    } catch (error) {
      console.error('Error fetching user profile:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const signIn = async (email: string, password: string) => {
    try {
      setIsLoading(true)
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (error) throw error

      if (data.user) {
        setSupabaseUser(data.user)
        await fetchUserProfile(data.user.id)
        
        // Update last login
        await supabase
          .from('users')
          .update({ last_login_at: new Date().toISOString() })
          .eq('id', data.user.id)
      }
    } catch (error) {
      const authError = error as AuthError
      throw new Error(authError.message || 'Failed to sign in')
    } finally {
      setIsLoading(false)
    }
  }

  const signUp = async (email: string, password: string, name: string) => {
    try {
      setIsLoading(true)
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            name,
          },
        },
      })

      if (error) throw error

      if (data.user) {
        // Create user profile
        const { error: profileError } = await supabase.from('users').insert({
          id: data.user.id,
          email: data.user.email!,
          name,
          wallet_balance: 0,
          total_savings: 0,
        })

        if (profileError) throw profileError

        // Create initial trust metrics
        const { error: trustError } = await supabase.from('trust_metrics').insert({
          user_id: data.user.id,
          score: 500,
          rating: 'fair',
          on_time_payment_rate: 0,
          years_active: 0,
          pools_completed: 0,
          defaults_count: 0,
        })

        if (trustError) throw trustError

        setSupabaseUser(data.user)
        await fetchUserProfile(data.user.id)
      }
    } catch (error) {
      const authError = error as AuthError
      throw new Error(authError.message || 'Failed to sign up')
    } finally {
      setIsLoading(false)
    }
  }

  const signOut = async () => {
    try {
      const { error } = await supabase.auth.signOut()
      if (error) throw error
      setUser(null)
      setSupabaseUser(null)
    } catch (error) {
      const authError = error as AuthError
      throw new Error(authError.message || 'Failed to sign out')
    }
  }

  const updateProfile = async (data: Partial<User>) => {
    if (!user) {
      throw new Error('No user logged in')
    }

    try {
      const { error } = await supabase
        .from('users')
        .update(data)
        .eq('id', user.id)

      if (error) throw error

      setUser({ ...user, ...data })
    } catch (error) {
      throw new Error('Failed to update profile')
    }
  }

  const resetPassword = async (email: string) => {
    try {
      const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/reset-password`,
      })

      if (error) throw error
    } catch (error) {
      const authError = error as AuthError
      throw new Error(authError.message || 'Failed to send reset email')
    }
  }

  const value = {
    user,
    supabaseUser,
    isLoading,
    isAuthenticated: !!user,
    signIn,
    signUp,
    signOut,
    updateProfile,
    resetPassword,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}
