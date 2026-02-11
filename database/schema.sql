-- ============================================================================
-- UBUNTU POOLS DATABASE SCHEMA
-- Production-Ready PostgreSQL/Supabase Schema
-- ============================================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- USERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    phone VARCHAR(20),
    wallet_balance DECIMAL(15, 2) DEFAULT 0.00 CHECK (wallet_balance >= 0),
    total_savings DECIMAL(15, 2) DEFAULT 0.00 CHECK (total_savings >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- ============================================================================
-- TRUST METRICS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS trust_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    score INTEGER CHECK (score >= 0 AND score <= 1000) DEFAULT 500,
    rating VARCHAR(20) CHECK (rating IN ('exceptional', 'good', 'fair', 'poor')) DEFAULT 'fair',
    on_time_payment_rate NUMERIC(5,2) DEFAULT 0.00 CHECK (on_time_payment_rate >= 0 AND on_time_payment_rate <= 100),
    years_active NUMERIC(5,2) DEFAULT 0.00,
    pools_completed INTEGER DEFAULT 0,
    defaults_count INTEGER DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- ============================================================================
-- POOLS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS pools (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL CHECK (type IN ('daily', 'weekly', 'fortnightly', 'monthly', 'stokvel', 'savings', 'investment', 'rotating')),
    creator_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    constitution_id UUID,
    contribution_amount DECIMAL(15, 2) NOT NULL CHECK (contribution_amount > 0),
    contribution_schedule VARCHAR(100) NOT NULL,
    next_due_date DATE NOT NULL,
    rotation_position INTEGER DEFAULT 1 CHECK (rotation_position > 0),
    total_members INTEGER DEFAULT 0 CHECK (total_members >= 0),
    max_members INTEGER CHECK (max_members IS NULL OR max_members > 0),
    status VARCHAR(50) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'paused', 'completed', 'cancelled')),
    health_status VARCHAR(50) NOT NULL DEFAULT 'healthy' CHECK (health_status IN ('healthy', 'warning', 'critical')),
    current_cycle INTEGER DEFAULT 0 CHECK (current_cycle >= 0),
    total_pool_value DECIMAL(15, 2) DEFAULT 0.00 CHECK (total_pool_value >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    settings JSONB NOT NULL DEFAULT '{"late_payment_grace_days": 3, "late_payment_penalty_rate": 10, "allow_early_exit": false, "require_unanimous_votes": false, "auto_rotate": true, "notification_preferences": {"email": true, "sms": false, "in_app": true}}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- ============================================================================
-- POOL MEMBERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS pool_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pool_id UUID NOT NULL REFERENCES pools(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member', 'viewer')),
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('active', 'pending', 'suspended', 'defaulted')),
    position INTEGER NOT NULL CHECK (position > 0),
    tier VARCHAR(50) DEFAULT 'bronze' CHECK (tier IN ('bronze', 'silver', 'gold', 'platinum')),
    total_contributed DECIMAL(15, 2) DEFAULT 0.00 CHECK (total_contributed >= 0),
    pending_contribution DECIMAL(15, 2) DEFAULT 0.00 CHECK (pending_contribution >= 0),
    penalties_incurred DECIMAL(15, 2) DEFAULT 0.00 CHECK (penalties_incurred >= 0),
    payment_status VARCHAR(50) DEFAULT 'pending' CHECK (payment_status IN ('paid', 'late', 'pending', 'failed', 'defaulted')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_payment_at TIMESTAMP WITH TIME ZONE,
    next_payout_date DATE,
    constitution_signed BOOLEAN DEFAULT FALSE,
    signature_date TIMESTAMP WITH TIME ZONE,
    UNIQUE(pool_id, user_id),
    UNIQUE(pool_id, position)
);

-- ============================================================================
-- TRANSACTIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pool_id UUID NOT NULL REFERENCES pools(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('contribution', 'payout', 'penalty', 'refund', 'fee')),
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) DEFAULT 'ZAR',
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),
    description TEXT,
    reference VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- ============================================================================
-- CONSTITUTIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS pool_constitutions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pool_id UUID NOT NULL REFERENCES pools(id) ON DELETE CASCADE,
    version VARCHAR(20) NOT NULL,
    template_name VARCHAR(255) NOT NULL,
    content JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE
);

