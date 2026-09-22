# GEN-00454 — cloud_run_base.tf. Metric: Config Syntax Validity · Pass/Fail.
resource "google_cloud_run_v2_service" "base" {
  name     = var.service_name
  location = var.region

  template {
    containers {
      image = var.image
      resources {
        limits = { cpu = "1", memory = "512Mi" }
      }
    }
    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
  }
}

variable "service_name" { type = string }
variable "region"       { type = string, default = "me-central1" }
variable "image"        { type = string }
