# Threat Model — AI-NATIVE Enterprise Platform

> **Status:** Draft | **Framework:** STRIDE | **Owner:** IT Head + Security Lead
> **Review Cycle:** Quarterly

---

## Scope

This threat model covers the AI-NATIVE platform including:
- API Gateway and backend services
- AI/LLM integration layer (Claude API)
- Frontend application
- Data stores (PostgreSQL, Redis, Qdrant)
- CI/CD pipeline
- Kubernetes infrastructure

## STRIDE Threat Categories

| Category | Threat | Mitigation |
|----------|--------|------------|
| **S**poofing | Impersonation of internal services | mTLS via Istio, service accounts |
| **T**ampering | Unauthorized data modification | Signed commits, RBAC, immutable audit log |
| **R**epudiation | Denying actions taken | Centralized audit logging (OpenTelemetry) |
| **I**nformation Disclosure | Data leakage | Encryption at rest/transit, secret management |
| **D**enial of Service | Overload API / AI endpoints | Rate limiting (Kong), HPA, circuit breakers |
| **E**levation of Privilege | Gaining unauthorized access | Least-privilege RBAC, zero-trust network |

## AI-Specific Threats

| Threat | Description | Mitigation |
|--------|-------------|------------|
| **Prompt Injection** | Malicious user input hijacking AI behavior | Input sanitization, system prompt hardening, output validation |
| **Data Poisoning** | Corrupting training/retrieval data | Data validation pipeline, signed datasets |
| **Model Inversion** | Extracting training data from model | API rate limits, output filtering |
| **Indirect Prompt Injection** | Injections via retrieved documents (RAG) | Source trust levels, content filtering |
| **AI Hallucination → Action** | Agent acting on hallucinated facts | Human-in-the-loop for high-risk actions, confidence thresholds |

## Trust Boundaries

```
[Internet]
    │  (TLS 1.3)
    ▼
[API Gateway / WAF]  ← public zone
    │  (mTLS)
    ▼
[Service Mesh - Istio]  ← internal zone
    │  (RBAC + namespace isolation)
    ▼
[Backend Services]
    │  (encrypted connection)
    ▼
[Data Layer]  ← data zone (no direct internet access)
```

## High-Risk Actions (Require Human Approval)

- [ ] Database schema migrations in production
- [ ] Deploying to production (ArgoCD sync requires approval)
- [ ] Modifying IAM/RBAC policies
- [ ] AI agent actions with external side effects (sending emails, API calls to third parties)

---

## Action Items

- [ ] Complete STRIDE analysis for each service
- [ ] Define security controls per boundary
- [ ] Set up Falco for runtime threat detection
- [ ] Configure GuardDuty (AWS) for cloud threat detection
- [ ] Define incident response playbook

*See: `04-Security/Security-Controls.md` for control implementation details*
