# Security Model — Golden Path Service Template

This document describes the security principles and controls built into every
service provisioned from the Golden Path template.

---

## Core Principles

### 1. No Manual Credential Sharing

Credentials are **never** passed between people, stored in chat tools, or
committed to source code.

| Instead of… | We use… |
|------------|---------|
| Sharing passwords in Slack | GitHub Actions Secrets / Vault |
| `.env` files in repositories | Runtime environment injection |
| Hard-coded API keys | Workload Identity / IRSA / Pod Identity |

All secrets are injected at runtime by the CI/CD pipeline or the Kubernetes
secrets store — developers never see or touch them.

---

### 2. Pipeline-Driven Deployments

**No human deploys directly to production.**

All changes reach the cluster through the automated CI/CD pipeline:

```
Developer pushes code
        │
        ▼
  GitHub Actions pipeline
  (lint → test → build → deploy)
        │
        ▼
  Automated deployment to Kubernetes
```

Benefits:
- Every deployment is logged and auditable.
- Quality gates (tests, linting) are mandatory — they cannot be skipped.
- Rollbacks are triggered automatically if health checks fail.
- No SSH access to nodes required.

---

### 3. Immutable Infrastructure

Infrastructure is defined in Terraform and **never mutated by hand**.

- Changes go through pull request → review → `terraform apply`.
- Drift detection can be enforced via scheduled `terraform plan`.
- Destroying and recreating resources is preferred over in-place patching.

This means the infrastructure is always in a known, reviewed state.

---

### 4. Repeatable Builds

Every build is deterministic:

- **Pinned dependencies** in `requirements.txt` (exact versions).
- **Minimal base image** (`python:3.12-slim`) — smaller attack surface.
- **Non-root container user** — the app runs as UID 1000, not root.
- **No build-time secrets** — the Docker build context never contains credentials.

The same commit SHA always produces the same image, making audits and rollbacks
reliable.

---

### 5. Least-Privilege by Default

| Layer | Control |
|-------|---------|
| Container | Non-root user (`appuser`, UID 1000) |
| Kubernetes Pod | `runAsNonRoot: true`, `runAsUser: 1000` |
| Kubernetes RBAC | Namespace-scoped service account (no cluster-admin) |
| Network | `ClusterIP` service — not exposed to the internet by default |
| Resource limits | CPU and memory limits prevent resource abuse |

---

### 6. Supply Chain Security

- Dependencies are pinned to specific versions.
- Container base images should be scanned with a tool such as Trivy or Grype
  in the CI pipeline before promotion.
- GitHub Actions use pinned action versions (`@v4`, `@v5`) to prevent
  supply-chain attacks via action tampering.

---

## Threat Model Summary

| Threat | Mitigation |
|--------|-----------|
| Leaked credentials | No secrets in code; runtime injection only |
| Unauthorised deployment | Pipeline-only deployments; branch protection |
| Vulnerable dependencies | Pinned versions; image scanning (recommended) |
| Container escape | Non-root user; read-only filesystem (recommended) |
| Lateral movement | Namespace isolation; NetworkPolicy (recommended) |
| Infrastructure drift | Terraform state; planned changes only |

---

## Recommended Hardening (Next Steps)

The following controls are **not** included in the template baseline but are
recommended before production:

- [ ] Enable `readOnlyRootFilesystem: true` in the pod security context.
- [ ] Add a Kubernetes `NetworkPolicy` to restrict pod-to-pod traffic.
- [ ] Integrate an image vulnerability scanner (Trivy, Grype) into the pipeline.
- [ ] Enable GitHub branch protection rules (require PR reviews, status checks).
- [ ] Store Terraform state in a remote backend with state locking (S3 + DynamoDB).
- [ ] Rotate all secrets on a schedule using a secrets manager (HashiCorp Vault,
  AWS Secrets Manager, etc.).

---

## Compliance Notes

This template is designed to align with common compliance frameworks:

| Framework | Relevant controls |
|-----------|-----------------|
| SOC 2 | Audit logging, access control, change management |
| ISO 27001 | Secure coding, access management, incident response |
| NIST CSF | Identify → Protect → Detect → Respond → Recover |

Consult your organisation's compliance team to confirm which controls must be
formally documented and evidenced.
