import { z } from 'zod'

// ============================================================================
// ENUMS
// ============================================================================

export enum PoolType {
  DAILY = 'daily',
  WEEKLY = 'weekly',
  FORTNIGHTLY = 'fortnightly',
  MONTHLY = 'monthly',
  STOKVEL = 'stokvel',
  SAVINGS = 'savings',
  INVESTMENT = 'investment',
  ROTATING = 'rotating',
}

export enum PoolStatus {
  DRAFT = 'draft',
  ACTIVE = 'active',
  PAUSED = 'paused',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
}

export enum PoolHealthStatus {
  HEALTHY = 'healthy',
  WARNING = 'warning',
  CRITICAL = 'critical',
}

export enum MemberRole {
  ADMIN = 'admin',
  MEMBER = 'member',
  VIEWER = 'viewer',
}

export enum MemberStatus {
  ACTIVE = 'active',
  PENDING = 'pending',
  SUSPENDED = 'suspended',
  DEFAULTED = 'defaulted',
}

export enum MemberTier {
  BRONZE = 'bronze',
  SILVER = 'silver',
  GOLD = 'gold',
  PLATINUM = 'platinum',
}

export enum PaymentStatus {
  PAID = 'paid',
  LATE = 'late',
  PENDING = 'pending',
  FAILED = 'failed',
  DEFAULTED = 'defaulted',
}

export enum TransactionType {
  CONTRIBUTION = 'contribution',
  PAYOUT = 'payout',
  PENALTY = 'penalty',
  REFUND = 'refund',
  FEE = 'fee',
}

export enum ProposalStatus {
  DRAFT = 'draft',
  ACTIVE = 'active',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  EXPIRED = 'expired',
}

// ============================================================================
// DATABASE MODELS
// ============================================================================

export interface User {
  id: string
  email: string
  name: string
  avatar_url?: string
  phone?: string
  wallet_balance: number
  total_savings: number
  trust_score: TrustScore
  created_at: string
  updated_at: string
  last_login_at?: string
  is_active: boolean
  metadata?: Record<string, any>
}

export interface TrustScore {
  score: number // 0 to 1000
  rating: 'exceptional' | 'good' | 'fair' | 'poor'
  metrics: {
    on_time_payment_rate: number
    years_active: number
    pools_completed: number
    defaults_count: number
  }
  updated_at: string
}

export interface Pool {
  id: string
  name: string
  description?: string
  type: PoolType
  creator_id: string
  constitution_id?: string
  contribution_amount: number
  contribution_schedule: string
  next_due_date: string
  rotation_position: number
  total_members: number
  max_members?: number
  status: PoolStatus
  health_status: PoolHealthStatus
  current_cycle: number
  total_pool_value: number
  created_at: string
  updated_at: string
  started_at?: string
  completed_at?: string
  settings: PoolSettings
  metadata?: Record<string, any>
}

export interface PoolSettings {
  late_payment_grace_days: number
  late_payment_penalty_rate: number
  minimum_trust_score?: number
  allow_early_exit: boolean
  require_unanimous_votes: boolean
  auto_rotate: boolean
  notification_preferences: {
    email: boolean
    sms: boolean
    in_app: boolean
  }
}

export interface PoolMember {
  id: string
  pool_id: string
  user_id: string
  role: MemberRole
  status: MemberStatus
  position: number
  tier: MemberTier
  total_contributed: number
  pending_contribution: number
  penalties_incurred: number
  payment_status: PaymentStatus
  joined_at: string
  last_payment_at?: string
  next_payout_date?: string
  constitution_signed: boolean
  signature_date?: string
}

export interface Transaction {
  id: string
  pool_id: string
  user_id: string
  type: TransactionType
  amount: number
  currency: string
  status: 'pending' | 'completed' | 'failed' | 'cancelled'
  description?: string
  reference?: string
  metadata?: Record<string, any>
  created_at: string
  completed_at?: string
}

export interface Constitution {
  id: string
  pool_id: string
  version: string
  template_name: string
  content: ConstitutionContent
  clauses: ConstitutionClause[]
  created_at: string
  updated_at: string
  is_active: boolean
}

export interface ConstitutionContent {
  pool_name: string
  purpose: string
  pool_type: PoolType
  contribution_amount: string
  contribution_schedule: string
  late_payment_policy: string
  dispute_resolution: string
  voting_threshold: 'simple_majority' | 'two_thirds' | 'unanimous'
  popia_consent: boolean
  authorized_signatories: string
}

export interface ConstitutionClause {
  id: string
  title: string
  content: string
  order: number
  is_custom: boolean
}

export interface MemberSignature {
  id: string
  pool_id: string
  user_id: string
  constitution_id: string
  full_legal_name: string
  ip_address?: string
  signed_at: string
  is_active: boolean
}

export interface Proposal {
  id: string
  pool_id: string
  created_by: string
  title: string
  description: string
  type: 'constitutional_change' | 'member_action' | 'pool_setting' | 'other'
  status: ProposalStatus
  created_at: string
  deadline: string
  yes_votes: number
  no_votes: number
  abstain_votes: number
  required_votes: number
  metadata?: Record<string, any>
}

export interface Vote {
  id: string
  proposal_id: string
  user_id: string
  vote: 'yes' | 'no' | 'abstain'
  comment?: string
  created_at: string
}

// ============================================================================
// ZOD VALIDATION SCHEMAS
// ============================================================================

