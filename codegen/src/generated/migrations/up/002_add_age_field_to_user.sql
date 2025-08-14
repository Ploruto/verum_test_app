-- Migration 002: add age field to user
-- =====================================
ALTER TABLE user ADD COLUMN age INTEGER NOT NULL DEFAULT 0;
