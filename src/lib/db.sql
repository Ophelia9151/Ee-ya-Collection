-- Users (from supabase.auth.users)
-- Profiles
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Baby Profiles (支援多個寶寶)
CREATE TABLE IF NOT EXISTS baby_profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  dob DATE NOT NULL,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

ALTER TABLE baby_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own babies" ON baby_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create babies" ON baby_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own babies" ON baby_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own babies" ON baby_profiles
  FOR DELETE USING (auth.uid() = user_id);

-- Words (詞彙)
CREATE TABLE IF NOT EXISTS words (
  id BIGINT PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id UUID NOT NULL REFERENCES baby_profiles(id) ON DELETE CASCADE,
  word VARCHAR(50) NOT NULL,
  cat VARCHAR(20) NOT NULL,
  sound VARCHAR(50),
  date DATE NOT NULL,
  note TEXT,
  retro BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

ALTER TABLE words ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own baby's words" ON words
  FOR SELECT USING (
    baby_id IN (
      SELECT id FROM baby_profiles WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert words" ON words
  FOR INSERT WITH CHECK (
    baby_id IN (
      SELECT id FROM baby_profiles WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own words" ON words
  FOR UPDATE USING (
    baby_id IN (
      SELECT id FROM baby_profiles WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own words" ON words
  FOR DELETE USING (
    baby_id IN (
      SELECT id FROM baby_profiles WHERE user_id = auth.uid()
    )
  );

-- Indexes
CREATE INDEX idx_words_baby_id ON words(baby_id);
CREATE INDEX idx_words_date ON words(date);
CREATE INDEX idx_baby_profiles_user_id ON baby_profiles(user_id);
