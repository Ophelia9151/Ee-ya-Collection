import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_KEY

export const supabase = createClient(supabaseUrl, supabaseKey)

// Auth
export async function signUp(email, password) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
  })
  return { data, error }
}

export async function signIn(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })
  return { data, error }
}

export async function signOut() {
  return await supabase.auth.signOut()
}

export async function getCurrentUser() {
  const { data: { user } } = await supabase.auth.getUser()
  return user
}

// Baby Profiles (多用戶)
export async function createBabyProfile(name, dob, userId) {
  const { data, error } = await supabase
    .from('baby_profiles')
    .insert([{ name, dob, user_id: userId }])
    .select()
  return { data, error }
}

export async function getBabyProfiles(userId) {
  const { data, error } = await supabase
    .from('baby_profiles')
    .select('*')
    .eq('user_id', userId)
  return { data, error }
}

// Words (詞彙備份)
export async function saveWord(babyId, word, cat, sound, date, note, retro) {
  const { data, error } = await supabase
    .from('words')
    .insert([{
      baby_id: babyId,
      word,
      cat,
      sound,
      date,
      note,
      retro,
    }])
    .select()
  return { data, error }
}

export async function getWords(babyId) {
  const { data, error } = await supabase
    .from('words')
    .select('*')
    .eq('baby_id', babyId)
    .order('date', { ascending: false })
  return { data, error }
}

export async function deleteWord(wordId) {
  const { data, error } = await supabase
    .from('words')
    .delete()
    .eq('id', wordId)
  return { data, error }
}

export async function updateWord(wordId, updates) {
  const { data, error } = await supabase
    .from('words')
    .update(updates)
    .eq('id', wordId)
    .select()
  return { data, error }
}

// Sync
export async function syncLocalToCloud(babyId, words) {
  const { data, error } = await supabase
    .from('words')
    .upsert(words.map(w => ({
      ...w,
      baby_id: babyId,
    })), { onConflict: 'id' })
  return { data, error }
}
