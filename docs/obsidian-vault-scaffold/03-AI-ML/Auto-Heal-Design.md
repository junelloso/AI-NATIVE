# Auto-Heal Design

> **Status:** Draft | **Phase:** 4 (implementation), informing Phase 0 architecture

---

## Concept

Auto-heal means the system detects anomalies, failures, or degradation and **corrects itself without human intervention**.

## Layers of Auto-Heal

```
┌─────────────────────────────────────────────────────┐
│  Layer 4: Business Logic Heal                        │
│  → Claude Agent detects data/logic anomalies         │
│  → Auto-corrects or escalates with context           │
├─────────────────────────────────────────────────────┤
│  Layer 3: Application Heal                           │
│  → Pod restart, circuit breaker, retry with backoff  │
│  → Canary rollback via ArgoCD                        │
├─────────────────────────────────────────────────────┤
│  Layer 2: Platform Heal                              │
│  → Kubernetes HPA/VPA auto-scaling                   │
│  → Node auto-repair (GKE/EKS managed node groups)   │
│  → Keptn SLO-based remediation                       │
├─────────────────────────────────────────────────────┤
│  Layer 1: Infrastructure Heal                        │
│  → Terraform drift detection + auto-apply            │
│  → Self-healing IaC via ArgoCD GitOps                │
└─────────────────────────────────────────────────────┘
```

## Auto-Heal Signal Sources

| Signal | Source | Action |
|--------|--------|--------|
| Latency spike | OpenTelemetry → Grafana | Scale out, alert, rollback |
| Error rate > threshold | Prometheus alert | Circuit break + rollback |
| Pod OOMKilled | Kubernetes events | VPA recommendation + restart |
| IaC drift detected | Terraform plan | Auto-apply or PR for review |
| Security anomaly | Falco / GuardDuty | Isolate + page oncall |
| AI model degradation | Arize AI eval score drop | Rollback model version |

## Claude Agent Auto-Heal Role

```python
# Conceptual — Claude agent monitors and heals
agent = ClaudeAgent(
    model="claude-sonnet-4-6",
    tools=[
        kubectl_tool,        # restart pods, scale deployments
        argo_rollback_tool,  # trigger ArgoCD rollback
        pagerduty_tool,      # escalate if auto-heal fails
        runbook_tool,        # fetch and execute runbook steps
    ],
    system_prompt="You are an SRE auto-heal agent. Diagnose and fix production issues autonomously. Escalate only if confidence < 80%."
)
```

## Escalation Policy

```
Auto-heal attempt → Success? → Log + close
                 → Fail?    → Retry (max 3) → Escalate to oncall with full context
```

---

*See: ADR-XXX — Auto-Heal Engine Selection (Keptn vs custom)*
