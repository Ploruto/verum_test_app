-- Migration 001: initial schema
-- =====================================
CREATE TABLE users (
  id SERIAL NOT NULL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  bio TEXT,
  order_number INTEGER NOT NULL DEFAULT nextval('user_order_seq'),
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL
);

CREATE INDEX users_id_idx ON users (id);

CREATE TABLE posts (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(200) NOT NULL,
  content TEXT,
  published BOOLEAN NOT NULL,
  user_id VARCHAR(36) NOT NULL,
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL
);

CREATE INDEX posts_id_idx ON posts (id);
