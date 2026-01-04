USE barbichetz_videos;

CREATE TABLE users (
    user_id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_is_admin (is_admin)
);

CREATE TABLE rsa_keys (
    key_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    algorithm VARCHAR(50) NOT NULL,
    key_size_bits INT NOT NULL,
    public_key_pem LONGTEXT NOT NULL,
    key_status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    validity_start TIMESTAMP NOT NULL,
    validity_end TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_key_status (key_status),
    INDEX idx_validity (validity_start, validity_end)
);

CREATE TABLE video_messages (
    message_id VARCHAR(36) PRIMARY KEY,
    sender_user_id VARCHAR(36) NOT NULL,
    recipient_user_id VARCHAR(36) NOT NULL,
    video_storage_url VARCHAR(2048) NOT NULL,
    video_sha256_hash VARCHAR(64) NOT NULL,
    signature_base64 LONGTEXT NOT NULL,
    signature_algorithm VARCHAR(50) NOT NULL,
    signer_key_id VARCHAR(36) NOT NULL,
    manifest_json LONGTEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    soft_deleted_at TIMESTAMP NULL,
    is_legal_hold BOOLEAN DEFAULT FALSE,
    
    INDEX idx_sender (sender_user_id, sent_at),
    INDEX idx_recipient (recipient_user_id, soft_deleted_at),
    INDEX idx_expiration (expires_at),
    INDEX idx_signer_key (signer_key_id)
);

CREATE TABLE action_audit_log (
    audit_id VARCHAR(36) PRIMARY KEY,
    actor_user_id VARCHAR(36) NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    target_resource VARCHAR(255) NOT NULL,
    source_ip_address VARCHAR(45) NOT NULL,
    user_agent VARCHAR(500) NOT NULL,
    log_signature VARCHAR(1024) NOT NULL,
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    INDEX idx_actor_time (actor_user_id, action_timestamp),
    INDEX idx_action_type (action_type),
    INDEX idx_target (target_resource),
    INDEX idx_timestamp (action_timestamp)
);

CREATE TABLE upload_sessions (
    session_id VARCHAR(36) PRIMARY KEY,
    message_id VARCHAR(36) NOT NULL,
    uploader_user_id VARCHAR(36) NOT NULL,
    total_chunks INT NOT NULL,
    chunks_received INT DEFAULT 0,
    session_status VARCHAR(50) NOT NULL DEFAULT 'IN_PROGRESS',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    
    INDEX idx_message_id (message_id),
    INDEX idx_uploader (uploader_user_id),
    INDEX idx_status (session_status)
);