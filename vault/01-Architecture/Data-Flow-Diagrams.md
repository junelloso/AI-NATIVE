# Data Flow Diagrams — AI-NATIVE Platform

> Last updated: 2026-03-20

---

## Flow 1: User AI Request (RAG Pattern)

```mermaid
sequenceDiagram
  participant U  as User (Browser)
  participant FE as Frontend (Next.js)
  participant GW as API Gateway (Kong)
  participant API as Backend API (FastAPI)
  participant AG as AI Agent (Claude SDK)
  participant QD as Qdrant (Vector DB)
  participant CL as Claude API

  U->>FE: Submit question / task
  FE->>GW: POST /api/v1/ai/query (JWT)
  GW->>API: Rate check + route (mTLS)
  API->>AG: Dispatch AI task
  AG->>QD: Semantic search (embed query → top-k chunks)
  QD-->>AG: Relevant context chunks
  AG->>CL: claude-sonnet-4-6 + system prompt + context
  CL-->>AG: Streamed response tokens
  AG-->>API: SSE stream
  API-->>GW: SSE stream
  GW-->>FE: SSE stream
  FE-->>U: Real-time streamed response
  AG->>API: Log trace (eval score, latency, tokens)
  API->>API: Persist to PostgreSQL audit log
```

---

## Flow 2: Auto-Heal Trigger

```mermaid
sequenceDiagram
  participant PROM as Prometheus
  participant AM   as Alertmanager
  participant AG   as AI Agent (Auto-Heal)
  participant K8S  as Kubernetes API
  participant ARGO as ArgoCD
  participant PD   as PagerDuty

  PROM->>AM: Alert: error_rate > 5% for 2m
  AM->>AG: POST /heal (alert payload)
  AG->>AG: Diagnose — check recent deploys, logs, metrics
  alt Confidence >= 80%
    AG->>K8S: Restart failing pods
    AG->>ARGO: Trigger rollback if new deploy detected
    AG->>PROM: Verify SLO recovery (poll 60s)
    PROM-->>AG: SLO restored
    AG->>AG: Log heal action to audit trail
  else Confidence < 80%
    AG->>PD: Page oncall with full diagnosis context
  end
```

---

## Flow 3: CI/CD Pipeline (Push to Develop)

```mermaid
flowchart LR
  A[git push to develop] --> B[GitHub Actions triggered]
  B --> C{Lint + Tests}
  C -->|fail| Z[Block — notify developer]
  C -->|pass| D[SAST: Semgrep + Gitleaks]
  D -->|critical finding| Z
  D -->|clean| E[Docker build]
  E --> F[Trivy container scan]
  F -->|critical CVE| Z
  F -->|clean| G[Push image to ECR]
  G --> H[Update Helm values in Git]
  H --> I[ArgoCD detects diff]
  I --> J[Deploy to staging]
  J --> K[Smoke tests]
  K -->|fail| L[Auto-rollback staging]
  K -->|pass| M[Staging deploy complete]
```

---

## Flow 4: Auto-Learn Pipeline

```mermaid
flowchart TD
  A[Production AI responses] -->|OTel events| B[Kafka topic: ai-events]
  B --> C[Feature Store: Feast]
  C --> D[Eval Engine: Arize AI]
  D -->|score drop / drift| E{Drift detected?}
  E -->|No| F[Continue monitoring]
  E -->|Yes| G[Retrain trigger: GitHub Actions]
  G --> H[Retrain on new data]
  H --> I[MLflow: register new model version]
  I --> J[Shadow test: 5% traffic]
  J -->|regression| K[Discard version]
  J -->|improvement| L[Canary: 20% traffic]
  L -->|stable 30min| M[Full rollout: 100%]
  M --> N[Update RAG index in Qdrant]
```
