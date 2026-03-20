# Claude Project Context — AI-NATIVE Enterprise Platform

This file is automatically loaded by Claude Code at the start of every session.
It gives Claude persistent context about this project without manual re-explanation.

---

## Project Identity

- **Name:** AI-NATIVE Enterprise Application Platform
- **Type:** Mission-critical, AI-native, enterprise-grade
- **Owner:** IT Head / Solutions Architect
- **Stage:** Phase 0 — Architecture & Documentation Setup

## My Role & What I Need Claude For

I am the IT Head and Solutions Architect responsible for both Infrastructure/Hardware and Software Development teams.

I use Claude to:
1. Refine and improve architecture designs before assigning to team
2. Review and generate technical documentation
3. Write and review Infrastructure-as-Code (Terraform, Helm, Kubernetes manifests)
4. Review application code across the stack (Python/FastAPI, Next.js, Go)
5. Enforce DevSecOps practices — security scanning, CI/CD pipelines
6. Design and implement Auto-heal and Auto-learn AI patterns
7. Onboard and guide the AI DevSecOps team

## Technology Stack (Decisions Made)

- **LLM:** Anthropic Claude API — `claude-sonnet-4-6` (default), `claude-opus-4-6` (complex reasoning)
- **AI SDK:** Claude Agent SDK for orchestration
- **Backend:** Python + FastAPI (primary), Go (performance-critical microservices)
- **Frontend:** Next.js 15 + React 19
- **Database:** PostgreSQL + Redis + Qdrant (vector)
- **Infra:** Kubernetes (EKS) + Terraform + Helm + ArgoCD
- **Observability:** OpenTelemetry + Grafana Stack
- **Security:** Zero-trust, Istio mTLS, HashiCorp Vault, Trivy, Semgrep

## Documentation

Technical documentation lives in an **Obsidian vault** at `~/obsidian-vault/AI-NATIVE/`.
Claude can access it via the `obsidian-docs` MCP server (see `.claude/settings.json`).

When I refer to "the docs" or "the vault", read from the MCP-connected Obsidian filesystem.

## Key Principles — Always Apply

1. **AI-Native first:** Every design decision should consider how AI augments or automates it
2. **Security by default:** Apply zero-trust, least-privilege, and shift-left security always
3. **Auto-heal:** Infrastructure and services must self-recover — design for failure
4. **Auto-learn:** Systems must improve from production signals — design feedback loops
5. **Docs-as-Code:** All decisions get an ADR; all designs get a diagram
6. **No over-engineering:** Start simple, validate, then scale

## Team Context

- This is a DevSecOps team. All members use Claude Code with this shared config.
- Never commit secrets. Use `.env.example` patterns and HashiCorp Vault references.
- Branch strategy: `main` (protected) → `develop` → `feature/`, `fix/`, `infra/`, `docs/`
- All AI/ML code must include observability hooks (traces, metrics, eval scores)

## Code Style Preferences

- Python: follow PEP 8, use `ruff` for linting, `mypy` for types, `pytest` for tests
- TypeScript/JS: strict mode, ESLint + Prettier, Vitest for tests
- Terraform: use modules, tag all resources, remote state in S3
- Kubernetes: always set resource limits, use namespaces, label everything
- Security: never hardcode credentials; validate all external inputs; parameterize queries

## ADR Process

Before implementing any significant technology choice:
1. Create `~/obsidian-vault/AI-NATIVE/08-Decisions/ADR-XXX-title.md`
2. Follow the ADR template
3. Get review before proceeding

## Current Active Tasks (Phase 0)

- [x] Finalize system architecture diagrams → `vault/01-Architecture/`
- [x] Complete threat model → `vault/04-Security/Threat-Model.md` + `Security-Controls.md`
- [x] Define coding standards and team onboarding → `vault/07-Team/`
- [x] Set up CI/CD skeleton → `.github/workflows/` (ci, cd-staging, cd-production, security-scan)
- [x] Configure MCP connections → `.claude/settings.json` (obsidian-docs + project-code live)
- [ ] PostgreSQL MCP — enable when DB is provisioned (Phase 1)
- [ ] GitHub MCP — enable when PAT is added to `settings.local.json` (Phase 1)

## Phase 0 Complete → Phase 1 Next

Phase 1 tasks:
- [ ] Provision AWS infrastructure (VPC, EKS, RDS, ElastiCache, Qdrant)
- [ ] Deploy Istio service mesh
- [ ] Bootstrap HashiCorp Vault
- [ ] Create service skeletons: `services/api/`, `services/frontend/`, `services/ai-agent/`
- [ ] First working CI/CD run on a real service
