import { createServerSupabaseClient } from '@/lib/supabase/server';

export async function getCurrentUser() {
  const supabase = await createServerSupabaseClient();
  const { data: { user }, error } = await supabase.auth.getUser();
  return { user, error };
}

export async function getUserRole() {
  const { user, error } = await getCurrentUser();

  if (error || !user) {
    return null;
  }

  const supabase = await createServerSupabaseClient();
  const { data, error: queryError } = await supabase
    .from('users')
    .select('role')
    .eq('id', user.id)
    .single();

  if (queryError) {
    return null;
  }

  return data?.role;
}

export async function getTeacherProfile() {
  const { user } = await getCurrentUser();

  if (!user) {
    return null;
  }

  const supabase = await createServerSupabaseClient();
  const { data, error } = await supabase
    .from('teacher_profiles')
    .select('*')
    .eq('user_id', user.id)
    .single();

  if (error) {
    return null;
  }

  return data;
}

export async function getStudentProfile() {
  const { user } = await getCurrentUser();

  if (!user) {
    return null;
  }

  const supabase = await createServerSupabaseClient();
  const { data, error } = await supabase
    .from('student_profiles')
    .select('*')
    .eq('user_id', user.id)
    .single();

  if (error) {
    return null;
  }

  return data;
}
