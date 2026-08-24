# ELI MVP Setup Guide

This guide walks you through setting up the ELI MVP locally and deploying it to production.

## Prerequisites

- Node.js 18+ and npm
- Supabase account (https://supabase.com)
- Vercel account (https://vercel.com)
- Git

## Local Development Setup

### 1. Clone and Install

```bash
git clone <your-repo>
cd eli
npm install
```

### 2. Create Supabase Project

1. Go to https://supabase.com and create a new project
2. Wait for the database to be provisioned
3. Navigate to Project Settings → API
4. Copy your project URL and API keys

### 3. Configure Environment Variables

Copy `.env.example` to `.env.local` and fill in your Supabase credentials:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### 4. Create Database Schema

1. Go to your Supabase project → SQL Editor
2. Create a new query
3. Copy the entire contents of `migrations/001_initial_schema.sql`
4. Paste into the query editor and execute

### 5. Enable Authentication

In Supabase:

1. Go to Authentication → Providers
2. Enable Email provider (should be default)
3. Go to Authentication → URL Configuration
4. Add `http://localhost:3000/auth/callback` to Redirect URLs (for local development)
5. Add your production URL later for deployment

### 6. Run Development Server

```bash
npm run dev
```

Open http://localhost:3000 in your browser.

### 7. Test Authentication

- Visit http://localhost:3000/auth/signup
- Create an account as a teacher or student
- You'll be redirected to your dashboard
- Verify in Supabase → Authentication → Users that your account exists

## Project Structure

```
eli/
├── app/                          # Next.js App Router
│   ├── auth/                    # Authentication pages
│   │   ├── login/
│   │   ├── signup/
│   │   └── logout/
│   ├── teacher/                 # Teacher pages
│   │   ├── dashboard/
│   │   ├── lesson/
│   │   └── class/
│   ├── student/                 # Student pages
│   │   ├── dashboard/
│   │   └── lesson/
│   ├── layout.tsx              # Root layout
│   ├── page.tsx                # Home page
│   └── globals.css             # Global styles
├── lib/
│   ├── supabase/               # Supabase client & server utilities
│   ├── auth/                   # Authentication helpers
│   └── api/                    # API utilities
├── migrations/                 # Database migrations
└── public/                     # Static files
```

## MVP Architecture

ELI Sprint 1 includes:

- **Authentication**: Teacher and Student sign up/login
- **Database**: Complete relational schema with RLS policies
- **Dashboards**: Teacher and student interfaces
- **Role-Based Access**: Middleware enforcing teacher/student separation

## Deployment to Production

### 1. Prepare Supabase Production

Create a separate Supabase project for production or use the same with separate branch.

### 2. Deploy to Vercel

```bash
# Push to GitHub
git add .
git commit -m "ELI MVP Sprint 1"
git push origin main

# Go to https://vercel.com/new
# Connect your GitHub repository
# Add environment variables:
NEXT_PUBLIC_SUPABASE_URL=https://your-production-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-production-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-production-service-role-key
NEXT_PUBLIC_APP_URL=https://your-production-domain.vercel.app

# Deploy
```

### 3. Configure Supabase Production

1. Update Authentication → URL Configuration with your Vercel deployment URL
2. Run database migrations on production database

## Testing the MVP

### Teacher Flow

1. Sign up as a teacher
2. View teacher dashboard (shows classes, lessons, assignments)
3. Create a new lesson (redirects to lesson builder - Sprint 2)

### Student Flow

1. Sign up as a student
2. View student dashboard (shows assigned lessons and skill progress)
3. Click on a lesson to start learning (Sprint 3)

## Next Steps

See the PRD for detailed Sprint 2-6 requirements:

- **Sprint 2**: Lesson Compiler (PDF → LessonPackage)
- **Sprint 3**: Student Learning (Activities: quiz, practice, roleplay)
- **Sprint 4**: Learning Intelligence (Mastery Engine, Adaptation)
- **Sprint 5**: Teacher Analytics (Progress dashboards)
- **Sprint 6**: Voice Capabilities (STT, TTS, speaking)

## Troubleshooting

### "Auth error: supabaseClient is not defined"

Make sure environment variables are set in `.env.local` and the dev server is restarted after adding them.

### "Database connection error"

Check that:
1. Supabase project is active
2. Environment variables are correct
3. Database schema has been created (run migrations)

### "Redirect URL mismatch"

Update Supabase → Authentication → URL Configuration with your current URL.

## Architecture Decision

This MVP uses:

- **Next.js 14+**: App Router for file-based routing and server actions
- **TypeScript**: Type safety
- **Supabase**: Auth + PostgreSQL database
- **Tailwind CSS**: UI styling
- **Server Components**: Data fetching on the server
- **Client Components**: Interactivity (auth forms, etc.)

The pattern is:
- Server Components for protected pages (dashboard, lessons)
- Client Components for auth flows
- Server Actions for mutations (coming in Sprint 2+)
- No separate backend needed for MVP

## Security Notes

- RLS policies enforce that teachers only see their data
- Students only see their assignments and records
- All sensitive operations use server components
- API keys are never exposed to the browser
- Authentication via Supabase Auth (battle-tested)

---

**Ready to build?** Continue with Sprint 2: Lesson Compiler
