variable "slack_webhook_url" {
  type = string
}

variable "github_token" {
  type        = string
  description = "A github personal access token"
}

variable "terraform_cloud_token" {
  type        = string
  description = "A terraform cloud org token"
}
