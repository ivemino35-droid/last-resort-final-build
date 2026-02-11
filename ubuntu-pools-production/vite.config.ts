import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@pages': path.resolve(__dirname, './src/pages'),
      '@lib': path.resolve(__dirname, './src/lib'),
      '@types': path.resolve(__dirname, './src/types'),
      '@hooks': path.resolve(__dirname, './src/hooks'),
      '@utils': path.resolve(__dirname, './src/utils'),
      '@contexts': path.resolve(__dirname, './src/contexts'),
      '@services': path.resolve(__dirname, './src/services'),
    },
  },
  server: {
    port: 5173,
    host: true,
    open: false,
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom'],
          'router': ['react-router-dom'],
          'ai': ['@google/generative-ai'],
          'db': ['@supabase/supabase-js'],
          'charts': ['recharts'],
          'forms': ['react-hook-form', '@hookform/resolvers', 'zod'],
        },
      },
    },
    chunkSizeWarningLimit: 1000,
  },
  optimizeDeps: {
    include: [
      'react',
      'react-dom',
      'react-router-dom',
      '@google/generative-ai',
      '@supabase/supabase-js',
      'recharts',
      'date-fns',
    ],
  },
})
