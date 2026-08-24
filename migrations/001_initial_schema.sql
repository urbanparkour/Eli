-- ============================================================================
-- ELI MVP Database Schema v1.0
-- ============================================================================

-- Enable UUID and JSONB extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgvector";

-- ============================================================================
-- 1. USERS & AUTHENTICATION
-- ============================================================================

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  display_name TEXT,
  role TEXT NOT NULL CHECK (role IN ('admin', 'teacher', 'student')),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- ============================================================================
-- 2. TEACHER PROFILES
-- ============================================================================

CREATE TABLE IF NOT EXISTS teacher_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  bio TEXT,
  school TEXT,
  specialization TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_teacher_profiles_user_id ON teacher_profiles(user_id);

-- ============================================================================
-- 3. STUDENT PROFILES
-- ============================================================================

CREATE TABLE IF NOT EXISTS student_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  cefr_level TEXT NOT NULL DEFAULT 'A1' CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_student_profiles_user_id ON student_profiles(user_id);

-- ============================================================================
-- 4. CLASSES (Teacher-managed classes)
-- ============================================================================

CREATE TABLE IF NOT EXISTS classes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  teacher_id UUID NOT NULL REFERENCES teacher_profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  level TEXT NOT NULL CHECK (level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  description TEXT,
  max_students INT DEFAULT 30,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_classes_teacher_id ON classes(teacher_id);

-- ============================================================================
-- 5. CLASS MEMBERS (Students enrolled in classes)
-- ============================================================================

CREATE TABLE IF NOT EXISTS class_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
  enrolled_at TIMESTAMP DEFAULT now(),
  UNIQUE(class_id, student_id)
);

CREATE INDEX idx_class_members_class_id ON class_members(class_id);
CREATE INDEX idx_class_members_student_id ON class_members(student_id);

-- ============================================================================
-- 6. LESSONS (Teacher-created lessons from PDFs)
-- ============================================================================

CREATE TABLE IF NOT EXISTS lessons (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  teacher_id UUID NOT NULL REFERENCES teacher_profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  source_pdf_url TEXT,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'review', 'published', 'archived')),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_lessons_teacher_id ON lessons(teacher_id);
CREATE INDEX idx_lessons_status ON lessons(status);

-- ============================================================================
-- 7. LESSON PACKAGES (Structured lesson data from AI)
-- ============================================================================

CREATE TABLE IF NOT EXISTS lesson_packages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lesson_id UUID NOT NULL UNIQUE REFERENCES lessons(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  cefr_level TEXT NOT NULL CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  objectives JSONB DEFAULT '[]'::jsonb,
  skills JSONB DEFAULT '[]'::jsonb,
  vocabulary JSONB DEFAULT '[]'::jsonb,
  grammar JSONB DEFAULT '[]'::jsonb,
  ai_context JSONB DEFAULT '{}'::jsonb,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_lesson_packages_lesson_id ON lesson_packages(lesson_id);
CREATE INDEX idx_lesson_packages_cefr_level ON lesson_packages(cefr_level);

-- ============================================================================
-- 8. SKILLS (Vocabulary, grammar, speaking skills)
-- ============================================================================

CREATE TABLE IF NOT EXISTS skills (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  category TEXT NOT NULL CHECK (category IN ('vocabulary', 'grammar', 'reading', 'listening', 'speaking', 'pronunciation')),
  description TEXT,
  cefr_level TEXT CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_skills_category ON skills(category);
CREATE INDEX idx_skills_name ON skills(name);

-- ============================================================================
-- 9. ACTIVITIES (Quiz, sentence practice, roleplay, etc.)
-- ============================================================================

CREATE TABLE IF NOT EXISTS activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('quiz', 'sentence_practice', 'roleplay', 'character_chat', 'speaking')),
  title TEXT,
  instructions TEXT,
  content JSONB NOT NULL DEFAULT '{}'::jsonb,
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
  assessment_config JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_activities_lesson_id ON activities(lesson_id);
CREATE INDEX idx_activities_type ON activities(type);

-- ============================================================================
-- 10. ACTIVITY SKILLS (Many-to-many: activities target specific skills)
-- ============================================================================

CREATE TABLE IF NOT EXISTS activity_skills (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
  skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  weight FLOAT DEFAULT 1.0,
  UNIQUE(activity_id, skill_id)
);

CREATE INDEX idx_activity_skills_activity_id ON activity_skills(activity_id);
CREATE INDEX idx_activity_skills_skill_id ON activity_skills(skill_id);

-- ============================================================================
-- 11. ASSIGNMENTS (Teacher assigns lesson to class)
-- ============================================================================

CREATE TABLE IF NOT EXISTS assignments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  assigned_at TIMESTAMP DEFAULT now(),
  due_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT now(),
  UNIQUE(lesson_id, class_id)
);

CREATE INDEX idx_assignments_lesson_id ON assignments(lesson_id);
CREATE INDEX idx_assignments_class_id ON assignments(class_id);

-- ============================================================================
-- 12. LEARNING RECORDS (Individual student responses during activities)
-- ============================================================================

CREATE TABLE IF NOT EXISTS learning_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  learner_id UUID NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
  skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  activity_type TEXT NOT NULL,
  expected_output TEXT,
  actual_output TEXT,
  score FLOAT NOT NULL CHECK (score >= 0 AND score <= 1),
  error_type TEXT,
  confidence FLOAT CHECK (confidence >= 0 AND confidence <= 1),
  duration_ms INT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_learning_records_learner_id ON learning_records(learner_id);