-- ============================================================================
-- CONSTITUTION CLAUSES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS constitution_clauses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    constitution_id UUID NOT NULL REFERENCES pool_constitutions(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    content TEXT NOT NULL,
    clause_order INTEGER NOT NULL,
    is_custom BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- MEMBER SIGNATURES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS member_signatures (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pool_id UUID NOT NULL REFERENCES pools(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    constitution_id UUID NOT NULL REFERENCES pool_constitutions(id) ON DELETE CASCADE,
    full_legal_name VARCHAR(255) NOT NULL,
    ip_address INET,
    signed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(pool_id, user_id, constitution_id)
);

-- ============================================================================
-- PROPOSALS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS proposals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pool_id UUID NOT NULL REFERENCES pools(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('constitutional_change', 'member_action', 'pool_setting', 'other')),
    status VARCHAR(50) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'approved', 'rejected', 'expired')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deadline TIMESTAMP WITH TIME ZONE NOT NULL,
    yes_votes INTEGER DEFAULT 0 CHECK (yes_votes >= 0),
    no_votes INTEGER DEFAULT 0 CHECK (no_votes >= 0),
    abstain_votes INTEGER DEFAULT 0 CHECK (abstain_votes >= 0),
    required_votes INTEGER NOT NULL CHECK (required_votes > 0),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- ============================================================================
-- VOTES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS votes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vote VARCHAR(10) NOT NULL CHECK (vote IN ('yes', 'no', 'abstain')),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(proposal_id, user_id)
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active) WHERE is_active = TRUE;

-- Trust metrics indexes
CREATE INDEX IF NOT EXISTS idx_trust_metrics_user ON trust_metrics(user_id);
CREATE INDEX IF NOT EXISTS idx_trust_metrics_score ON trust_metrics(score DESC);

