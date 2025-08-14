-- Migration 003: rename bio to description in user
-- =====================================
ALTER TABLE user RENAME COLUMN bio TO description;
