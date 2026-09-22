# GEN-00487 — DLQ policies on Pub/Sub subscriptions, max_delivery_attempts=5.
# Metric: Max Delivery Attempt Value · Pass/Fail.
resource "google_pubsub_topic" "dlq" { name = "${var.subscription}-dlq" }

resource "google_pubsub_subscription" "main" {
  name  = var.subscription
  topic = var.topic

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dlq.id
    max_delivery_attempts = 5
  }
  retry_policy {
    minimum_backoff = "10s"
  }
}

variable "subscription" { type = string }
variable "topic"        { type = string }
