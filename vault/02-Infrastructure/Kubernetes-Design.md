# Kubernetes Design — AI-NATIVE Platform

> Last updated: 2026-03-20 | Target: AWS EKS

---

## Cluster Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  EKS Cluster: ai-native-prod                                 │
│                                                              │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │  Node Group:    │  │  Node Group:    │                   │
│  │  app-nodes      │  │  ai-nodes       │                   │
│  │  m6i.2xlarge    │  │  g5.2xlarge     │                   │
│  │  (min:3 max:10) │  │  (GPU, min:1    │                   │
│  │                 │  │   max:5)        │                   │
│  └─────────────────┘  └─────────────────┘                   │
│                                                              │
│  Namespaces:                                                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │  app     │ │  ai      │ │  data    │ │  infra   │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
└─────────────────────────────────────────────────────────────┘
```

## Namespace Design

| Namespace | Workloads | Network Policy |
|-----------|-----------|---------------|
| `app` | frontend, backend-api, api-gateway | Allow ingress from istio-gateway only |
| `ai` | ai-agent, worker | Allow egress to Claude API; deny all other external |
| `data` | PostgreSQL, Redis, Qdrant | Deny all external ingress; allow only from `app` + `ai` |
| `infra` | ArgoCD, cert-manager, external-secrets | Restricted admin access only |
| `monitoring` | Prometheus, Grafana, Loki, Tempo | Read-only access to all namespaces |
| `istio-system` | Istiod, ingress-gateway | Cluster-wide |

## Every Workload Must Have

```yaml
# Mandatory for ALL deployments
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "1000m"
    memory: "512Mi"

# Mandatory labels
labels:
  app.kubernetes.io/name: <service-name>
  app.kubernetes.io/version: <image-tag>
  app.kubernetes.io/component: backend|frontend|ai|worker
  app.kubernetes.io/part-of: ai-native
  environment: prod|staging|dev

# Mandatory probes
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /readyz
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Auto-Scaling Config

```yaml
# HPA — all stateless services
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  minReplicas: 2        # Never below 2 for HA
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

## Security Hardening (Every Pod)

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
```

## Service Mesh (Istio)

- All pod-to-pod communication uses **mTLS** (enforced via PeerAuthentication: STRICT)
- External traffic enters via **Istio Ingress Gateway** (TLS termination)
- Traffic shifting for canary deploys via **VirtualService weights**
- Circuit breaking via **DestinationRule** outlier detection

---

*See: [IaC Standards](./IaC-Standards.md) | ADR-004 Kubernetes on EKS*
