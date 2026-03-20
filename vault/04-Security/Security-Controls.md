# Security Controls — AI-NATIVE Platform

> Framework: Zero-Trust | Last updated: 2026-03-20

---

## Zero-Trust Principles Applied

| Principle | Implementation |
|-----------|---------------|
| Never trust, always verify | Every request re-authenticated; mTLS between all services |
| Least privilege | RBAC scoped per namespace; no wildcard permissions |
| Assume breach | Network segmentation; blast radius minimization via namespaces |
| Verify explicitly | JWT + service identity (SPIFFE/SVID) for every call |

---

## Controls by Layer

### 1. Network Layer
| Control | Tool | Config |
|---------|------|--------|
| Ingress WAF | Kong + AWS WAF | OWASP Core Rule Set enabled |
| mTLS everywhere | Istio (STRICT mode) | PeerAuthentication: STRICT in all namespaces |
| Network Policies | Kubernetes NetworkPolicy | Default-deny; explicit allow rules only |
| DDoS protection | AWS Shield Standard | Enabled on all public load balancers |
| Private cluster | EKS private endpoint | API server not publicly accessible |

### 2. Identity & Access
| Control | Tool | Config |
|---------|------|--------|
| Human auth | OAuth 2.0 + OIDC | Okta / Azure AD |
| API auth | JWT (RS256, 15min expiry) | Refresh token rotation |
| Service identity | SPIFFE/SVID via Istio | Auto-rotated every 24h |
| K8s RBAC | Namespace-scoped roles | No ClusterAdmin in production |
| Cloud IAM | AWS IAM roles | IRSA (IAM Roles for Service Accounts) — no static keys |

### 3. Secrets Management
| Control | Tool | Config |
|---------|------|--------|
| Secret storage | HashiCorp Vault | Transit encryption, audit logging |
| K8s secret injection | External Secrets Operator | Vault → K8s Secret sync |
| DB credential rotation | Vault Dynamic Secrets | PostgreSQL creds rotate every 30 days |
| Pre-commit scanning | Gitleaks | Blocks commit if secret pattern detected |
| CI scanning | Trufflehog | Scans full git history on PR |

### 4. Application Layer
| Control | Tool | Config |
|---------|------|--------|
| SAST | Semgrep | Rules: security, owasp-top-10, secrets |
| Dependency scan | Dependabot + Trivy | Daily scan; auto-PR for patches |
| Container scan | Trivy | Blocks deploy on CRITICAL CVEs |
| SBOM | Syft | Generated per image, stored in ECR |
| DAST | OWASP ZAP | Runs against staging before prod promotion |
| Input validation | Pydantic (FastAPI) | All external inputs validated at boundary |
| SQL injection | SQLAlchemy ORM | Parameterized queries only — no raw SQL |
| XSS | Next.js + CSP headers | Strict Content-Security-Policy |

### 5. AI-Specific Controls
| Control | Implementation |
|---------|---------------|
| Prompt injection defense | Input sanitization + output validation; system prompt locked |
| Agent action limits | High-risk actions require `confidence >= 0.95` + human flag |
| RAG source trust | Documents tagged with trust level; low-trust sources filtered |
| Output filtering | PII detection before returning AI responses to UI |
| Rate limiting | Per-user token budget; circuit breaker at 1000 tokens/min |
| Hallucination guard | Fact-check tool call for claims about real-world data |

### 6. Runtime & Observability
| Control | Tool | Config |
|---------|------|--------|
| Runtime threat detection | Falco | Custom rules for container escape, privilege escalation |
| Cloud threat detection | AWS GuardDuty | Enabled in all regions |
| Audit logging | PostgreSQL audit_log table + CloudTrail | Immutable, 7-year retention |
| Vulnerability alerts | AWS Security Hub | Aggregates Trivy + GuardDuty + Inspector |
| Incident response | PagerDuty + Runbooks | Auto-heal first; escalate with full context |

---

## Security Review Gates

| Gate | When | Blocker? |
|------|------|---------|
| Gitleaks pre-commit | Every commit | Yes |
| Semgrep SAST | Every PR | Yes — Critical/High |
| Trivy container scan | Every build | Yes — Critical CVE |
| Dependency audit | Every PR | Yes — Critical CVE |
| DAST scan | Pre-prod promotion | Yes — High findings |
| Manual pen test | Quarterly | No (tracked as issues) |

---

*See: [Threat Model](./Threat-Model.md) | [Compliance Matrix](./Compliance-Matrix.md)*
