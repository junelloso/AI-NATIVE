# System Context Diagram — AI-NATIVE Platform

> **C4 Level 1** | Last updated: 2026-03-20

---

## Overview

The AI-NATIVE platform is an enterprise application where AI is embedded at every layer — not bolted on. It serves internal users, automated agents, and external integrations.

```mermaid
C4Context
  title AI-NATIVE Enterprise Platform — System Context

  Person(user, "Business User", "Uses the AI-native web application for enterprise workflows")
  Person(admin, "IT Admin / Operator", "Manages platform, monitors health, reviews AI actions")
  Person(developer, "Developer", "Builds features via CI/CD, queries Claude Code with vault context")

  System_Boundary(ai_native, "AI-NATIVE Platform") {
    System(app, "AI-NATIVE Application", "Enterprise web app with embedded AI — auto-heal, auto-learn, zero-trust")
  }

  System_Ext(claude_api, "Anthropic Claude API", "LLM inference — claude-sonnet-4-6 / claude-opus-4-6")
  System_Ext(github, "GitHub", "Source code, CI/CD triggers, branch-protected main")
  System_Ext(aws, "AWS (EKS)", "Cloud infrastructure — compute, networking, managed services")
  System_Ext(vault, "HashiCorp Vault", "Secrets management — API keys, DB passwords, certs")
  System_Ext(pagerduty, "PagerDuty", "Incident escalation when auto-heal cannot resolve")

  Rel(user, app, "Uses", "HTTPS / WebSocket")
  Rel(admin, app, "Operates & monitors", "HTTPS")
  Rel(developer, app, "Deploys via", "GitHub Actions + ArgoCD")

  Rel(app, claude_api, "LLM inference", "HTTPS / REST")
  Rel(app, aws, "Runs on", "Kubernetes / EKS")
  Rel(app, vault, "Fetches secrets", "mTLS")
  Rel(app, pagerduty, "Escalates incidents", "HTTPS")
  Rel(github, app, "Triggers deployments", "GitOps / ArgoCD")
```

---

## Key Design Decisions at This Level

| Decision | Choice | Rationale |
|----------|--------|-----------|
| LLM provider | Anthropic Claude API | Best-in-class reasoning; Claude Agent SDK for orchestration |
| Cloud | AWS EKS primary | Managed K8s, mature ecosystem, team familiarity |
| Secrets | HashiCorp Vault | Zero secrets in env vars or config files |
| GitOps | ArgoCD | Pull-based deployment; audit trail in Git |

---

*Next level of detail: [Container Diagram](./Container-Diagram.md)*
