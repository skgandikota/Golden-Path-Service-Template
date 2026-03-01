# Golden Path Service Template

👉 A self-service template that lets a developer create a secure microservice with CI/CD in minutes.

---

## Repository Structure

```
golden-path-service-template/
│
├── README.md
├── architecture/
│   └── platform-flow.md        # End-to-end platform flow explanation
│
├── template/
│   ├── app/
│   │   └── main.py             # Hello Platform FastAPI service
│   ├── Dockerfile              # Minimal, non-root container definition
│   └── requirements.txt        # Pinned Python dependencies
│
├── cicd/
│   └── github-actions.yml      # Build → Lint/Test → Deploy pipeline
│
├── infra/
│   └── terraform-main.tf       # Kubernetes namespace + deployment (IaC)
│
├── docs/
│   ├── onboarding-guide.md     # Developer quick-start guide
│   └── security-model.md       # Security principles and controls
│
└── scripts/
    └── bootstrap.sh            # Service scaffold generator
```

---

## Problem

Developers often spend days configuring:

- Project structure
- CI/CD pipelines
- Security settings
- Infrastructure
- Observability

This leads to **inconsistency** and **security risk** across teams.

---

## Solution

Provide a Golden Path Template that provisions:

✔ Pre-structured application  
✔ Containerisation  
✔ CI/CD pipeline  
✔ Infrastructure-as-Code  
✔ Secure defaults  
✔ Repeatable environment setup  

---

## Outcome

Developers can bootstrap a compliant service in **minutes instead of days**.

---

## How to Use

```bash
bash scripts/bootstrap.sh <your-service-name>
```

This generates a ready-to-deploy service scaffold with all plumbing
pre-configured. See [docs/onboarding-guide.md](docs/onboarding-guide.md) for
the full walkthrough.

---

## Platform Engineering Concepts Demonstrated

| Concept | Where |
|---------|-------|
| Developer self-service | `scripts/bootstrap.sh` |
| Infrastructure as Code | `infra/terraform-main.tf` |
| Standardised CI/CD | `cicd/github-actions.yml` |
| Secure-by-default environments | `docs/security-model.md` |
| Reproducible onboarding | `template/` + `docs/onboarding-guide.md` |
| Architecture documentation | `architecture/platform-flow.md` |

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `bash scripts/bootstrap.sh my-svc` | Create a new service from the template |
| `uvicorn app.main:app --reload` | Run the service locally |
| `docker build -t my-svc:dev .` | Build the container |
| `terraform apply` | Provision Kubernetes infrastructure |

---

## Documentation

- [Architecture & Platform Flow](architecture/platform-flow.md)
- [Developer Onboarding Guide](docs/onboarding-guide.md)
- [Security Model](docs/security-model.md)
