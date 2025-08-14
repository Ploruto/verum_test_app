-- Rollback 003: rename bio to description in user
-- =====================================
ALTER TABLE user RENAME COLUMN description TO bio;