CREATE INDEX idx_learning_records_skill_id ON learning_records(skill_id);
CREATE INDEX idx_learning_records_activity_id ON learning_records(activity_id);
CREATE INDEX idx_learning_records_lesson_id ON learning_records(lesson_id);
CREATE INDEX idx_learning_records_created_at ON learning_records(created_at);

-- ============================================================================
-- 13. LEARNER SKILLS (Student's mastery per skill)
-- ============================================================================

CREATE TABLE IF NOT EXISTS learner_skills (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  learner_id UUID NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
  skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  mastery_score FLOAT NOT NULL DEFAULT 0.20 CHECK (mastery_score >= 0 AND mastery_score <= 1),
  mastery_state TEXT NOT NULL DEFAULT 'introduced' CHECK (mastery_state IN ('introduced', 'developing', 'practicing', 'proficient', 'mastered')),
  evidence_count INT DEFAULT 0,
  last_assessed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  UNIQUE(learner_id, skill_id)
);

CREATE INDEX idx_learner_skills_learner_id ON learner_skills(learner_id);
CREATE INDEX idx_learner_skills_skill_id ON learner_skills(skill_id);
CREATE INDEX idx_learner_skills_mastery_state ON learner_skills(mastery_state);

-- ============================================================================
-- 14. ROW-LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE learner_skills ENABLE ROW LEVEL SECURITY;

-- Teachers can view/update their own profile and classes
CREATE POLICY "Teachers view own profile"
  ON teacher_profiles FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Teachers update own profile"
  ON teacher_profiles FOR UPDATE
  USING (user_id = auth.uid());

-- Students can view/update their own profile
CREATE POLICY "Students view own profile"
  ON student_profiles FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Students update own profile"
  ON student_profiles FOR UPDATE
  USING (user_id = auth.uid());

-- Teachers can access their own classes
CREATE POLICY "Teachers access own classes"
  ON classes FOR SELECT
  USING (teacher_id IN (SELECT id FROM teacher_profiles WHERE user_id = auth.uid()));

-- Students can view classes they're enrolled in
CREATE POLICY "Students view enrolled classes"
  ON classes FOR SELECT
  USING (id IN (
    SELECT class_id FROM class_members
    WHERE student_id IN (SELECT id FROM student_profiles WHERE user_id = auth.uid())
  ));

-- Teachers see their own lessons
CREATE POLICY "Teachers access own lessons"
  ON lessons FOR SELECT
  USING (teacher_id IN (SELECT id FROM teacher_profiles WHERE user_id = auth.uid()));

-- Skills are readable by all authenticated users
CREATE POLICY "Skills readable by all"
  ON skills FOR SELECT
  USING (auth.role() = 'authenticated');

-- Students can only see their own learning records
CREATE POLICY "Students view own learning records"
  ON learning_records FOR SELECT
  USING (learner_id IN (SELECT id FROM student_profiles WHERE user_id = auth.uid()));

-- Students can only see their own learner skills
CREATE POLICY "Students view own learner skills"
  ON learner_skills FOR SELECT
  USING (learner_id IN (SELECT id FROM student_profiles WHERE user_id = auth.uid()));

-- ============================================================================
-- 15. HELPER FUNCTIONS
-- ============================================================================

-- Function to update mastery_state based on mastery_score
CREATE OR REPLACE FUNCTION update_mastery_state()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.mastery_score >= 0.90 THEN
    NEW.mastery_state := 'mastered';
  ELSIF NEW.mastery_score >= 0.80 THEN
    NEW.mastery_state := 'proficient';
  ELSIF NEW.mastery_score >= 0.60 THEN
    NEW.mastery_state := 'practicing';
  ELSIF NEW.mastery_score >= 0.40 THEN
    NEW.mastery_state := 'developing';
  ELSE
    NEW.mastery_state := 'introduced';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update mastery_state
CREATE TRIGGER trigger_update_mastery_state
  BEFORE INSERT OR UPDATE ON learner_skills
  FOR EACH ROW
  EXECUTE FUNCTION update_mastery_state();

-- Function to calculate mastery score (weighted moving average)
-- new_mastery = (old_mastery × 0.70) + (current_score × 0.30)
CREATE OR REPLACE FUNCTION update_learner_skill_from_record(
  p_learner_id UUID,
  p_skill_id UUID,
  p_current_score FLOAT
)
RETURNS void AS $$
DECLARE
  v_old_mastery FLOAT;
  v_new_mastery FLOAT;
BEGIN
  -- Get current mastery or default to 0.20 if new
  SELECT COALESCE(mastery_score, 0.20) INTO v_old_mastery
  FROM learner_skills
  WHERE learner_id = p_learner_id AND skill_id = p_skill_id;

  -- Calculate new mastery using weighted moving average
  v_new_mastery := (v_old_mastery * 0.70) + (p_current_score * 0.30);

  -- Upsert the learner_skill
  INSERT INTO learner_skills (learner_id, skill_id, mastery_score, evidence_count, last_assessed_at)
  VALUES (p_learner_id, p_skill_id, v_new_mastery, 1, now())
  ON CONFLICT (learner_id, skill_id)
  DO UPDATE SET
    mastery_score = v_new_mastery,
    evidence_count = evidence_count + 1,
    last_assessed_at = now(),
    updated_at = now();
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
