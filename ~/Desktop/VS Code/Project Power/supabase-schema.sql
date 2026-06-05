-- Project Power - Supabase Schema
-- 请在 Supabase Dashboard → SQL Editor 中执行

-- 1. 人员表
CREATE TABLE IF NOT EXISTS persons (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  track TEXT NOT NULL CHECK (track IN ('求职', '找对象')),
  start_date TEXT NOT NULL
);

-- 2. 进度表（每个阶段的数值和状态）
CREATE TABLE IF NOT EXISTS progresses (
  person_id TEXT PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
  stages JSONB NOT NULL DEFAULT '{}'
);

-- 3. 阈值配置表
CREATE TABLE IF NOT EXISTS thresholds (
  id INTEGER PRIMARY KEY DEFAULT 1,
  config JSONB NOT NULL
);

-- 4. 阶段日志表
CREATE TABLE IF NOT EXISTS logs (
  id BIGSERIAL PRIMARY KEY,
  person_id TEXT NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  stage_index INTEGER NOT NULL,
  content TEXT NOT NULL,
  mood TEXT DEFAULT '一般',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. 评论/回复表
CREATE TABLE IF NOT EXISTS comments (
  id BIGSERIAL PRIMARY KEY,
  person_id TEXT NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  stage_index INTEGER NOT NULL,
  content TEXT NOT NULL,
  parent_id BIGINT REFERENCES comments(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_logs_person_stage ON logs(person_id, stage_index);
CREATE INDEX IF NOT EXISTS idx_comments_person_stage ON comments(person_id, stage_index);

-- 允许匿名用户操作
ALTER TABLE persons ENABLE ROW LEVEL SECURITY;
ALTER TABLE progresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE thresholds ENABLE ROW LEVEL SECURITY;
ALTER TABLE logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- 允许所有人读写（因为是个人项目）
CREATE POLICY "allow_all_persons" ON persons FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_progresses" ON progresses FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_thresholds" ON thresholds FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_logs" ON logs FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_comments" ON comments FOR ALL USING (true) WITH CHECK (true);
