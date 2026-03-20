# CI/CD Pipeline Design

> **Stack:** GitHub Actions (CI) + ArgoCD (CD) + GitOps

---

## Pipeline Overview

```
Developer Push / PR
        │
        ▼
┌───────────────────────────────────────────────────┐
│  GitHub Actions — CI Pipeline                      │
│                                                    │
│  1. Lint & Format check (ruff, eslint, prettier)  │
│  2. Unit tests (pytest, vitest)                   │
│  3. SAST scan (Semgrep)                           │
│  4. Container build (Docker)                      │
│  5. Container scan (Trivy)                        │
│  6. SBOM generation (Syft)                        │
│  7. Integration tests                             │
│  8. Push image to registry (ECR)                  │
│  9. Update Helm values (triggers ArgoCD)          │
└──────────────────┬────────────────────────────────┘
                   │  (GitOps: manifest updated in Git)
                   ▼
┌───────────────────────────────────────────────────┐
│  ArgoCD — CD Pipeline                             │
│                                                    │
│  Staging: Auto-sync (on merge to develop)         │
│  Production: Manual approval required             │
│  Rollback: One-click or auto (SLO breach)         │
└───────────────────────────────────────────────────┘
```

## Security Gates (Mandatory — Cannot be bypassed)

| Gate | Tool | Failure Action |
|------|------|---------------|
| SAST | Semgrep | Block PR merge |
| Secrets scan | GitLeaks | Block PR merge |
| Container vuln (Critical) | Trivy | Block deployment |
| License check | FOSSA | Warn + flag |
| DAST (staging only) | OWASP ZAP | Block prod promotion |

## Branch → Environment Mapping

| Branch | Environment | Auto-deploy? | Approval? |
|--------|------------|-------------|-----------|
| `feature/*` | PR preview | Yes | No |
| `develop` | Staging | Yes | No |
| `main` | Production | No | Yes (2 approvals) |

## Rollback Strategy

1. **Automatic:** If SLO breach detected within 10 min of deploy → ArgoCD auto-rollback
2. **Manual:** `argocd app rollback ai-native-api --revision <N>`
3. **Emergency:** Disable feature flag → reduces blast radius without full rollback

---

*See: `05-DevSecOps/Runbooks/` for operational procedures*
