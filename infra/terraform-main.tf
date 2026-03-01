# Golden Path Service Template — Infrastructure as Code
# Every service gets its infrastructure from code, never from manual setup.
#
# This file demonstrates the IaC pattern used for all platform services.
# Replace variable defaults and resource names to match your real environment.

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
  }

  # Remote state — uncomment and configure for real deployments
  # backend "s3" {
  #   bucket = "platform-terraform-state"
  #   key    = "services/${var.service_name}/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# ── Variables ──────────────────────────────────────────────────────────────────

variable "service_name" {
  description = "Name of the microservice being provisioned."
  type        = string
  default     = "hello-platform-service"
}

variable "namespace" {
  description = "Kubernetes namespace the service is deployed into."
  type        = string
  default     = "platform-services"
}

variable "replicas" {
  description = "Number of pod replicas."
  type        = number
  default     = 2
}

variable "container_image" {
  description = "Full container image reference (repo/image:tag)."
  type        = string
  default     = "hello-platform-service:latest"
}

variable "container_port" {
  description = "Port the application listens on inside the container."
  type        = number
  default     = 8000
}

# ── Kubernetes Namespace ───────────────────────────────────────────────────────

resource "kubernetes_namespace" "service_namespace" {
  metadata {
    name = var.namespace
    labels = {
      "managed-by"   = "terraform"
      "golden-path"  = "true"
      "team"         = "platform-engineering"
    }
  }
}

# ── Kubernetes Deployment ──────────────────────────────────────────────────────

resource "kubernetes_deployment" "service" {
  metadata {
    name      = var.service_name
    namespace = kubernetes_namespace.service_namespace.metadata[0].name
    labels = {
      app           = var.service_name
      "managed-by"  = "terraform"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.service_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.service_name
        }
      }

      spec {
        # Security context — non-root by default
        security_context {
          run_as_non_root = true
          run_as_user     = 1000
        }

        container {
          name  = var.service_name
          image = var.container_image

          port {
            container_port = var.container_port
          }

          # Liveness and readiness probes
          liveness_probe {
            http_get {
              path = "/health"
              port = var.container_port
            }
            initial_delay_seconds = 10
            period_seconds        = 15
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = var.container_port
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          # Resource limits — prevent noisy-neighbour issues
          resources {
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

# ── Kubernetes Service ─────────────────────────────────────────────────────────

resource "kubernetes_service" "service" {
  metadata {
    name      = var.service_name
    namespace = kubernetes_namespace.service_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = var.service_name
    }

    port {
      port        = 80
      target_port = var.container_port
    }

    type = "ClusterIP"
  }
}

# ── Outputs ────────────────────────────────────────────────────────────────────

output "service_name" {
  description = "Deployed service name."
  value       = kubernetes_deployment.service.metadata[0].name
}

output "namespace" {
  description = "Kubernetes namespace."
  value       = kubernetes_namespace.service_namespace.metadata[0].name
}

output "service_endpoint" {
  description = "Internal cluster endpoint for the service."
  value       = "${kubernetes_service.service.metadata[0].name}.${var.namespace}.svc.cluster.local"
}
