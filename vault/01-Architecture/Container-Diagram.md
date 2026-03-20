# Container Diagram — AI-NATIVE Platform

> **C4 Level 2** | Last updated: 2026-03-20

---

```mermaid
C4Container
  title AI-NATIVE Platform — Container Diagram

  Person(user, "Business User")
  Person(admin, "IT Admin / Operator")

  System_Ext(claude_api, "Anthropic Claude API")
  System_Ext(github,     "GitHub / ArgoCD")

  System_Boundary(ai_native, "AI-NATIVE Platform (Kubernetes / EKS)") {

    Container(frontend,    "Frontend",          "Next.js 15 + React 19",  "Server-side rendered UI. Streams AI responses via SSE.")
    Container(api,         "Backend API",       "Python / FastAPI",        "REST + WebSocket API. JWT auth. Business logic.")
    Container(ai_agent,    "AI Agent Service",  "Claude Agent SDK",        "Orchestrates multi-step AI tasks. Auto-heal + auto-learn loops.")
    Container(worker,      "Background Worker", "Python / Celery",         "Async tasks — data ingestion, model eval, scheduled jobs.")

    ContainerDb(postgres,  "PostgreSQL",        "Database",                "Primary relational store. Audit logs.")
    ContainerDb(redis,     "Redis",             "Cache / Queue",           "Session cache. Celery broker. Rate-limit counters.")
    ContainerDb(qdrant,    "Qdrant",            "Vector Database",         "Embeddings for RAG and semantic search.")

    Container(gateway,     "API Gateway",       "Kong",                    "Rate limiting, auth, routing, WAF rules.")
    Container(observability,"Observability",    "OTel + Grafana Stack",    "Traces, metrics, logs. SLO dashboards.")
  }

  Rel(user,        frontend,     "Uses",              "HTTPS")
  Rel(admin,       observability,"Monitors",          "HTTPS")
  Rel(frontend,    gateway,      "API calls",         "HTTPS")
  Rel(gateway,     api,          "Routes to",         "mTLS / HTTP2")
  Rel(api,         ai_agent,     "Delegates AI tasks","gRPC / internal")
  Rel(api,         postgres,     "Reads/writes",      "TLS")
  Rel(api,         redis,        "Cache + queue",     "TLS")
  Rel(ai_agent,    claude_api,   "LLM inference",     "HTTPS")
  Rel(ai_agent,    qdrant,       "Vector search",     "gRPC")
  Rel(worker,      postgres,     "Batch jobs",        "TLS")
  Rel(worker,      redis,        "Task queue",        "TLS")
  Rel(api,         observability,"Emits telemetry",   "OTel gRPC")
  Rel(ai_agent,    observability,"Emits AI traces",   "OTel gRPC")
  Rel(github,      api,          "GitOps deploy",     "ArgoCD pull")
```

---

## Container Responsibilities

| Container | Owns | Does NOT own |
|-----------|------|-------------|
| **Frontend** | UI rendering, SSE streaming, client-side state | Business logic, DB access |
| **Backend API** | Auth, business logic, data validation | AI orchestration, long-running tasks |
| **AI Agent Service** | Multi-step AI workflows, RAG, auto-heal triggers | User auth, UI concerns |
| **Background Worker** | Async jobs, model eval, data pipelines | Serving synchronous API requests |
| **API Gateway** | Rate limiting, WAF, TLS termination | Application logic |

---

## Communication Protocols

| From → To | Protocol | Auth |
|-----------|----------|------|
| User → Frontend | HTTPS/WSS | Session cookie |
| Frontend → Gateway | HTTPS | JWT Bearer |
| Gateway → API | mTLS (Istio) | SPIFFE/SVID |
| API → AI Agent | gRPC (internal) | mTLS (Istio) |
| API → Databases | TLS | Vault-rotated credentials |
| AI Agent → Claude API | HTTPS | API key (from Vault) |

---

*Next level: [Component Diagram](./Component-Diagram.md) | [Data Flow](./Data-Flow-Diagrams.md)*
