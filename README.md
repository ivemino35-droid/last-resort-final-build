# 🌍 Ubuntu Pools - Production Ready

> Community-powered pooling platform with AI governance

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.6-blue)](https://www.typescriptlang.org/)
[![React](https://img.shields.io/badge/React-18.3-blue)](https://reactjs.org/)
[![Supabase](https://img.shields.io/badge/Supabase-2.45-green)](https://supabase.com/)

## ✨ Features

- 🤖 **AI-Powered Governance** - Generate fair constitutions using Google Gemini AI
- 💰 **Multiple Pool Types** - Stokvel, Savings, Investment, Rotating, and more
- 🗳️ **Democratic Voting** - Propose and vote on pool decisions
- 📊 **Transaction Tracking** - Complete transparency with detailed history
- 👥 **Member Management** - Role-based access (Admin, Member, Viewer)
- 🏆 **Trust Scoring** - Reputation system based on payment history
- 📱 **Responsive Design** - Works on desktop, tablet, and mobile
- 🔒 **Enterprise Security** - Production-grade security implementation
- ⚡ **High Performance** - Optimized with Vite and code splitting

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ 
- npm or yarn
- [Google Gemini API key](https://aistudio.google.com/app/apikey)
- [Supabase account](https://supabase.com)

### Installation

1. **Clone and navigate:**
```bash
git clone <your-repo-url>
cd ubuntu-pools-production
```

2. **Install dependencies:**
```bash
npm install
```

3. **Set up environment variables:**
```bash
cp .env.example .env.local
```

Edit `.env.local` and add:
```env
VITE_GEMINI_API_KEY=your_gemini_api_key
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. **Set up database:**
- Create a new project in Supabase
- Run the SQL in `database/schema.sql` via Supabase SQL Editor

5. **Start development server:**
```bash
npm run dev
```

Visit http://localhost:5173

## 📦 Tech Stack

### Core
- **React 18.3** - UI framework
- **TypeScript 5.6** - Type safety
- **Vite 5.4** - Build tool
- **Tailwind CSS 3.4** - Styling

### Backend & Services
- **Supabase** - Database, Authentication, Real-time
- **PostgreSQL** - Database
- **Google Gemini Pro** - AI constitution generation

### State & Forms
- **React Router 6** - Routing
- **React Hook Form** - Form handling
- **Zod** - Schema validation

### UI & Charts
- **Recharts** - Data visualization
- **Lucide React** - Icons
- **date-fns** - Date formatting

### Development
- **Vitest** - Unit testing
- **ESLint** - Code linting
- **Prettier** - Code formatting

## 🏗️ Project Structure

```
ubuntu-pools-production/
├── src/
│   ├── components/        # Reusable React components
│   ├── pages/            # Page components
│   ├── contexts/         # React contexts (Auth, etc.)
│   ├── hooks/            # Custom React hooks
│   ├── lib/              # Core libraries
│   │   ├── supabase.ts  # Supabase client
│   │   └── gemini.ts    # Gemini AI client
│   ├── services/         # Business logic
│   ├── types/            # TypeScript definitions
│   ├── utils/            # Utility functions
│   ├── App.tsx           # Main app component
│   └── main.tsx          # App entry point
├── database/
│   └── schema.sql        # PostgreSQL schema
├── netlify/
│   └── functions/        # Serverless functions
├── public/               # Static assets
├── .env.example          # Environment template
├── netlify.toml          # Netlify configuration
├── package.json          # Dependencies
├── tsconfig.json         # TypeScript config
├── tailwind.config.js    # Tailwind config
└── vite.config.ts        # Vite config
```

## 🔐 Security Features

- ✅ Row Level Security (RLS) on all tables
- ✅ Comprehensive CSP headers
- ✅ XSS protection
- ✅ CSRF protection
- ✅ Input validation with Zod
- ✅ Secure authentication flow
- ✅ JWT token-based sessions
- ✅ Rate limiting on AI requests

## 📊 Database Schema

### Core Tables
- `users` - User accounts
- `trust_metrics` - Trust scoring
- `pools` - Pool information
- `pool_members` - Membership
- `transactions` - Financial records
- `pool_constitutions` - Governance docs
- `proposals` - Democratic proposals
- `votes` - Proposal voting

### Features
- Auto-updating trust scores
- Trigger-based pool value calculations
- Automatic member count updates
- Real-time vote tallying

## 🚀 Deployment

### Deploy to Netlify

[![Deploy to Netlify](https://www.netlify.com/img/deploy/button.svg)](https://app.netlify.com/start/deploy)

1. Click the button above
2. Connect your repository
3. Add environment variables:
   - `VITE_GEMINI_API_KEY`
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
4. Deploy!

### Manual Deployment

```bash
# Build production bundle
npm run build

# Deploy dist/ folder to your hosting provider
```

## 🧪 Testing

```bash
# Run unit tests
npm test

# Run tests with UI
npm run test:ui

# Type check
npm run type-check

# Lint code
npm run lint
```

## 📝 Development Scripts

```bash
npm run dev          # Start dev server
npm run build        # Build for production
npm run preview      # Preview production build
npm run lint         # Lint code
npm run format       # Format code with Prettier
npm run type-check   # TypeScript type checking
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Google Gemini AI](https://ai.google.dev/)
- Powered by [Supabase](https://supabase.com/)
- Inspired by Ubuntu philosophy: "I am because we are"
- South African Stokvel Act of 1990

## 📞 Support

- 📧 Email: support@ubuntupools.com
- 💬 Discord: [Join our community](https://discord.gg/ubuntupools)
- 🐦 Twitter: [@UbuntuPools](https://twitter.com/ubuntupools)
- 📖 Documentation: [docs.ubuntupools.com](https://docs.ubuntupools.com)

## 🗺️ Roadmap

- [x] Core infrastructure
- [x] Database schema
- [x] Authentication
- [x] Pool creation
- [ ] AI constitution generation
- [ ] Payment integration
- [ ] Mobile apps (iOS/Android)
- [ ] Multi-currency support
- [ ] Advanced analytics
- [ ] API for third-party integrations

---

**Made with ❤️ by the Ubuntu Pools community**

_Empowering communities through collective prosperity_
