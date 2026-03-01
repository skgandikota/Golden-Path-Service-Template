# Onboarding Guide — Golden Path Service Template

Welcome to the platform! This guide gets you from zero to a running, compliant
microservice in minutes.

---

## Prerequisites

| Tool | Minimum version | Install guide |
|------|----------------|---------------|
| Git | 2.40+ | https://git-scm.com |
| Docker | 24+ | https://docs.docker.com/get-docker |
| Python | 3.12+ | https://python.org |
| Terraform | 1.7+ | https://developer.hashicorp.com/terraform/install |
| kubectl | 1.29+ | https://kubernetes.io/docs/tasks/tools |

---

## Quick Start (5 minutes)

### Step 1 — Clone the template repository

```bash
git clone https://github.com/your-org/golden-path-service-template.git
cd golden-path-service-template
```

### Step 2 — Bootstrap your new service

```bash
bash scripts/bootstrap.sh <your-service-name>
```

Example:

```bash
bash scripts/bootstrap.sh payment-service
```

This copies the template into a new folder called `payment-service/` and
renames all placeholders.

### Step 3 — Enter your new service folder

```bash
cd payment-service
```

### Step 4 — Run locally

```bash
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Visit http://localhost:8000/docs for the auto-generated API documentation.

### Step 5 — Build and run the container

```bash
docker build -t payment-service:dev .
docker run -p 8000:8000 payment-service:dev
```

### Step 6 — Push to GitHub

```bash
git init && git add . && git commit -m "feat: initial service scaffold"
git remote add origin https://github.com/your-org/payment-service.git
git push -u origin main
```

The CI/CD pipeline defined in `cicd/github-actions.yml` will trigger
automatically.

---

## Folder Structure

```
your-service-name/
├── app/
│   └── main.py          # Your API — start adding endpoints here
├── Dockerfile           # Container definition — do not modify unless needed
├── requirements.txt     # Python dependencies
├── cicd/
│   └── github-actions.yml  # Automated pipeline
├── infra/
│   └── terraform-main.tf   # Infrastructure definition
└── docs/
    └── ...              # Project documentation
```

---

## Customising the Service

| What to change | Where |
|---------------|-------|
| Business logic | `app/main.py` |
| New dependencies | `requirements.txt` |
| Extra pipeline steps | `cicd/github-actions.yml` |
| Infrastructure tweaks | `infra/terraform-main.tf` |

---

## Provisioning Infrastructure

```bash
cd infra
terraform init
terraform plan -var="service_name=payment-service"
terraform apply -var="service_name=payment-service"
```

Terraform will create the Kubernetes namespace, deployment, and service for
your new microservice.

---

## Need Help?

- **Platform team Slack**: `#platform-engineering`
- **Internal docs portal**: https://platform.internal/docs
- **Architecture overview**: `architecture/platform-flow.md`
- **Security model**: `docs/security-model.md`

---

## Checklist Before Going Live

- [ ] Service boots locally with `uvicorn`
- [ ] Container builds without errors
- [ ] `/health` endpoint returns `{"status": "healthy"}`
- [ ] CI/CD pipeline passes in GitHub Actions
- [ ] Terraform plan reviewed and applied
- [ ] No hard-coded secrets in code
- [ ] Resource limits set in `terraform-main.tf`
