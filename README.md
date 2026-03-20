# AI-NATIVE Enterprise Application Platform

> **Role:** IT Head / Solutions Architect
> **Scope:** Ground-up, mission-critical, AI-native enterprise application
> **Principles:** Auto-heal · Auto-learn · DevSecOps · Shift-left Security

---

## Table of Contents

1. [Vision & Guiding Principles](#1-vision--guiding-principles)
2. [Technology Stack Overview](#2-technology-stack-overview)
3. [Documentation Strategy: Obsidian + Claude MCP](#3-documentation-strategy-obsidian--claude-mcp)
4. [Claude Code MCP Setup (Local)](#4-claude-code-mcp-setup-local)
5. [Repository & Team Structure](#5-repository--team-structure)
6. [Phase Roadmap](#6-phase-roadmap)
7. [Getting Started Checklist](#7-getting-started-checklist)

---

## 1. Vision & Guiding Principles

| Principle        | Definition |
|-----------------|------------|
| **AI-Native**   | AI is not an add-on; it is embedded in every layer — UI, API, data, infra, observability |
| **Auto-heal**   | Self-detecting, self-correcting infrastructure and application services with zero manual intervention |
| **Auto-learn**  | Continuous model retraining from production signals; policy and config drift correction via RL feedback loops |
| **Shift-left Security** | Security gates at IDE, PR, CI/CD — not post-deployment |
| **Docs-as-Code** | All technical documentation lives in version-controlled, machine-readable format (Obsidian vault → Git) |

---

## 2. Technology Stack Overview

### Infrastructure & Platform
| Layer | Technology |
|-------|-----------|
| Cloud | Multi-cloud (AWS primary + GCP for AI workloads) |
| Container Orchestration | Kubernetes (EKS/GKE) + Helm |
| Service Mesh | Istio (mTLS, traffic management, observability) |
| GitOps | ArgoCD + Flux |
| IaC | Terraform + Pulumi (AI-generated drift correction) |
| Secret Management | HashiCorp Vault |

### Application Core
| Layer | Technology |
|-------|-----------|
| Backend API | Python (FastAPI) or Go (Gin) — TBD per service |
| Frontend | Next.js 15 + React 19 (App Router) |
| Database | PostgreSQL (primary) + Redis (cache) + Qdrant (vector) |
| Message Bus | Apache Kafka |
| API Gateway | Kong or AWS API Gateway |

### AI / ML Platform
| Component | Technology |
|-----------|-----------|
| LLM Integration | Anthropic Claude API (claude-sonnet-4-6 default) |
| AI Orchestration | Claude Agent SDK |
| Vector Search | Qdrant |
| Model Registry | MLflow |
| Feature Store | Feast |
| Observability | Arize AI / WhyLabs |

### DevSecOps
| Component | Technology |
|-----------|-----------|
| CI/CD | GitHub Actions + ArgoCD |
| SAST/DAST | Semgrep, OWASP ZAP |
| Container Scan | Trivy + Grype |
| SBOM | Syft |
| Observability | OpenTelemetry + Grafana Stack (Loki, Tempo, Mimir) |
| Incident Auto-heal | Keptn + custom Claude agent |

---

## 3. Documentation Strategy: Obsidian + Claude MCP

### Why Obsidian Locally (Not NotebookLM)
- NotebookLM has **no API** — Claude cannot read it directly
- Obsidian stores docs as **plain Markdown files** on disk
- Claude Code reads your vault via **MCP Filesystem Server** — no upload, no cloud dependency
- Your vault can later be **pushed to a private Git repo** for team sharing

### Obsidian Vault Location (Recommended)
```
~/obsidian-vault/AI-NATIVE/
```

### Vault Structure
```
~/obsidian-vault/AI-NATIVE/
├── 00-Overview/
│   ├── Project-Charter.md
│   ├── Architecture-Decision-Records/   # ADRs
│   └── Stakeholder-Map.md
├── 01-Architecture/
│   ├── System-Context-Diagram.md
│   ├── Container-Diagram.md            # C4 model
│   ├── Component-Diagram.md
│   └── Data-Flow-Diagrams.md
├── 02-Infrastructure/
│   ├── Network-Topology.md
│   ├── Kubernetes-Design.md
│   ├── IaC-Standards.md
│   └── Disaster-Recovery.md
├── 03-AI-ML/
│   ├── Model-Strategy.md
│   ├── Auto-Heal-Design.md
│   ├── Auto-Learn-Pipeline.md
│   └── Prompt-Engineering-Standards.md
├── 04-Security/
│   ├── Threat-Model.md
│   ├── Security-Controls.md
│   ├── Compliance-Matrix.md
│   └── Zero-Trust-Design.md
├── 05-DevSecOps/
│   ├── CICD-Pipeline-Design.md
│   ├── Branch-Strategy.md
│   ├── Release-Process.md
│   └── Runbooks/
├── 06-Data/
│   ├── Data-Architecture.md
│   ├── Database-Schema.md
│   ├── Data-Governance.md
│   └── API-Contracts/
├── 07-Team/
│   ├── Team-Structure.md
│   ├── RACI-Matrix.md
│   ├── Onboarding.md
│   └── Coding-Standards.md
└── 08-Decisions/
    ├── ADR-001-Language-Choice.md
    ├── ADR-002-Database-Selection.md
    └── ADR-template.md
```

---

## 4. Claude Code MCP Setup (Local)

Claude Code connects to your local Obsidian vault via the **MCP Filesystem Server**.
This means Claude reads your docs in real-time during sessions — no copy-paste needed.

### Step 1: Install MCP Filesystem Server

```bash
npm install -g @modelcontextprotocol/server-filesystem
```

### Step 2: Configure Claude Code MCP

Edit or create `~/.claude/settings.json` (global) or `.claude/settings.json` (per-project):

```json
{
  "mcpServers": {
    "obsidian-docs": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/YOUR_USERNAME/obsidian-vault/AI-NATIVE"
      ],
      "description": "AI-NATIVE technical documentation vault"
    },
    "project-code": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/home/user/AI-NATIVE"
      ],
      "description": "AI-NATIVE source code repository"
    }
  }
}
```

> Replace `/Users/YOUR_USERNAME/` with your actual home path (e.g., `/home/yourname/` on Linux).

### Step 3: Add Database MCP (Later — when DB is ready)

```json
"postgres-db": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-postgres"],
  "env": {
    "POSTGRES_CONNECTION_STRING": "postgresql://user:pass@localhost:5432/ai_native_db"
  }
}
```

### Step 4: Add GitHub MCP (For team repo access)

```json
"github": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_YOUR_TOKEN"
  }
}
```

### Verify MCP is Connected

In a Claude Code session, type:
```
/mcp
```
You should see `obsidian-docs` and `project-code` listed as connected servers.

---

## 5. Repository & Team Structure

```
AI-NATIVE/                          # This repo (monorepo or mono-root)
├── .claude/
│   ├── settings.json               # MCP server config (team-shared, no secrets)
│   └── settings.local.json         # Personal overrides (gitignored)
├── CLAUDE.md                       # Claude project context (auto-loaded)
├── docs/                           # Lightweight repo docs (links to Obsidian)
├── services/
│   ├── api/                        # Backend API service
│   ├── frontend/                   # Next.js frontend
│   ├── ai-agent/                   # Claude Agent SDK orchestration
│   └── data-pipeline/              # ML/data ingestion
├── infra/
│   ├── terraform/
│   ├── kubernetes/
│   └── helm/
└── .github/
    └── workflows/                  # CI/CD pipelines
```

### Team Onboarding (Share this repo)
1. Clone repo
2. Copy `.claude/settings.json` — update vault path to their local Obsidian clone
3. `npm install -g @modelcontextprotocol/server-filesystem`
4. Open Claude Code in project root — MCP connects automatically

---

## 6. Phase Roadmap

| Phase | Focus | Deliverable |
|-------|-------|-------------|
| **Phase 0** (Now) | Architecture & Documentation Setup | Obsidian vault + Claude MCP + ADRs |
| **Phase 1** | Core Platform & DevSecOps Pipeline | CI/CD + IaC + Base Kubernetes |
| **Phase 2** | Application Skeleton | API + Frontend + Auth |
| **Phase 3** | AI-Native Layer | Claude Agent integration + Vector DB |
| **Phase 4** | Auto-heal & Auto-learn | Observability + RL feedback + Keptn |
| **Phase 5** | Security Hardening & Compliance | Zero-trust + SAST/DAST + Audit |
| **Phase 6** | Production Launch | Load test + DR drill + Go-live |

---

## 7. Getting Started Checklist

### As IT Head (You — Today)

- [ ] Install Obsidian Desktop: https://obsidian.md
- [ ] Create vault at `~/obsidian-vault/AI-NATIVE/` using the structure above
- [ ] Copy your existing technical designs into the vault as Markdown files
- [ ] Install MCP Filesystem Server: `npm install -g @modelcontextprotocol/server-filesystem`
- [ ] Configure `.claude/settings.json` in this repo (see Section 4)
- [ ] Run `/mcp` in Claude Code to verify connection
- [ ] Start refining architecture using Claude with live vault access

### As Team Lead (Before Team Assignment)

- [ ] Define ADRs for key technology choices
- [ ] Complete threat model (`04-Security/Threat-Model.md`)
- [ ] Define coding standards (`07-Team/Coding-Standards.md`)
- [ ] Set up GitHub repo with branch protection rules
- [ ] Configure CI/CD skeleton pipeline
- [ ] Create team onboarding guide

---

## Notes on Obsidian → Git Sync (For Team)

Obsidian files are plain Markdown. Options to share with team:

| Option | How |
|--------|-----|
| **Private Git Repo** | Push `~/obsidian-vault/AI-NATIVE/` to a private GitHub/GitLab repo. Team clones locally and uses with Obsidian. |
| **Git Submodule** | Add the vault repo as a submodule inside `AI-NATIVE/docs/` |
| **Obsidian Git Plugin** | Auto-commit/push vault changes on save (recommended for solo phase) |

> **Security Note:** Never commit secrets, credentials, or PII to the Obsidian vault or this repo. Use `.gitignore` and HashiCorp Vault for secrets.
