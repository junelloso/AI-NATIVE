# Database Schema — AI-NATIVE Platform

> Status: Draft (Phase 0) | PostgreSQL 16

---

## Core Tables

```sql
-- ============================================================
-- USERS & AUTH
-- ============================================================
CREATE TABLE users (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email         TEXT UNIQUE NOT NULL,
    display_name  TEXT NOT NULL,
    role          TEXT NOT NULL DEFAULT 'user',  -- user | admin | service
    is_active     BOOLEAN NOT NULL DEFAULT true,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at    TIMESTAMPTZ NULL  -- soft delete
);

-- ============================================================
-- AI INTERACTIONS (Audit + Auto-Learn feed)
-- ============================================================
CREATE TABLE ai_interactions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID REFERENCES users(id),
    session_id      UUID NOT NULL,
    model           TEXT NOT NULL,         -- claude-sonnet-4-6
    prompt_tokens   INT NOT NULL,
    output_tokens   INT NOT NULL,
    latency_ms      INT NOT NULL,
    eval_score      NUMERIC(4,3) NULL,     -- 0.000 to 1.000
    feedback        SMALLINT NULL,         -- -1 | 0 | 1 (thumbs down/neutral/up)
    metadata        JSONB NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX ai_interactions_user_id_idx   ON ai_interactions(user_id);
CREATE INDEX ai_interactions_created_at_idx ON ai_interactions(created_at DESC);
CREATE INDEX ai_interactions_session_idx   ON ai_interactions(session_id);

-- ============================================================
-- AUDIT LOG (immutable — never UPDATE or DELETE)
-- ============================================================
CREATE TABLE audit_log (
    id          BIGSERIAL PRIMARY KEY,
    actor_id    UUID NULL,                -- NULL for system actions
    actor_type  TEXT NOT NULL,            -- user | service | ai-agent
    action      TEXT NOT NULL,            -- create | update | delete | escalate
    resource    TEXT NOT NULL,            -- table/entity name
    resource_id TEXT NOT NULL,
    old_value   JSONB NULL,
    new_value   JSONB NULL,
    ip_address  INET NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Partition by month for performance
-- CREATE TABLE audit_log_2026_03 PARTITION OF audit_log
--   FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');

-- ============================================================
-- AUTO-HEAL EVENTS
-- ============================================================
CREATE TABLE heal_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_source    TEXT NOT NULL,         -- prometheus | grafana | falco
    alert_name      TEXT NOT NULL,
    severity        TEXT NOT NULL,         -- critical | high | medium
    affected_service TEXT NOT NULL,
    diagnosis       TEXT NULL,             -- AI-generated diagnosis
    action_taken    TEXT NULL,             -- AI-generated action description
    confidence      NUMERIC(4,3) NULL,     -- AI confidence score
    outcome         TEXT NULL,             -- resolved | escalated | failed
    resolved_at     TIMESTAMPTZ NULL,
    escalated_at    TIMESTAMPTZ NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## Schema Migration Strategy

- Tool: **Alembic** (Python) — version-controlled migrations
- Never use `DROP COLUMN` in production — mark as deprecated, remove in next major version
- All migrations must be **reversible** (include `downgrade()`)
- Migrations run in CI pipeline before deployment (`alembic upgrade head`)
- Never modify existing migration files — always create new ones

---

## Indexing Rules

1. Always index foreign keys
2. Index any column used in `WHERE`, `ORDER BY`, or `JOIN` with > 10k rows
3. Use **partial indexes** for soft-deleted records: `WHERE deleted_at IS NULL`
4. Use **GIN indexes** for JSONB columns with frequent key lookups
5. Review `pg_stat_user_indexes` monthly — drop unused indexes
