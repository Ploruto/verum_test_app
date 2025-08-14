-- Migration 001: initial schema
-- =====================================
CREATE TABLE users (
  id INTEGER NOT NULL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  bio TEXT,
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL
);

CREATE INDEX users_id_idx ON users (id);

CREATE TABLE posts (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  content TEXT,
  published BOOLEAN NOT NULL,
  user_id VARCHAR(36) NOT NULL,
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL
);

CREATE INDEX posts_id_idx ON posts (id);
