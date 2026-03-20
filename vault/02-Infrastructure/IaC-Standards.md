# Infrastructure-as-Code Standards

> Last updated: 2026-03-20 | Tool: Terraform + Helm

---

## Terraform Standards

### Module Structure
```
infra/terraform/
├── modules/
│   ├── eks-cluster/       # Reusable EKS module
│   ├── rds-postgres/      # RDS PostgreSQL module
│   ├── elasticache/       # Redis module
│   └── networking/        # VPC, subnets, SGs
├── environments/
│   ├── dev/               # Dev tfvars + backend config
│   ├── staging/
│   └── prod/
└── global/                # IAM, Route53, ACM (shared across envs)
```

### Mandatory Rules

```hcl
# 1. Tag EVERYTHING
locals {
  common_tags = {
    Project     = "ai-native"
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "infra-team"
    CostCenter  = "engineering"
  }
}

# 2. Remote state — NEVER local
terraform {
  backend "s3" {
    bucket         = "ai-native-tfstate"
    key            = "prod/eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "ai-native-tflock"
  }
}

# 3. Lock provider versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.7"
}
```

### Drift Detection

- CI runs `terraform plan` on every PR to `infra/` path
- Daily scheduled `terraform plan` in GitHub Actions
- Deviations from expected plan fail the check and alert the infra team
- **Auto-apply** only for non-critical resources (tags, scaling params)
- **Manual approval** required for: VPC changes, IAM, security groups, RDS

---

## Helm Standards

### Chart Structure
```
infra/helm/
└── ai-native/
    ├── Chart.yaml
    ├── values.yaml              # Defaults (no secrets)
    ├── values-staging.yaml      # Staging overrides
    ├── values-prod.yaml         # Prod overrides
    └── templates/
        ├── deployment.yaml
        ├── service.yaml
        ├── hpa.yaml
        ├── pdb.yaml             # PodDisruptionBudget — always include
        ├── servicemonitor.yaml  # Prometheus scraping
        └── _helpers.tpl
```

### Mandatory: PodDisruptionBudget
```yaml
# Ensure at least 1 pod is always available during node drain
apiVersion: policy/v1
kind: PodDisruptionBudget
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ .Values.name }}
```

---

## Secrets Management — Non-Negotiable Rules

| Rule | Detail |
|------|--------|
| No secrets in Terraform state | Use `aws_secretsmanager_secret` reference, never `value` |
| No secrets in Helm values | Use External Secrets Operator → Vault |
| No secrets in container env | Mount from Kubernetes Secret (populated by ESO) |
| No secrets in Git | Pre-commit hook: Gitleaks scan blocks commit |
| Rotation | All DB passwords auto-rotate every 30 days via Vault |

### External Secrets Operator Flow
```
HashiCorp Vault
      │  (Vault auth via K8s ServiceAccount)
      ▼
External Secrets Operator
      │  (creates/syncs)
      ▼
Kubernetes Secret
      │  (mounted as env or volume)
      ▼
Pod
```
