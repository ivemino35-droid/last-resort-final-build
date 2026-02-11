/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#2D302E',
          light: '#3D403E',
          dark: '#1D201E',
        },
        accent: {
          DEFAULT: '#8CA082',
          light: '#A5B89A',
          dark: '#73876A',
        },
        'accent-secondary': {
          DEFAULT: '#D6CFC7',
          light: '#E6DFD7',
          dark: '#C6BFB7',
        },
        'ubuntu-gold': {
          DEFAULT: '#D4AF37',
          light: '#E4BF47',
          dark: '#C49F27',
        },
        background: '#FDFCFB',
        surface: '#FFFFFF',
        border: '#F1F0EE',
        text: {
          main: '#2D302E',
          muted: '#6B706C',
          light: '#9EA39F',
        },
        status: {
          healthy: '#7C9082',
          warning: '#C2A878',
          critical: '#B36A5E',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
      },
      boxShadow: {
        'soft': '0 2px 8px rgba(45, 48, 46, 0.06)',
        'medium': '0 4px 16px rgba(45, 48, 46, 0.08)',
        'hard': '0 8px 32px rgba(45, 48, 46, 0.12)',
      },
      borderRadius: {
        'DEFAULT': '0.5rem',
        'lg': '0.75rem',
        'xl': '1rem',
      },
    },
  },
  plugins: [],
}