-- Pools indexes
CREATE INDEX IF NOT EXISTS idx_pools_creator ON pools(creator_id);
CREATE INDEX IF NOT EXISTS idx_pools_status ON pools(status);
CREATE INDEX IF NOT EXISTS idx_pools_type ON pools(type);
CREATE INDEX IF NOT EXISTS idx_pools_health ON pools(health_status);
CREATE INDEX IF NOT EXISTS idx_pools_created_at ON pools(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_pools_next_due ON pools(next_due_date);

-- Pool members indexes
CREATE INDEX IF NOT EXISTS idx_pool_members_pool ON pool_members(pool_id);
CREATE INDEX IF NOT EXISTS idx_pool_members_user ON pool_members(user_id);
CREATE INDEX IF NOT EXISTS idx_pool_members_status ON pool_members(status);
CREATE INDEX IF NOT EXISTS idx_pool_members_payment_status ON pool_members(payment_status);

-- Transactions indexes
CREATE INDEX IF NOT EXISTS idx_transactions_pool ON transactions(pool_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at DESC);

-- Constitutions indexes
CREATE INDEX IF NOT EXISTS idx_constitutions_pool ON pool_constitutions(pool_id);
CREATE INDEX IF NOT EXISTS idx_constitutions_active ON pool_constitutions(is_active) WHERE is_active = TRUE;

-- Signatures indexes
CREATE INDEX IF NOT EXISTS idx_signatures_pool ON member_signatures(pool_id);
CREATE INDEX IF NOT EXISTS idx_signatures_user ON member_signatures(user_id);
CREATE INDEX IF NOT EXISTS idx_signatures_constitution ON member_signatures(constitution_id);

-- Proposals indexes
CREATE INDEX IF NOT EXISTS idx_proposals_pool ON proposals(pool_id);
CREATE INDEX IF NOT EXISTS idx_proposals_status ON proposals(status);
CREATE INDEX IF NOT EXISTS idx_proposals_deadline ON proposals(deadline);

-- Votes indexes
CREATE INDEX IF NOT EXISTS idx_votes_proposal ON votes(proposal_id);
CREATE INDEX IF NOT EXISTS idx_votes_user ON votes(user_id);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pools_updated_at BEFORE UPDATE ON pools
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_constitutions_updated_at BEFORE UPDATE ON pool_constitutions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update pool total_pool_value when transaction completed
CREATE OR REPLACE FUNCTION update_pool_value_on_transaction()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        IF NEW.type = 'contribution' THEN
            UPDATE pools 
            SET total_pool_value = total_pool_value + NEW.amount
            WHERE id = NEW.pool_id;
        ELSIF NEW.type IN ('payout', 'refund') THEN
            UPDATE pools 
            SET total_pool_value = total_pool_value - NEW.amount
            WHERE id = NEW.pool_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER transaction_updates_pool_value
AFTER INSERT OR UPDATE ON transactions
FOR EACH ROW EXECUTE FUNCTION update_pool_value_on_transaction();

-- Update pool member count
CREATE OR REPLACE FUNCTION update_pool_member_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE pools 
        SET total_members = total_members + 1
        WHERE id = NEW.pool_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE pools 
        SET total_members = total_members - 1
        WHERE id = OLD.pool_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER pool_member_count_trigger
AFTER INSERT OR DELETE ON pool_members
FOR EACH ROW EXECUTE FUNCTION update_pool_member_count();

-- Update proposal vote counts
CREATE OR REPLACE FUNCTION update_proposal_vote_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.vote = 'yes' THEN
            UPDATE proposals SET yes_votes = yes_votes + 1 WHERE id = NEW.proposal_id;
        ELSIF NEW.vote = 'no' THEN
            UPDATE proposals SET no_votes = no_votes + 1 WHERE id = NEW.proposal_id;
        ELSIF NEW.vote = 'abstain' THEN
            UPDATE proposals SET abstain_votes = abstain_votes + 1 WHERE id = NEW.proposal_id;
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        -- Decrement old vote
        IF OLD.vote = 'yes' THEN
            UPDATE proposals SET yes_votes = yes_votes - 1 WHERE id = OLD.proposal_id;
        ELSIF OLD.vote = 'no' THEN
            UPDATE proposals SET no_votes = no_votes - 1 WHERE id = OLD.proposal_id;
        ELSIF OLD.vote = 'abstain' THEN
            UPDATE proposals SET abstain_votes = abstain_votes - 1 WHERE id = OLD.proposal_id;
        END IF;
        -- Increment new vote
        IF NEW.vote = 'yes' THEN
            UPDATE proposals SET yes_votes = yes_votes + 1 WHERE id = NEW.proposal_id;
        ELSIF NEW.vote = 'no' THEN
            UPDATE proposals SET no_votes = no_votes + 1 WHERE id = NEW.proposal_id;
        ELSIF NEW.vote = 'abstain' THEN
            UPDATE proposals SET abstain_votes = abstain_votes + 1 WHERE id = NEW.proposal_id;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.vote = 'yes' THEN
            UPDATE proposals SET yes_votes = yes_votes - 1 WHERE id = OLD.proposal_id;
        ELSIF OLD.vote = 'no' THEN
            UPDATE proposals SET no_votes = no_votes - 1 WHERE id = OLD.proposal_id;
        ELSIF OLD.vote = 'abstain' THEN
            UPDATE proposals SET abstain_votes = abstain_votes - 1 WHERE id = OLD.proposal_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_proposal_votes
AFTER INSERT OR UPDATE OR DELETE ON votes
FOR EACH ROW EXECUTE FUNCTION update_proposal_vote_counts();

-- Update trust score on transaction completion
CREATE OR REPLACE FUNCTION update_trust_score_on_payment()
RETURNS TRIGGER AS $$
DECLARE
    is_on_time BOOLEAN;
    pool_next_due DATE;
BEGIN
    IF NEW.status = 'completed' AND NEW.type = 'contribution' THEN
        -- Check if payment was on time
        SELECT next_due_date INTO pool_next_due FROM pools WHERE id = NEW.pool_id;
        is_on_time := NEW.completed_at::DATE <= pool_next_due;
        
        -- Update trust metrics
        UPDATE trust_metrics tm
        SET 
            on_time_payment_rate = CASE 
                WHEN is_on_time THEN LEAST(100, on_time_payment_rate + 0.5)
                ELSE GREATEST(0, on_time_payment_rate - 1)
            END,
            score = CASE 
                WHEN is_on_time THEN LEAST(1000, score + 5)
                ELSE GREATEST(0, score - 10)
            END,
            updated_at = NOW()
        WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_trust_on_payment
AFTER UPDATE ON transactions
FOR EACH ROW EXECUTE FUNCTION update_trust_score_on_payment();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE trust_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE pools ENABLE ROW LEVEL SECURITY;
ALTER TABLE pool_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE pool_constitutions ENABLE ROW LEVEL SECURITY;
ALTER TABLE constitution_clauses ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_signatures ENABLE ROW LEVEL SECURITY;
ALTER TABLE proposals ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view all users" ON users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

-- Trust metrics policies
CREATE POLICY "Anyone can view trust metrics" ON trust_metrics FOR SELECT USING (true);

-- Pools policies
CREATE POLICY "Anyone can view active pools" ON pools FOR SELECT USING (status IN ('active', 'completed'));
CREATE POLICY "Creators can update their pools" ON pools FOR UPDATE USING (auth.uid() = creator_id);
CREATE POLICY "Authenticated users can create pools" ON pools FOR INSERT WITH CHECK (auth.uid() = creator_id);

-- Pool members policies
CREATE POLICY "Pool members can view pool membership" ON pool_members FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM pool_members pm
        WHERE pm.pool_id = pool_members.pool_id
        AND pm.user_id = auth.uid()
    )
);

-- Transactions policies
CREATE POLICY "Users can view their own transactions" ON transactions FOR SELECT 
USING (user_id = auth.uid());

-- Proposals policies
CREATE POLICY "Pool members can view proposals" ON proposals FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM pool_members pm
        WHERE pm.pool_id = proposals.pool_id
        AND pm.user_id = auth.uid()
    )
);

-- ============================================================================
-- SEED DATA (OPTIONAL - FOR DEVELOPMENT)
-- ============================================================================

-- This section can be commented out for production
-- INSERT seed data here if needed for testing
