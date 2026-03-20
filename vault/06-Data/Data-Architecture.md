# Data Architecture — AI-NATIVE Platform

> Last updated: 2026-03-20

---

## Storage Layer Summary

| Store | Purpose | Technology | Scaling |
|-------|---------|-----------|---------|
| **Primary DB** | Structured business data, audit logs | PostgreSQL 16 (RDS) | Read replicas |
| **Cache** | Sessions, rate limits, hot data | Redis 7 (ElastiCache) | Cluster mode |
| **Vector DB** | AI embeddings, RAG retrieval | Qdrant (self-hosted K8s) | Horizontal sharding |
| **Object Store** | Files, model artifacts, backups | AWS S3 | Infinite |
| **Message Bus** | Event streaming, async decoupling | Apache Kafka (MSK) | Partition-based |
| **Feature Store** | ML training + serving features | Feast (online + offline) | Offline: S3+Spark |

---

## Data Flow by Type

```
User-generated data
  └─→ PostgreSQL (source of truth)
  └─→ Kafka (event stream for async consumers)
        └─→ Feature Store (ML training data)
        └─→ Audit Log (immutable append-only table)

AI-generated data
  └─→ Qdrant (embeddings from documents/knowledge base)
  └─→ PostgreSQL (AI interaction logs, eval scores)
  └─→ Arize AI (model performance telemetry)

Infrastructure telemetry
  └─→ OpenTelemetry Collector
        └─→ Grafana Mimir (metrics)
        └─→ Grafana Loki (logs)
        └─→ Grafana Tempo (traces)
```

---

## PostgreSQL Design Principles

1. **Row-level security (RLS)** — tenant isolation at DB level
2. **Audit columns on every table**: `created_at`, `updated_at`, `created_by`, `updated_by`
3. **Soft deletes** — `deleted_at TIMESTAMPTZ NULL` — never hard-delete business records
4. **UUID primary keys** — no sequential integer IDs exposed externally
5. **Read replicas** — all read-heavy API queries route to replica; writes to primary
6. **Connection pooling** — PgBouncer in front of RDS; max 20 connections per service

---

## Qdrant Collections Design

| Collection | Content | Embedding Model | Dimensions |
|-----------|---------|----------------|-----------|
| `knowledge-base` | Internal docs, runbooks, SOPs | text-embedding-3-small | 1536 |
| `user-context` | Per-user interaction history | text-embedding-3-small | 1536 |
| `code-index` | Source code for AI-assisted dev | code-embedding model | 1536 |

---

## Data Retention Policy

| Data Type | Retention | Reason |
|-----------|----------|--------|
| Business records | 7 years | Regulatory / audit |
| AI interaction logs | 1 year | Model improvement |
| Infrastructure metrics | 13 months | Trend analysis (YoY) |
| Application logs | 90 days | Debugging window |
| Session tokens | 24 hours | Security |
| Raw Kafka events | 7 days | Replay window |

---

## Encryption Standards

- **At rest:** AES-256 (RDS encryption, S3 SSE-KMS, EBS)
- **In transit:** TLS 1.3 minimum for all connections
- **Keys:** AWS KMS (customer-managed CMK, annual rotation)
- **PII fields:** Column-level encryption via pgcrypto for sensitive personal data

---

*See: [Database Schema](./Database-Schema.md) | [API Contracts](./API-Contracts/)*