export const CreatePoolSchema = z.object({
  name: z.string().min(3, 'Pool name must be at least 3 characters').max(100),
  description: z.string().max(1000).optional(),
  type: z.nativeEnum(PoolType),
  contribution_amount: z.number().positive('Contribution must be positive'),
  contribution_schedule: z.string().min(1),
  max_members: z.number().int().positive().optional(),
  settings: z.object({
    late_payment_grace_days: z.number().int().min(0).default(3),
    late_payment_penalty_rate: z.number().min(0).max(100).default(10),
    minimum_trust_score: z.number().min(0).max(1000).optional(),
    allow_early_exit: z.boolean().default(false),
    require_unanimous_votes: z.boolean().default(false),
    auto_rotate: z.boolean().default(true),
    notification_preferences: z.object({
      email: z.boolean().default(true),
      sms: z.boolean().default(false),
      in_app: z.boolean().default(true),
    }).default({
      email: true,
      sms: false,
      in_app: true,
    }),
  }).default({
    late_payment_grace_days: 3,
    late_payment_penalty_rate: 10,
    allow_early_exit: false,
    require_unanimous_votes: false,
    auto_rotate: true,
    notification_preferences: {
      email: true,
      sms: false,
      in_app: true,
    },
  }),
})

export const UpdatePoolSchema = CreatePoolSchema.partial()

export const CreateConstitutionSchema = z.object({
  pool_id: z.string().uuid(),
  template_name: z.string().min(1),
  content: z.object({
    pool_name: z.string().min(1),
    purpose: z.string().min(10),
    pool_type: z.nativeEnum(PoolType),
    contribution_amount: z.string().min(1),
    contribution_schedule: z.string().min(1),
    late_payment_policy: z.string().min(10),
    dispute_resolution: z.string().min(10),
    voting_threshold: z.enum(['simple_majority', 'two_thirds', 'unanimous']),
    popia_consent: z.boolean(),
    authorized_signatories: z.string().min(1),
  }),
  clauses: z.array(z.object({
    id: z.string(),
    title: z.string(),
    content: z.string(),
    order: z.number().int(),
    is_custom: z.boolean(),
  })),
})

export const CreateTransactionSchema = z.object({
  pool_id: z.string().uuid(),
  type: z.nativeEnum(TransactionType),
  amount: z.number().positive(),
  currency: z.string().length(3).default('ZAR'),
  description: z.string().max(500).optional(),
  reference: z.string().max(100).optional(),
})

export const CreateProposalSchema = z.object({
  pool_id: z.string().uuid(),
  title: z.string().min(5).max(200),
  description: z.string().min(20).max(2000),
  type: z.enum(['constitutional_change', 'member_action', 'pool_setting', 'other']),
  deadline: z.string().datetime(),
})

export const VoteSchema = z.object({
  proposal_id: z.string().uuid(),
  vote: z.enum(['yes', 'no', 'abstain']),
  comment: z.string().max(500).optional(),
})

export const SignConstitutionSchema = z.object({
  pool_id: z.string().uuid(),
  constitution_id: z.string().uuid(),
  full_legal_name: z.string().min(3).max(255),
  ip_address: z.string().ip().optional(),
})

// ============================================================================
// API RESPONSE TYPES
// ============================================================================

export interface ApiResponse<T = any> {
  success: boolean
  data?: T
  error?: {
    code: string
    message: string
    details?: any
  }
  metadata?: {
    page?: number
    limit?: number
    total?: number
    has_more?: boolean
  }
}

export interface PaginationParams {
  page?: number
  limit?: number
  sort_by?: string
  order?: 'asc' | 'desc'
}

// ============================================================================
// COMPONENT PROPS TYPES
// ============================================================================

export interface PoolCardProps {
  pool: Pool
  onView?: (poolId: string) => void
  onJoin?: (poolId: string) => void
  isJoined?: boolean
}

export interface MemberCardProps {
  member: PoolMember
  user?: User
  onView?: (memberId: string) => void
}

export interface TransactionListProps {
  transactions: Transaction[]
  isLoading?: boolean
  onTransactionClick?: (transaction: Transaction) => void
}

// ============================================================================
// GEMINI AI TYPES
// ============================================================================

export interface AIConstitutionRequest {
  poolType: PoolType
  poolName: string
  purpose: string
  numberOfMembers?: number
  contributionAmount?: number
  contributionSchedule?: string
  additionalContext?: string
}

export interface AIConstitutionResponse {
  constitution: string
  clauses: ConstitutionClause[]
  key_points: string[]
  warnings: string[]
  recommendations: string[]
}

export interface AIAnalysisRequest {
  poolData: Pool
  transactions?: Transaction[]
  members?: PoolMember[]
}

export interface AIAnalysisResponse {
  health_score: number
  insights: string[]
  recommendations: string[]
  risks: string[]
  opportunities: string[]
}

// ============================================================================
// TYPE EXPORTS
// ============================================================================

export type CreatePoolInput = z.infer<typeof CreatePoolSchema>
export type UpdatePoolInput = z.infer<typeof UpdatePoolSchema>
export type CreateConstitutionInput = z.infer<typeof CreateConstitutionSchema>
export type CreateTransactionInput = z.infer<typeof CreateTransactionSchema>
export type CreateProposalInput = z.infer<typeof CreateProposalSchema>
export type VoteInput = z.infer<typeof VoteSchema>
export type SignConstitutionInput = z.infer<typeof SignConstitutionSchema>
