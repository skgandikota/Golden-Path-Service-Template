# Platform Flow — Golden Path Service Template

This document explains, in plain English, how a developer goes from zero to a
production-ready microservice using the Golden Path.

---

## Overview

```
Developer
    │
    ▼
[1] Run bootstrap script (scripts/bootstrap.sh)
    │
    ▼
[2] Standardised service scaffold is generated
    │
    ▼
[3] Code is pushed → CI/CD pipeline triggers automatically
    │
    ▼
[4] Terraform provisions infrastructure
    │
    ▼
[5] Service is deployed into a controlled, observable environment
```

---

## Step-by-step Explanation

### 1. Developer Runs the Bootstrap Script

```bash
bash scripts/bootstrap.sh my-new-service
```

The script:
- Copies the `/template` folder into a new directory named after the service.
- Updates placeholder names in the copied files.
- Prints a "next steps" guide so the developer knows exactly what to do.

No manual file creation. No copy-paste mistakes. Every service starts from the
same baseline.

---

### 2. Template Generates a Standardised Service

The bootstrap produces:

| File | Purpose |
|------|---------|
| `app/main.py` | Pre-wired FastAPI app with `/health` and `/hello` endpoints |
| `Dockerfile` | Minimal, non-root container definition |
| `requirements.txt` | Pinned dependencies |

Every service is **identical at birth**. Teams only add business logic — they
never need to configure the plumbing themselves.

---

### 3. CI/CD Pipeline Automatically Configured

Pushing code to GitHub triggers the pipeline defined in `cicd/github-actions.yml`:

| Stage | What happens |
|-------|-------------|
| **Lint & Test** | `ruff` lints Python; `pytest` runs unit tests |
| **Build** | Docker image is built and smoke-tested |
| **Deploy** | Image is rolled out to the target namespace |

Developers never manually build or deploy. The pipeline enforces quality gates
automatically.

---

### 4. Infrastructure Created via Terraform

Before the service can run, its infrastructure is provisioned by code
(`infra/terraform-main.tf`):

- **Kubernetes Namespace** — isolated, labelled, managed.
- **Deployment** — replicas, resource limits, health probes, non-root security
  context.
- **Service** — internal ClusterIP endpoint.

No one SSHes into a server. No ClickOps. Infrastructure is reviewed, version-
controlled, and reproducible.

---

### 5. Service Deployed into a Controlled Environment

Once infrastructure exists and the image is built, the deployment step rolls out
the new version using a `RollingUpdate` strategy:

- Zero-downtime updates by default.
- Liveness and readiness probes ensure only healthy pods receive traffic.
- Resource limits prevent runaway memory/CPU consumption.

---

## Why This Matters

| Without Golden Path | With Golden Path |
|--------------------|-----------------|
| Days of setup per service | Minutes |
| Inconsistent structures | Identical baselines |
| Manual infrastructure | Infrastructure as Code |
| Ad-hoc pipelines | Standardised CI/CD |
| Security varies per team | Secure-by-default everywhere |

---

## Diagram — Component Relationships

```
┌──────────────────────────────────────────────────────────────┐
│                     Golden Path Template                      │
│                                                              │
│   Developer  ──▶  bootstrap.sh  ──▶  /template (scaffold)   │
│                                            │                 │
│                                     git push                 │
│                                            │                 │
│                              ┌─────────────▼──────────────┐  │
│                              │   GitHub Actions CI/CD     │  │
│                              │  lint → build → deploy     │  │
│                              └─────────────┬──────────────┘  │
│                                            │                 │
│                              ┌─────────────▼──────────────┐  │
│                              │  Terraform (IaC)           │  │
│                              │  namespace + deployment    │  │
│                              └─────────────┬──────────────┘  │
│                                            │                 │
│                              ┌─────────────▼──────────────┐  │
│                              │  Kubernetes Cluster        │  │
│                              │  (controlled environment)  │  │
│                              └────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```
