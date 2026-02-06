-- PostgreSQL Database Initialization Script
-- This file is executed on first container startup
-- Demonstrates best practices for database initialization

-- Set session parameters
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create schema
CREATE SCHEMA IF NOT EXISTS app AUTHORIZATION appuser;

-- Revoke default public schema permissions
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO appuser;

-- Create tables
CREATE TABLE app.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE app.audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES app.users(id),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(100),
    resource_id VARCHAR(255),
    changes JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX idx_users_username ON app.users(username);
CREATE INDEX idx_users_email ON app.users(email);
CREATE INDEX idx_audit_user_id ON app.audit_logs(user_id);
CREATE INDEX idx_audit_created ON app.audit_logs(created_at DESC);

-- Create triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON app.users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions to application user
GRANT USAGE ON SCHEMA app TO appuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO appuser;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA app TO appuser;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA app TO appuser;

-- Insert sample data
INSERT INTO app.users (username, email, password_hash) VALUES
    ('admin', 'admin@example.com', '$2b$12$...'),
    ('user1', 'user1@example.com', '$2b$12$...'),
    ('user2', 'user2@example.com', '$2b$12$...')
ON CONFLICT DO NOTHING;

-- Create audit log entries
INSERT INTO app.audit_logs (user_id, action, resource_type) 
SELECT id, 'created', 'user' FROM app.users ON CONFLICT DO NOTHING;

-- Set default session timezone
SET timezone = 'UTC';

-- Verify setup
SELECT 'Database initialized successfully' AS status;
