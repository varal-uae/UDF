# GEN-00586 — Deploy MCP Server microservice to Cloud Run.
# Metric: Deployment Readiness · Pass/Fail.
resource "google_cloud_run_v2_service" "mcp_server" {
  name     = "mcp-server"
  location = var.region
  template {
    containers {
      image = var.mcp_image
      ports { container_port = 8080 }
    }
    scaling { min_instance_count = 1, max_instance_count = 5 }
  }
}
variable "region"    { type = string, default = "me-central1" }
variable "mcp_image" { type = string }
