# ELI MVP — Quick Start (5 minutes)

## 1. Create Supabase Project

- Go to https://supabase.com
- Click "New Project"
- Name it "eli-dev"
- Choose a region
- Wait for database to be ready

## 2. Get Your Keys

In Supabase dashboard:
- Go to **Settings → API**
- Copy `Project URL`
- Copy `anon public key` (labeled as "ANON_KEY")
- Copy `service_role key` (under "SERVICE_ROLE_KEY")

## 3. Configure Environment

```bash
cd eli

# Edit .env.local
NEXT_PUBLIC_SUPABASE_URL=<paste your project URL>
NEXT_PUBLIC_SUPABASE_ANON_KEY=<paste your anon key>
SUPABASE_SERVICE_ROLE_KEY=<paste your service role key>
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

## 4. Create Database Schema

In Supabase:
1. Go to **SQL Editor**
2. Click **New Query**
3. Copy entire contents of `migrations/001_initial_schema.sql`
4. Paste into editor
5. Click **Execute**
6. Wait for "Success"

## 5. Run Locally

```bash
npm run dev
```

Open http://localhost:3000

## 6. Test Sign-up

1. Click "Sign Up"
2. Choose role: "Teacher"
3. Enter email: `teacher@test.com`
4. Enter password: `test1234`
5. Enter name: `Test Teacher`
6. Click "Sign Up"
7. You should see Teacher Dashboard

## 7. Test Student

Repeat step 6 but choose role: "Student"

## Done! ✅

You now have:
- ✅ Running Next.js app
- ✅ Supabase authentication
- ✅ PostgreSQL database
- ✅ Teacher and student dashboards
- ✅ Role-based access control

## Next

Read **SETUP.md** for:
- Deployment to Vercel
- Production Supabase setup
- Environment configuration

Read **SPRINT_1_COMPLETE.md** for:
- Full feature list
- Architecture decisions
- What's next in Sprint 2

Read **PRD** for:
- Full requirements
- Detailed features per sprint
- Build roadmap

---

**That's it! You're ready to start Sprint 2 (Lesson Compiler).**
