-- =========================================================================
-- AI CHATBOT SYSTEM - DATABASE SCHEMA (JDBC COMPLIANT)
-- Author: Abhinav Kumar Singh
-- GUVI Geek Network Pvt. Ltd. Project
-- Compatible with MySQL 8.x and SQLite 3.x
-- =========================================================================

-- 1. Users Table (Supports Admin and Customer Roles)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER', -- 'ADMIN' or 'USER'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Knowledge Base & Response Templates Table
CREATE TABLE IF NOT EXISTS knowledge_base (
    id INT AUTO_INCREMENT PRIMARY KEY,
    intent VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,
    question_pattern TEXT NOT NULL,
    response_template TEXT NOT NULL,
    keywords_raw TEXT NOT NULL,
    confidence_threshold DOUBLE DEFAULT 0.65,
    is_active INT DEFAULT 1,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Conversation Interaction Logs Table
CREATE TABLE IF NOT EXISTS interaction_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    query_text TEXT NOT NULL,
    bot_response TEXT NOT NULL,
    intent_detected VARCHAR(50),
    confidence_score DOUBLE,
    sentiment_score DOUBLE,
    response_time_ms BIGINT,
    is_resolved INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 4. Customer Feedbacks Table
CREATE TABLE IF NOT EXISTS feedbacks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    log_id INT,
    user_id INT,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    is_helpful INT DEFAULT 1,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (log_id) REFERENCES interaction_logs(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 5. System Configurations Table
CREATE TABLE IF NOT EXISTS system_configs (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value TEXT NOT NULL,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Machine Learning Algorithm Models Table
CREATE TABLE IF NOT EXISTS algorithm_models (
    id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    algorithm_type VARCHAR(50) NOT NULL,
    learning_rate DOUBLE DEFAULT 0.05,
    accuracy_score DOUBLE DEFAULT 0.88,
    precision_score DOUBLE DEFAULT 0.89,
    recall_score DOUBLE DEFAULT 0.87,
    epochs INT DEFAULT 50,
    is_active INT DEFAULT 1,
    last_trained TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for Fast Analytics and Query Lookup
CREATE INDEX IF NOT EXISTS idx_logs_user ON interaction_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_logs_intent ON interaction_logs(intent_detected);
CREATE INDEX IF NOT EXISTS idx_kb_intent ON knowledge_base(intent);
CREATE INDEX IF NOT EXISTS idx_feedbacks_rating ON feedbacks(rating);

-- =========================================================================
-- SEED DATA
-- =========================================================================

-- Insert Seed Users
INSERT INTO users (username, email, full_name, role) VALUES 
('admin', 'admin@guvi.in', 'System Administrator', 'ADMIN'),
('john_doe', 'john@customer.com', 'John Doe', 'USER'),
('sarah_k', 'sarah@customer.com', 'Sarah Khan', 'USER');

-- Insert Seed System Configurations
INSERT INTO system_configs (config_key, config_value, description) VALUES
('BOT_NAME', 'NovaAI Assistant', 'Display name of the AI Chatbot'),
('WELCOME_MESSAGE', 'Hello! I am your AI Support Assistant. How may I assist you today?', 'Initial greeting message'),
('FALLBACK_MESSAGE', 'I apologize, but I could not understand that query with sufficient confidence. Would you like to connect with human support?', 'Default fallback reply'),
('MIN_CONFIDENCE_THRESHOLD', '0.65', 'Global minimum confidence threshold'),
('VOICE_ENABLED', 'true', 'Enable speech recognition and audio synthesis');

-- Insert Seed Algorithm Models
INSERT INTO algorithm_models (model_name, algorithm_type, learning_rate, accuracy_score, precision_score, recall_score, epochs, is_active) VALUES
('Ensemble-NLP-v2.4', 'HYBRID_NLP', 0.05, 0.912, 0.925, 0.898, 50, 1),
('Legacy-TFIDF-v1.0', 'TF_IDF', 0.01, 0.824, 0.840, 0.810, 30, 0);

-- Insert Seed Knowledge Base Response Templates
INSERT INTO knowledge_base (intent, category, question_pattern, response_template, keywords_raw, confidence_threshold, is_active) VALUES
('GREETING', 'GENERAL', 'hello hi hey good morning greetings', 'Hello! Welcome to 24/7 AI Customer Support. How may I assist you today?', 'hello,hi,hey,morning,evening,greetings', 0.60, 1),
('PASSWORD_RESET', 'ACCOUNT', 'how do i reset my password forgot password change login', 'To reset your password:\n1. Click "Forgot Password" on login screen.\n2. Enter registered email address.\n3. Follow the secure reset email instructions.', 'password,reset,forgot,login,credentials', 0.65, 1),
('ORDER_TRACKING', 'ORDERS', 'where is my order track shipment tracking delivery', 'Track your order in real-time under "My Account" > "Order History" > "Track Shipment".', 'order,track,tracking,shipment,delivery,package', 0.65, 1),
('REFUND_POLICY', 'BILLING', 'refund policy money back cancel order return item', 'We offer a 30-day money-back guarantee. Select your order and click "Request Refund" to initiate.', 'refund,return,money,back,cancel,policy', 0.65, 1),
('PAYMENT_METHODS', 'BILLING', 'payment methods credit card upi netbanking paypal', 'We support Credit/Debit Cards, UPI, Net Banking, and PayPal for international payments.', 'payment,methods,credit,debit,card,upi,paypal', 0.65, 1),
('BUSINESS_HOURS', 'SUPPORT', 'working hours business hours open timing schedule', 'The AI Chatbot is available 24/7. Human support agents are active Mon-Sat 9am-8pm IST.', 'hours,timing,open,working,business,schedule', 0.65, 1),
('CONTACT_HUMAN', 'SUPPORT', 'talk to human agent representative customer executive phone number', 'Contact human support at: 1800-425-GUVI or email support@aichatbot-guvi.org.', 'human,agent,executive,representative,call,phone', 0.65, 1);
