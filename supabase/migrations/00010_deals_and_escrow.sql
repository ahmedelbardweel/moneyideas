-- ============================================================================
-- 00010_deals_and_escrow.sql
-- Money Ideas | أفكار المال
-- Module 10: Investment Deals, Milestones, Digital Contracts & Escrow
-- Idempotent: safe to run more than once.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Table: deals
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.deals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES public.projects(id) ON DELETE SET NULL,
  investor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  creator_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  deal_type TEXT NOT NULL DEFAULT 'equity',
  target_amount NUMERIC(14, 2) NOT NULL DEFAULT 0,
  equity_percentage NUMERIC(5, 2) DEFAULT NULL,
  status TEXT NOT NULL DEFAULT 'draft',
  terms_summary TEXT,
  investor_signed_at TIMESTAMPTZ DEFAULT NULL,
  creator_signed_at TIMESTAMPTZ DEFAULT NULL,
  escrow_account_id TEXT DEFAULT NULL,
  escrow_status TEXT NOT NULL DEFAULT 'not_initiated',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_deal_type CHECK (deal_type IN ('equity', 'convertible_note', 'debt_financing', 'franchise_partnership', 'acquisition')),
  CONSTRAINT chk_deal_status CHECK (status IN ('draft', 'negotiation', 'contract_pending', 'escrow_funded', 'in_progress', 'completed', 'cancelled')),
  CONSTRAINT chk_escrow_status CHECK (escrow_status IN ('not_initiated', 'pending_deposit', 'held_in_escrow', 'released', 'disputed'))
);

CREATE INDEX IF NOT EXISTS idx_deals_investor_id ON public.deals(investor_id);
CREATE INDEX IF NOT EXISTS idx_deals_creator_id ON public.deals(creator_id);
CREATE INDEX IF NOT EXISTS idx_deals_project_id ON public.deals(project_id);
CREATE INDEX IF NOT EXISTS idx_deals_status ON public.deals(status);

-- ----------------------------------------------------------------------------
-- 2. Table: deal_milestones
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.deal_milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  deal_id UUID NOT NULL REFERENCES public.deals(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  amount NUMERIC(14, 2) NOT NULL DEFAULT 0,
  order_index INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pending',
  proof_url TEXT DEFAULT NULL,
  due_date DATE DEFAULT NULL,
  completed_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_milestone_status CHECK (status IN ('pending', 'submitted_for_approval', 'approved', 'released', 'disputed'))
);

CREATE INDEX IF NOT EXISTS idx_deal_milestones_deal_id ON public.deal_milestones(deal_id);
CREATE INDEX IF NOT EXISTS idx_deal_milestones_order ON public.deal_milestones(deal_id, order_index);

-- ----------------------------------------------------------------------------
-- 3. Table: deal_contracts
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.deal_contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  deal_id UUID NOT NULL REFERENCES public.deals(id) ON DELETE CASCADE,
  contract_version INTEGER NOT NULL DEFAULT 1,
  legal_clauses JSONB NOT NULL DEFAULT '[]'::jsonb,
  governing_law TEXT NOT NULL DEFAULT 'قوانين وإجراءات مركز دبي المالي العالمي (DIFC) / سوق أبوظبي العالمي (ADGM) ودولة الإمارات العربية المتحدة',
  dispute_mechanism TEXT NOT NULL DEFAULT 'الوساطة والتحكيم المالي المعتمد',
  investor_signature TEXT DEFAULT NULL,
  creator_signature TEXT DEFAULT NULL,
  investor_signed_at TIMESTAMPTZ DEFAULT NULL,
  creator_signed_at TIMESTAMPTZ DEFAULT NULL,
  is_finalized BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_deal_contracts_deal_id ON public.deal_contracts(deal_id);

-- ----------------------------------------------------------------------------
-- 4. Enable RLS
-- ----------------------------------------------------------------------------
ALTER TABLE public.deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deal_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deal_contracts ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- 5. Policies: deals
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Participants and admins can view deals" ON public.deals;
CREATE POLICY "Participants and admins can view deals"
  ON public.deals FOR SELECT
  USING (
    investor_id = auth.uid() OR
    creator_id = auth.uid() OR
    public.is_admin()
  );

DROP POLICY IF EXISTS "Authenticated users can create deals" ON public.deals;
CREATE POLICY "Authenticated users can create deals"
  ON public.deals FOR INSERT
  WITH CHECK (
    auth.uid() = creator_id OR
    auth.uid() = investor_id OR
    public.is_admin()
  );

DROP POLICY IF EXISTS "Participants and admins can update deals" ON public.deals;
CREATE POLICY "Participants and admins can update deals"
  ON public.deals FOR UPDATE
  USING (
    investor_id = auth.uid() OR
    creator_id = auth.uid() OR
    public.is_admin()
  );

-- ----------------------------------------------------------------------------
-- 6. Policies: deal_milestones
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Participants and admins can view deal milestones" ON public.deal_milestones;
CREATE POLICY "Participants and admins can view deal milestones"
  ON public.deal_milestones FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.deals d
      WHERE d.id = deal_milestones.deal_id
      AND (d.investor_id = auth.uid() OR d.creator_id = auth.uid() OR public.is_admin())
    )
  );

DROP POLICY IF EXISTS "Participants and admins can manage deal milestones" ON public.deal_milestones;
CREATE POLICY "Participants and admins can manage deal milestones"
  ON public.deal_milestones FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.deals d
      WHERE d.id = deal_milestones.deal_id
      AND (d.investor_id = auth.uid() OR d.creator_id = auth.uid() OR public.is_admin())
    )
  );

-- ----------------------------------------------------------------------------
-- 7. Policies: deal_contracts
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Participants and admins can view deal contracts" ON public.deal_contracts;
CREATE POLICY "Participants and admins can view deal contracts"
  ON public.deal_contracts FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.deals d
      WHERE d.id = deal_contracts.deal_id
      AND (d.investor_id = auth.uid() OR d.creator_id = auth.uid() OR public.is_admin())
    )
  );

DROP POLICY IF EXISTS "Participants and admins can manage deal contracts" ON public.deal_contracts;
CREATE POLICY "Participants and admins can manage deal contracts"
  ON public.deal_contracts FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.deals d
      WHERE d.id = deal_contracts.deal_id
      AND (d.investor_id = auth.uid() OR d.creator_id = auth.uid() OR public.is_admin())
    )
  );

-- ----------------------------------------------------------------------------
-- 8. Realtime publication
-- ----------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'deals'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.deals;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'deal_milestones'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.deal_milestones;
  END IF;
END $$;
